//  PVErrorType.swift
//  Created by Techtic on 11/12/24.

import Foundation

public enum PVErrorType: Error, LocalizedError {
    case noInternetConnection
    case parseResponseFail
    case parseUrlFail
    case notFound
    case validationError
    case serverError
    case wrongOTP
    case defaultError
    case Unauthorized
    case noCredentials
    case badRequest
    case networkError
    
    public var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "Unable to connect. Please check your internet connection."
        case .parseUrlFail:
            return "Error initializing URL object. Please check the URL and try again."
        case .notFound:
            return "Requested item not found."
        case .validationError:
            return "Input validation errors. Please review and correct your input."
        case .serverError:
            return "Internal server error. Please try again later."
        case .defaultError:
            return "Oops! Something went wrong. Please try again later."
        case .parseResponseFail:
            return "Unable to parse the response. Please try again."
        case .wrongOTP:
            return "Incorrect OTP entered. Please try again."
        case .Unauthorized:
            return "Access denied. Please ensure you have the appropriate permissions."
        case .noCredentials:
            return "No authentication credentials were found."
        case .badRequest:
            return "Bad request."
        case .networkError:
            return "Network Error"
        }
    }
}
