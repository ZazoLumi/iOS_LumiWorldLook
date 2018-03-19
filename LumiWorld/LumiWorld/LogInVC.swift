//
//  LogInVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import Foundation
import UIKit

class LogInVC: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
        let dict: [Rule] = [RequiredRule(), EmailRule()]
        let dict1: [Rule] = [RequiredRule(), EmailRule()]
        
        let customview = CustomTableView(placeholders: [["Mobile Number","Password"]], texts: [["",""]], images:[["Artboard","Artboard"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict1],["rule":dict]])
        
        viewTblData.addSubview(customview)

        
    }
    @IBAction func onBtnSignInTapped(_ sender: Any) {
        UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
    }

    @IBAction func onBtnForgotPasswordTapped(_ sender: Any) {
    }
    @IBAction func onBtnSignUpTapped(_ sender: Any) {
    }
    
}

