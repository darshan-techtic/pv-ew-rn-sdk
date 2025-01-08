//  PVActivityIndicator.swift
//  Created by Techtic on 20/09/24.

import Foundation
import UIKit

public class PVActivityIndicator: UIView {
    
    // Singleton instance
    public static let shared = PVActivityIndicator()
    
    // Public activity indicator view
    public var activityIndicatorView: UIActivityIndicatorView!
    
    // Public initializer with frame
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // Public required initializer
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // Public method to setup the UI
    public func setupUI() {
        backgroundColor = UIColor.clear
        activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color =  #colorLiteral(red: 0.2, green: 0.4666666667, blue: 1, alpha: 1)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // Public method to start animating and show the indicator
    public func startAnimating() {
        activityIndicatorView.startAnimating()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first {
            frame = keyWindow.frame
            DispatchQueue.main.async {
                self.activityIndicatorView.center = self.center
                keyWindow.addSubview(self)
            }
        }
    }
    
    // Public method to stop animating and hide the indicator
    public func stopAnimating() {
        activityIndicatorView.stopAnimating()
        removeFromSuperview()
    }
}
