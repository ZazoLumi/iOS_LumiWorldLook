//
//  inviteFriendVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/06/06.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MBProgressHUD

class inviteFriendVC: UIViewController,FormDataDelegate {
    var customview : CustomTableView!
    @IBOutlet weak var viewTblData: UIView!
    @IBOutlet weak var lblUserName : UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblUserName.text = "Hi \(GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!)"
        let dict: [Rule] = [RequiredRule(), MinLengthRule()]
        let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
        let dict2: [Rule] = [RequiredRule(), PhoneNumberRule()]
        
        customview = CustomTableView(placeholders: [["Name","Surname","Mobile Number"]], texts: [["","",""]], images:[["Artboard 70xxxhdpi","Artboard 70xxxhdpi","Artboard 71xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1],["rule":dict2]],fieldType:[[4,5,1]])
        customview.formDelegate = self
        customview.isFromProfile = true
        viewTblData.addSubview(customview)

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
       // customview.isFromProfile = false
    }
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func onBtnClosePopupTapped(_ sender: Any) {
        self.parent?.view.backgroundColor = UIColor.white
        self.view.superview?.removeBlurEffect()
        removeAnimate()
    }
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
                self.parent?.view.backgroundColor = UIColor.white
            }
        })
    }
    
    @IBAction func onBtnSubmitTapped(_ sender: Any) {
        customview.doneAction()
    }
    
    func processedContacts(contact:EPContact) {
        
    }
    func processedFormData(formData: Dictionary<String, String>) {
        do {
            let strUserName : String  = formData["0"]!
            let strUserSurname : String  = formData["1"]!
            var strUserMobile : String  = formData["0"]!
            strUserMobile = strUserMobile.replacingOccurrences(of: "+", with:"")
            
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
            let param = ["lumiFirstName": GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName,"lumiLastName": GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName, "lumiMobile":GlobalShareData.sharedGlobal.objCurrentUserDetails.cell,"lumineerName":"","friendFirstName":strUserName,"friendLastName":strUserSurname,"friendMobile":strUserMobile,"inviteMsg":""]
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIInviteAFriendToLumiWorld)"
            AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
                //                let userObj = UserData(json:json)
                let tempDict = json.dictionary
                MBProgressHUD.hide(for: (self.navigationController?.view)!, animated: true)
                guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                    let message = tempDict!["response"]?.string
                    self.navigationController?.showCustomAlert(strTitle: "", strDetails: message!, completion: { (str) in
                    })
                    return
                }
                self.navigationController?.showCustomAlert(strTitle: self.lblUserName.text!, strDetails: "Thank you  for suggesting Lumi World to \(strUserName) \n We will be contacting \(strUserName) shortly. \n Team Lumi World", completion: { (str) in
                    self.onBtnClosePopupTapped((Any).self)
                })

                print(json)
            }, failure: { (Error) in
                MBProgressHUD.hide(for: (self.navigationController?.view)!, animated: true)
                self.navigationController?.showCustomAlert(strTitle: "", strDetails: Error.localizedDescription, completion: { (str) in
                    print(Error.localizedDescription)
                })
            })
        } catch let jsonError{
            print(jsonError)
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
