//
//  ForgotPasswordVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/20.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MBProgressHUD

class ForgotPasswordVC: UIViewController,FormDataDelegate {
    var customview : CustomTableView!
    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        
         customview = CustomTableView(placeholders: [["Mobile Number"]], texts: [[""]], images:[["Artboard 71xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict]],fieldType:[[1]])
        customview.formDelegate = self
        viewTblData.addSubview(customview)

    }
    @IBAction func onBtnSignInTapped(_ sender: Any) {
        if #available(iOS 11.0, *) {
            UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func onBtnResetPasswordTapped(_ sender: Any) {
        customview.doneAction()
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
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIForgotPassword)"
        do {
            var strUser : String  = formData["0"]!
            GlobalShareData.sharedGlobal.userCellNumber = strUser
            strUser = strUser.replacingOccurrences(of: "+", with:"")
            let param = ["cellNumber": strUser,"email":""]
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")

            AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
                print(json)
                hud.hide(animated: true)
                let tempDict = json.dictionary
                guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                    let message = tempDict!["responseText"]?.string
                    self.showCustomAlert(strTitle: "", strDetails: message!, completion: { (str) in
                    })
                    return
                }

                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let objTemporaryPasswordVC = storyBoard.instantiateViewController(withIdentifier: "TemporaryPasswordVC") as! TemporaryPasswordVC
                self.navigationController?.pushViewController(objTemporaryPasswordVC, animated: true)

                
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
