//
//  ATKeychainManager.swift
//  ATKit
//
//  Created by Rupendra on 29/08/20.
//  Copyright © 2020 Rupendra. All rights reserved.
//

import UIKit


public class ATUtilityManager: NSObject {
    
    public static var topWindow: UIWindow? {
        // Take top-most window, as this will hide the keyboard and other windows as well.
        var aReturnVal :UIWindow?
        if let aWindow = UIApplication.shared.keyWindow {
            aReturnVal = aWindow
        } else {
            aReturnVal = UIApplication.shared.windows.last
        }
        return aReturnVal
    }
    
    
    public static func topViewController(controller pController: UIViewController? = ATUtilityManager.topWindow?.rootViewController) -> UIViewController? {
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
    
}
