//
//  TemporaryPasswordVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/20.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MBProgressHUD

class TemporaryPasswordVC: UIViewController,FormDataDelegate {
    var customview : CustomTableView!
    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
        
         customview = CustomTableView(placeholders: [["Mobile Number","Code"]], texts: [[GlobalShareData.sharedGlobal.userCellNumber,""]], images:[["Artboard 71xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1]],fieldType:[[1,6]])
        customview.formDelegate = self
        viewTblData.addSubview(customview)

    }
    @IBAction func onBtnSignInTapped(_ sender: Any) {
        customview.doneAction()
    }
    
    @IBAction func onBtnResendCodeTapped(_ sender: Any) {
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIForgotPassword)"
        do {
            let strUser = GlobalShareData.sharedGlobal.userCellNumber.replacingOccurrences(of: "+", with:"")
            let param = ["cellNumber": strUser,"email":""]
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
                self.showCustomAlert(strTitle: "Success", strDetails:"Temporary password has been sent on your register device.")
                
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
    @IBAction func onBtnSignUpTapped(_ sender: Any) {
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
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIValidateCode)"
        do {
            var strUser : String  = formData["0"]!
            strUser = strUser.replacingOccurrences(of: "+", with:"")
            let param = ["cellNumber": strUser,"password":formData["1"], "deviceToken":"123454234326789"]
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")

            AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
                print(json)
                hud.hide(animated: true)
                let tempDict = json.dictionary
                guard let code = tempDict!["responsCode"]?.intValue, code != 0 else {
                    let message = tempDict!["response"]?.string
                    self.showCustomAlert(strTitle: "", strDetails: message!, completion: { (str) in
                    })
                    return
                }
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let objChangePasswordVC = storyBoard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
                    self.navigationController?.pushViewController(objChangePasswordVC, animated: true)

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
