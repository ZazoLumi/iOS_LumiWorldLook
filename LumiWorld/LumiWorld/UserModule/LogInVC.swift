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
    
    var customview : CustomTableView!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
        
        customview = CustomTableView(placeholders: [["Mobile Number","Password"]], texts: [["",""]], images:[["Artboard 71xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1]],fieldType:[[1,2]])
        customview.formDelegate = self
        viewTblData.addSubview(customview)

    }
    @IBAction func onBtnSignInTapped(_ sender: Any) {
        UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
        return

        customview.doneAction()
//        UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
    }

    @IBAction func onBtnForgotPasswordTapped(_ sender: Any) {
    }
    @IBAction func onBtnSignUpTapped(_ sender: Any) {
    }
    func processedFormData(formData: Dictionary<String, String>) {
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APILogin)"
        do {
            var strUser : String  = formData["0"]!
            strUser = strUser.replacingOccurrences(of: "+", with:"")
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")

            let param = ["cellNumber": strUser, "password":formData["1"],"deviceToken":"123456789"]
            AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
//                let userObj = UserData(json:json)
                let tempDict = json.dictionary
                hud.hide(animated: true)
                guard let code = tempDict!["responsCode"]?.intValue, code != 0 else {
                    let message = tempDict!["response"]?.string
                    self.showCustomAlert(strTitle: "", strDetails: message!, completion: { (str) in
                    })
                    return
                }
                let realm = try! Realm()
                let id : Int = json["id"].intValue
                let data  = realm.objects(UserData.self).filter("id == %d", id)
                let newObj = UserData(id : id , gcmId : json["gcmId"].string,profilePic : json["profilePic"].string,token : json["token"].string,updateDate : json["updateDate"].string,lastName : json["lastName"].string,appVersion : json["appVersion"].string,cell : json["cell"].string,status : json["status"].string,password : json["password"].string,createDate : json["createDate"].string,displayName : json["displayName"].string,firstName : json["firstName"].string)

                GlobalShareData.sharedGlobal.objCurrentUserDetails = newObj
                if data.count>0 {
                    GlobalShareData.sharedGlobal.realmManager.editObjects(objs: newObj)
                }
                else {
                    GlobalShareData.sharedGlobal.realmManager.saveObjects(objs: newObj)
                }

                UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
                print(json)
            }, failure: { (Error) in
                hud.hide(animated: true)
                self.showCustomAlert(strTitle: "", strDetails: Error.localizedDescription, completion: { (str) in
                    print(Error.localizedDescription)
                })
            })
        } catch let jsonError{
            print(jsonError)

        }

    }
}

