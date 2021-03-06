//
//  CreateAccountVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/20.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import SCLAlertView
import MBProgressHUD

typealias AlertResponseBlock = (String?) -> Void
var alertCompletionBlock: AlertResponseBlock?

class CreateAccountVC: UIViewController,FormDataDelegate {
    @IBOutlet weak var btnTermsAndCondition: UIButton!
    @IBOutlet weak var viewTblData: UIView!
    var realmManager : RealmManager!
    var customview : CustomTableView!

    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), MinLengthRule()]
        let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
        let dict2: [Rule] = [RequiredRule(), MinLengthRule()]
        let dict3: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict6: [Rule] = [RequiredRule(), EmailRule()]
        let dict4: [Rule] = [RequiredRule(), PasswordRule()]
        let dict5: [Rule] = [RequiredRule(), PasswordRule()]
        
        customview = CustomTableView(placeholders: [["Name","Surname","My Lumi Profile Name","Mobile Number","Email Address","Password","Repeat New Password"]], texts: [["","","","+27","","",""]], images:[["Artboard 70xxxhdpi","Artboard 70xxxhdpi","Artboard 70xxxhdpi","Artboard 71xxxhdpi","emailIcon","Artboard 72xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1],["rule":dict2],["rule":dict3],["rule":dict6],["rule":dict4],["rule":dict5]],fieldType:[[4,5,7,1,8,2,3]])
        customview.formDelegate = self
        viewTblData.addSubview(customview)
        
    }

    @IBAction func onBtnTermAndConditionTapped(_ sender: Any) {
        btnTermsAndCondition.isSelected  ? (btnTermsAndCondition.isSelected = false) : (btnTermsAndCondition.isSelected = true)
        
    }
    @IBAction func onBtnCreateAccountTapped(_ sender: Any) {
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
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APICreateAccount)"
        do {
            if !btnTermsAndCondition.isSelected {
                showCustomAlert(strTitle: "", strDetails: "Please accept Terms and Conditions.", completion: { (str) in
                    
                })
            }
            else {
                var strCellNumber : String  = formData["3"]!
                strCellNumber = strCellNumber.replacingOccurrences(of: "+", with:"")
                let newObj = UserData(id : 123456 , gcmId : nil,profilePic : nil,token : nil,updateDate : nil,lastName : formData["1"],appVersion : nil,cell : strCellNumber,status : nil,password : formData["5"],createDate : nil,displayName : formData["2"],firstName : formData["0"],emailAddress:formData["4"])

                let param = ["cellNumber": strCellNumber,"firstName":formData["0"],"lastName":formData["1"],"displayName":formData["2"],"deviceToken":"123456789","email":formData["4"]]
                let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")

                AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
                    //                let userObj = UserData(json:json)
                    GlobalShareData.sharedGlobal.objCurrentUserDetails = newObj
                    hud.hide(animated: true)
                    let tempDict = json.dictionary
                    guard tempDict?.count != 0, (tempDict?.keys.contains("responseCode"))!, let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        let message = tempDict!["responseText"]?.string
                        self.showCustomAlert(strTitle: "", strDetails: message!, completion: { (str) in
                        })
                        return
                    }

                    self.showCustomAlert(strTitle: "Success", strDetails: "Your account is created successfully.", completion: { (str) in
                        
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let objVerifyAccoutVC = storyBoard.instantiateViewController(withIdentifier: "VerifyAccoutVC") as! VerifyAccoutVC
                        UserDefaults.standard.setBoolValue(value: true, key: UserDefaultsKeys.pendingVerification)
                        self.navigationController?.pushViewController(objVerifyAccoutVC, animated: true)
                    })
                    print(json)
                }, failure: { (Error) in
                    hud.hide(animated: true)
                    self.showCustomAlert(strTitle: "", strDetails: Error.localizedDescription, completion: { (str) in
                        print(Error.localizedDescription)
                    })
                })
            }

        } catch let jsonError{
            print(jsonError)
            
        }
        
    }

}

extension UIViewController:FloatRatingViewDelegate {
    // new functionality to add to SomeType goes here
    func showCustomAlert(strTitle : String, strDetails : String, completion: AlertResponseBlock? = nil) -> Void {
        alertCompletionBlock = completion
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false,
            dynamicAnimatorActive: true,
            buttonsLayout: .horizontal
        )
        let alert = SCLAlertView(appearance: appearance)
        _ = alert.addButton("OK") {
            alertCompletionBlock?("OK button tapped")
            print("OK button tapped")
        }
        
        let icon = UIImage(named:"Artboard 128xxhdpi")
        let color = UIColor(red: 110, green: 187, blue: 171)
        
        _ = alert.showCustom(strTitle, subTitle: strDetails, color: color!, icon:icon!)
        // ...
        // optional closure callback

    }
    func showRatingAlert(currntRating:Double, completion: AlertResponseBlock? = nil) {
        let alert = UIAlertController(title: "PLEASE RATE US", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.setValue(NSAttributedString(string: "PLEASE RATE US \n \n ", attributes: [NSAttributedString.Key.font : UIFont.init(name: "Helvetica", size: 16) as Any,NSAttributedString.Key.foregroundColor:UIColor(red: 110, green: 187, blue: 171)!]), forKey: "attributedTitle")
        let floatRatingView = FloatRatingView(frame: CGRect(x: 60, y: 55, width: 160,height:40))
        floatRatingView.backgroundColor = UIColor.clear
         alert.view.addSubview(floatRatingView)
        floatRatingView.backgroundColor = UIColor.clear
        
        /** Note: With the exception of contentMode, type and delegate,
         all properties can be set directly in Interface Builder **/
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        floatRatingView.type = .wholeRatings
        floatRatingView.rating = 0
        floatRatingView.minRating = 0
        floatRatingView.maxRating = 5
        floatRatingView.emptyImage = UIImage.init(named: "Star-Icon1")
        floatRatingView.fullImage = UIImage.init(named: "Star-Icon")
        floatRatingView.rating = currntRating

        let notNowAction = UIAlertAction(title: "Not Now", style: .default)
        notNowAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")
        alert.addAction(notNowAction)

        let submitAction = UIAlertAction(title:"Submit", style:.default ) { (action) in
            completion!(String(format: "%.2f", floatRatingView.rating))
        }
        submitAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")
        alert.addAction(submitAction)

        self.present(alert, animated: true, completion: nil)

        }

        
    }

