//
//  tabbarcontroller.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import Foundation
import ESTabBarController_swift

@available(iOS 11.0, *)
enum ExampleProvider {

static func customIrregularityStyle(delegate: UITabBarControllerDelegate?) -> ExampleNavigationController {
    let tabBarController = ESTabBarController()
    tabBarController.delegate = delegate
    tabBarController.tabBar.backgroundImage = UIImage(named: "blackBG")
    tabBarController.shouldHijackHandler = {
        tabbarController, viewController, index in
        if index == 1 {
            //return true
        }
        return false
    }
    tabBarController.didHijackHandler = {
        [weak tabBarController] tabbarController, viewController, index in
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            //tabBarController?.selectedIndex = 1

//            let alertController = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
//            let takePhotoAction = UIAlertAction(title: "Take a photo", style: .default, handler: nil)
//            alertController.addAction(takePhotoAction)
//            let selectFromAlbumAction = UIAlertAction(title: "Select from album", style: .default, handler: nil)
//            alertController.addAction(selectFromAlbumAction)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            alertController.addAction(cancelAction)
//            tabBarController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    let v1 = storyBoard.instantiateViewController(withIdentifier: "MyLumiFeedVC") as! MyLumiFeedVC
    let v2 = storyBoard.instantiateViewController(withIdentifier: "LumiCategoryVC") as! LumiCategoryVC
    let v3 = storyBoard.instantiateViewController(withIdentifier: "MyLumiProfileVC") as! MyLumiProfileVC

    
    v1.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "Artboard 76xxhdpi"), selectedImage: UIImage(named: "Artboard 76xxhdpi"))
    v2.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: nil, image: UIImage(named: "Artboard 77xxhdpi"), selectedImage: UIImage(named: "Artboard 77xxhdpi"))
    v3.tabBarItem = ESTabBarItem.init(ExampleIrregularityBasicContentView(), title: nil, image: UIImage(named: "Artboard 78xxhdpi"), selectedImage: UIImage(named: "Artboard 78xxhdpi"))
    
    
    tabBarController.viewControllers = [v1, v2, v3]
    tabBarController.selectedIndex = 1
    let navigationController = ExampleNavigationController.init(rootViewController: tabBarController)
    navigationController.navigationItem.addSettingButtonOnRight()
    navigationController.navigationItem.addBackButtonOnLeft()

    return navigationController
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? ESTabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


extension UINavigationBar {
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        subviews.forEach { (view) in
            if let imageView = view as? UIImageView {
                if imageView.image == backIndicatorImage || imageView.image == backIndicatorTransitionMaskImage {
                    view.frame.origin.y = floor((frame.height - view.frame.height) / 2.0)
                }
            }
        }
    }

}

class ExampleNavigationController: UINavigationController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UIBarButtonItem.appearance()
        appearance.setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: 0.0, vertical: -60), for: .default)
        self.navigationBar.isTranslucent = true
        self.navigationBar.barTintColor = UIColor.init(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 0.8)
        #if swift(>=4.0)
            self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0)]
        #elseif swift(>=3.0)
            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0), NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)];
        #endif
        self.navigationBar.tintColor = UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0)
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(red: 180, green: 219, blue: 212)
            
        }

        UIApplication.shared.statusBarStyle = .lightContent
        


    }
    
}
//class ExampleIrregularityBasicContentView: ExampleBouncesContentView {
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        textColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        highlightTextColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
//        iconColor = UIColor.init(white: 255.0 / 255.0, alpha: 1.0)
//        highlightIconColor = UIColor.init(red: 23/255.0, green: 149/255.0, blue: 158/255.0, alpha: 1.0)
//        backdropColor = UIColor.init(red: 10/255.0, green: 66/255.0, blue: 91/255.0, alpha: 1.0)
//        highlightBackdropColor = UIColor.init(red: 10/255.0, green: 66/255.0, blue: 91/255.0, alpha: 1.0)
//    }
//    
//    public required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

