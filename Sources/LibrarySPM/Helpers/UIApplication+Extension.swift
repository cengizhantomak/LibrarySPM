//
//  UIApplication+Extension.swift
//  Folders
//
//  Created by Cengizhan Tomak on 27.10.2023.
//

import UIKit

extension UIApplication{
    var firstWindow : UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.firstWindow?.rootViewController) -> UIViewController? {
        if let nav = controller as? UINavigationController {
            return topViewController(controller: nav.visibleViewController)
        } else if let tab = controller as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(controller: selected)
        } else if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
