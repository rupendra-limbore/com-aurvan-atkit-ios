//
//  ATLocalAuthenticationManager.swift
//  
//
//  Created by Rupendra on 18/06/22.
//

import UIKit
import LocalAuthentication

public class ATLocalAuthenticationManager: NSObject {
    public static let shared :ATLocalAuthenticationManager = ATLocalAuthenticationManager()
    
    
    private var overlayView :UIVisualEffectView!
    
    private var expectedPassword :String?
    
    private var passwordAlertController: UIAlertController?
    
    private let overlayMessage = "You need to authenticate yourself to use the application."
    private let authenticationMessageFormat = "Enter password for %@"
    private let authenticationMessageDefaultAppName = "the app"
    private let authenticationReason = "You are accessing confidential data."
    private let cancelButtonTitle = "CANCEL"
    private let submitButtonTitle = "SUBMIT"
    private let proceedButtonTitle = "PROCEED"
    
    
    private var topWindow: UIWindow? {
        // Take top-most window, as this will hide the keyboard and other windows as well.
        var aReturnVal :UIWindow?
        if let aWindow = UIApplication.shared.keyWindow {
            aReturnVal = aWindow
        } else {
            aReturnVal = UIApplication.shared.windows.last
        }
        return aReturnVal
    }
    
    
    private func topViewController(controller pController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        var aReturnVal :UIViewController?
        
        if let aNavigationController = pController as? UINavigationController {
            aReturnVal = self.topViewController(controller: aNavigationController.visibleViewController)
        } else if let aTabController = pController as? UITabBarController, let aSelectedViewController = aTabController.selectedViewController {
            aReturnVal = self.topViewController(controller: aSelectedViewController)
        } else if let aPresentedViewController = pController?.presentedViewController {
            aReturnVal = self.topViewController(controller: aPresentedViewController)
        } else {
            aReturnVal = pController
        }
        
        return aReturnVal
    }
    
    
    private func displayOverlay() {
        if self.overlayView != nil {
            self.overlayView.removeFromSuperview()
            self.overlayView = nil
        }
        self.overlayView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        
        self.topWindow?.addSubview(self.overlayView)
        self.topWindow?.bringSubviewToFront(self.overlayView)
        
        self.overlayView.frame = self.topWindow?.bounds ?? UIScreen.main.bounds
        
        let aLabel = UILabel()
        aLabel.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        aLabel.textColor = UIColor.white
        aLabel.font = UIFont.systemFont(ofSize: 17.0)
        aLabel.numberOfLines = 0
        aLabel.textAlignment = NSTextAlignment.center
        aLabel.text = self.overlayMessage
        self.overlayView.contentView.addSubview(aLabel)
        
        aLabel.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[aLabel]-20-|", options: [], metrics: nil, views: ["aLabel":aLabel]))
        self.overlayView!.addConstraint(NSLayoutConstraint(item: aLabel, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.overlayView!, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: -40))
        
        let aButton = UIButton(type: UIButton.ButtonType.system)
        aButton.frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
        aButton.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        aButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        aButton.backgroundColor = aButton.tintColor
        aButton.setTitle(self.proceedButtonTitle, for: UIControl.State.normal)
        aButton.addTarget(self, action: #selector(self.didSelectProceedToAuthentication), for: UIControl.Event.touchUpInside)
        self.overlayView.contentView.addSubview(aButton)
        
        aButton.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView!.addConstraint(NSLayoutConstraint(item: aButton, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.overlayView!, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0))
        self.overlayView!.addConstraint(NSLayoutConstraint(item: aButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200))
        self.overlayView!.addConstraint(NSLayoutConstraint(item: aButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: aLabel, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 20))
        self.overlayView!.addConstraint(NSLayoutConstraint(item: aButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40))
    }
    
    
    private func hideOverlay() {
        if self.overlayView != nil {
            self.overlayView.removeFromSuperview()
            self.overlayView = nil
        }
    }
    
    
    @objc private func didSelectProceedToAuthentication() {
        if let aPassword = self.expectedPassword {
            self.authenticateWithPassword(expectedPassword: aPassword)
        } else {
            self.authenticateWithBiometrics()
        }
    }
    
    
    public func authenticateWithBiometrics() {
        self.expectedPassword = nil
        
        DispatchQueue.main.async {
            self.displayOverlay()
        }
        
        let anAuthenticationContext = LAContext()
        var anError :NSError? = nil
        let aCanEvaluatePolicy = anAuthenticationContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &anError)
        if aCanEvaluatePolicy == true {
            anAuthenticationContext.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: self.authenticationReason, reply: {[weak self] (pIsAuthentic, pError) in
                var aShouldHideOverlay :Bool = false
                if pError == nil && pIsAuthentic == true {
                    aShouldHideOverlay = true
                }
                DispatchQueue.main.async {
                    if aShouldHideOverlay == true {
                        self?.hideOverlay()
                    } else {
                        self?.displayOverlay()
                    }
                }
            })
        }
    }
    
    
    public func authenticateWithPassword(expectedPassword pExpectedPassword: String) {
        self.expectedPassword = pExpectedPassword
        
        DispatchQueue.main.async {
            self.displayOverlay()
        }
        
        if self.passwordAlertController != nil {
            self.passwordAlertController?.dismiss(animated: false)
            self.passwordAlertController = nil
        }
        
        let anAlertController = UIAlertController(title: String(format: self.authenticationMessageFormat, (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String) ?? self.authenticationMessageDefaultAppName), message: self.authenticationReason, preferredStyle: .alert)
        anAlertController.addTextField(configurationHandler: { pTextField in
            pTextField.isSecureTextEntry = true
        })
        anAlertController.addAction(UIAlertAction(title: self.cancelButtonTitle, style: .cancel))
        anAlertController.addAction(UIAlertAction(title: self.submitButtonTitle, style: .default, handler: {[weak self] _ in
            var aShouldHideOverlay :Bool = false
            if self?.expectedPassword == anAlertController.textFields?.first?.text {
                aShouldHideOverlay = true
            }
            DispatchQueue.main.async {
                if aShouldHideOverlay == true {
                    self?.expectedPassword = nil
                    self?.hideOverlay()
                } else {
                    self?.displayOverlay()
                    self?.topViewController()?.present(anAlertController, animated: true)
                }
            }
        }))
        self.topViewController()?.present(anAlertController, animated: true)
        self.passwordAlertController = anAlertController
    }
}
