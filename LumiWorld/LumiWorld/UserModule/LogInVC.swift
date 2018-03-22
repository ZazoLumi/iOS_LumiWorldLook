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
    var customview : CustomTableView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict1: [Rule] = [RequiredRule(), PasswordRule()]
        
        customview = CustomTableView(placeholders: [["Mobile Number","Password"]], texts: [["",""]], images:[["Artboard 71xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1]],fieldType:[[1,2]])
        
        viewTblData.addSubview(customview)

    }
    @IBAction func onBtnSignInTapped(_ sender: Any) {
        customview.doneAction()
//        UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
    }

    @IBAction func onBtnForgotPasswordTapped(_ sender: Any) {
    }
    @IBAction func onBtnSignUpTapped(_ sender: Any) {
    }
    
}

