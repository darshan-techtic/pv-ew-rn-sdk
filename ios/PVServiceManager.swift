//  PVServiceManager.swift
//  Created by Techtic on 11/12/24.

import Foundation
import UIKit

public class PVServiceManager<T: Codable> {

    // MARK: - Variables
    public typealias CompletionHandler = (Result<T, PVErrorType>) -> Void
    private let config: URLSessionConfiguration
    private let session: URLSession

    public var idToken: String?
    public var accessToken: String?

    // MARK: - Initializer
    public init() {
        config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }

    // MARK: - API Call
    public func webServiceAPICall(endpoint: String, httpMethod: HTTPMethod, params: [String: Any], loaderEnabled: Bool, completionHandler: @escaping CompletionHandler) {
        guard let idToken = idToken, let accessToken = accessToken else {
            DispatchQueue.main.async {
                self.handleError(errorType: .noCredentials, completionHandler: completionHandler)
            }
            return
        }

        // Check network connectivity
        guard PVReachability.isConnectedToNetwork() else {
            DispatchQueue.main.async {
                self.handleError(errorType: .noInternetConnection, completionHandler: completionHandler)
            }
            return
        }

        // Build API URL
        let finalUrl = endpoint
        guard let encodedUrl = finalUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedUrl) else {
            DispatchQueue.main.async {
                self.handleError(errorType: .parseUrlFail, completionHandler: completionHandler)
            }
            return
        }
        
        print("Encoded URL --> \(encodedUrl)")

        // Show Loader
        if loaderEnabled {
            PVActivityIndicator.shared.startAnimating()
        }

        // Configure request
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        request.httpMethod = httpMethod.rawValue
        request.setValue("iOS", forHTTPHeaderField: "X-App-Source")
        request.setValue(idToken, forHTTPHeaderField: "idToken")
        request.setValue(accessToken, forHTTPHeaderField: "accessToken")

        // Prepare request body for POST
        if httpMethod == .post {
            preparePostRequest(&request, params: params)
        }

        // Execute the network request
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                PVActivityIndicator.shared.stopAnimating()

                if let error = error {
                    self.handleError(errorType: .networkError, completionHandler: completionHandler)
                    return
                }

                guard let response = response as? HTTPURLResponse, let data = data else {
                    self.handleError(errorType: .defaultError, completionHandler: completionHandler)
                    return
                }

                print("Status Code --> \(response.statusCode)")

                switch response.statusCode {
                case 200...299:
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        self.handleError(errorType: .parseResponseFail, completionHandler: completionHandler)
                    }
                case 400:
                    self.handleError(errorType: .badRequest, completionHandler: completionHandler)
                case 403:
                    self.handleError(errorType: .validationError, completionHandler: completionHandler)
                default:
                    self.handleError(errorType: .defaultError, completionHandler: completionHandler)
                }
            }
        }
        task.resume()
    }

    // MARK: - Helper Methods
    private func preparePostRequest(_ request: inout URLRequest, params: [String: Any]) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var data = Data()

        for (key, value) in params {
            if let stringValue = value as? String {
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(stringValue)\r\n".data(using: .utf8)!)
            }
        }

        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
    }

    private func handleError(errorType: PVErrorType, completionHandler: CompletionHandler) {
        print("Error: \(errorType)")
        completionHandler(.failure(errorType))
    }
}
