//
//  ChangePasswordVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/20.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MBProgressHUD

class ChangePasswordVC: UIViewController,FormDataDelegate {
    var customview : CustomTableView!

    @IBOutlet weak var btnTermsAndCondition: UIButton!
    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict1: [Rule] = [RequiredRule(), PasswordRule()]
        let dict2: [Rule] = [RequiredRule(), PasswordRule()]

         customview = CustomTableView(placeholders: [["Mobile Number","New Password","Repeat New Password"]], texts: [[GlobalShareData.sharedGlobal.userCellNumber,"",""]], images:[["Artboard 71xxxhdpi","Artboard 72xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1],["rule":dict2]],fieldType:[[1,2,3]])
        customview.formDelegate = self
        viewTblData.addSubview(customview)
        
    }
    
    @IBAction func onBtnTermAndConditionTapped(_ sender: Any) {
        btnTermsAndCondition.isSelected  ? (btnTermsAndCondition.isSelected = false) : (btnTermsAndCondition.isSelected = true)

    }
    @IBAction func onBtnChangePasswordTapped(_ sender: Any) {
        customview.doneAction()
    }
    
    @IBAction func onBtnBackTapped(_ sender: Any) {
        backButtonTapped()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func processedFormData(formData: Dictionary<String, String>) {
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIChangePassword)"
        do {
            if !btnTermsAndCondition.isSelected {
                showCustomAlert(strTitle: "", strDetails: "Please accept Terms and Conditions.", completion: { (str) in
                })
            }
            else {
            var strUser : String  = formData["0"]!
            strUser = strUser.replacingOccurrences(of: "+", with:"")
                let param = ["cellNumber": strUser,"newPassword":formData["1"],"email":""]
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
            AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
                print(json)
                hud.hide(animated: true)
                let tempDict = json.dictionary
                guard tempDict?.count != 0, (tempDict?.keys.contains("responseCode"))!, let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                    let message = tempDict!["responseText"]?.string
                    self.showCustomAlert(strTitle: "", strDetails: message!, completion: { (str) in
                    })
                    return
                }

                self.showCustomAlert(strTitle: "Success", strDetails: "Your password is changed successfully.", completion: { (str) in
                    self.navigationController?.popToRootViewController(animated: true)
                })
                
            }, failure: { (Error) in
                hud.hide(animated: true)
                self.showCustomAlert(strTitle: "", strDetails: Error.localizedDescription, completion: { (str) in
                    print(Error.localizedDescription)
                })
            })}
        } catch let jsonError{
            print(jsonError)
            
        }

    }

}

extension UIViewController {
    func backButtonTapped() {
        self.navigationController?.popViewController()
    }
}
