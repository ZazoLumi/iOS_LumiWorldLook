//
//  LogInVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Realm
import MBProgressHUD
class LogInVC: UIViewController,FormDataDelegate {
    
    @IBOutlet weak var constLogoTopSpace: NSLayoutConstraint!
    var customview : CustomTableView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
        if UserDefaults.standard.getBoolValue(key:UserDefaultsKeys.isAlreadyLogin) {
            let realm = try! Realm()
            let data  = realm.objects(UserData.self)
            if data.count>0 {
                GlobalShareData.sharedGlobal.objCurrentUserDetails = data[0]
                GlobalShareData.sharedGlobal.userCellNumber = data[0].cell
            }

            UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
        }
        if self.view.frame.size.height == 960 {
            constLogoTopSpace.constant = 30
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
        
        customview = CustomTableView(placeholders: [["Mobile Number","Password"]], texts: [["+27",""]], images:[["Artboard 71xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1]],fieldType:[[1,2]])
        customview.formDelegate = self
        viewTblData.addSubview(customview)
        self.checkPendingVerification()
    }
    
    func checkPendingVerification() {
        if UserDefaults.standard.getBoolValue(key:UserDefaultsKeys.pendingVerification) {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let firstVC = storyBoard.instantiateViewController(withIdentifier: "CreateAccountVC") as! CreateAccountVC
            let objVerifyAccoutVC = storyBoard.instantiateViewController(withIdentifier: "VerifyAccoutVC") as! VerifyAccoutVC
            self.navigationController?.pushViewController(firstVC, animated: false);
            self.navigationController?.pushViewController(objVerifyAccoutVC, animated: true);
        }
    }

    @IBAction func onBtnSignInTapped(_ sender: Any) {
//Static        UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
//        return
        customview.doneAction()
      //  UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
    }

    @IBAction func onBtnForgotPasswordTapped(_ sender: Any) {
    }
    @IBAction func onBtnSignUpTapped(_ sender: Any) {
    }
    func processedFormData(formData: Dictionary<String, String>) {
        do {
            let objUser = UserData()
            var strUser : String  = formData["0"]!
            strUser = strUser.replacingOccurrences(of: "+", with:"")
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
            let param = ["cellNumber": strUser, "password":formData["1"],"deviceToken":"123456789"]
            objUser.loginUserDetails(param: param as [String : AnyObject]) { (userData) in
                UserDefaults.standard.setBoolValue(value: true, key: UserDefaultsKeys.isAlreadyLogin)
                GlobalShareData.sharedGlobal.objCurretnVC = self
                GlobalShareData.sharedGlobal.getlatestCategoriesAndData()
              let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                hud.label.text = NSLocalizedString("Fetching Data...", comment: "HUD loading title")

                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if #available(iOS 11.0, *) {
                        DispatchQueue.main.async {
                            hud.hide(animated: true)}
                        UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
                    } else {
                        // Fallback on earlier versions
                        }
                }
            }
        } catch let jsonError{
            print(jsonError)

        }
    }
}

