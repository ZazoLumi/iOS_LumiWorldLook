//
//  LumiProfileDetails.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/06/01.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import MBProgressHUD
class LumiProfileDetails: UIViewController,FormDataDelegate,UITextFieldDelegate {
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    var customview : CustomTableView!
    var isImgChanged = false
    @IBOutlet weak var txtDisplayName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var btnImgProfilePic: UIButton!
    @IBOutlet weak var viewProfileTbl1: UIView!
    @IBOutlet weak var viewProfileTbl: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.addBackButtonOnLeft()
        self.navigationItem.title = "MY LUMI PROFILE"
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        btnCancel.isHidden = true
        btnDone.isHidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict1: [Rule] = [RequiredRule(), EmailRule()]
        
        txtFirstName.text = GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName
        txtLastName.text = GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName
        txtDisplayName.text = GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName
        let mobileNumber = "+" + GlobalShareData.sharedGlobal.objCurrentUserDetails.cell!
        customview = CustomTableView(placeholders: [["Mobile Number","Email Address"]], texts: [[mobileNumber,GlobalShareData.sharedGlobal.objCurrentUserDetails.emailAddress!]], images:[["Artboard 71xxxhdpi","emailIcon"]], frame:CGRect(x: 0
            , y: 0, width: viewProfileTbl1.frame.size.width, height: viewProfileTbl1.frame.size.height),rrules:[["rule":dict],["rule":dict1]],fieldType:[[1,8]])
        customview.formDelegate = self
        customview.isTopTitle = true
        viewProfileTbl1.addSubview(customview)
        let urlOriginalImage : URL!
        if GlobalShareData.sharedGlobal.strImagePath.count > 0{
            urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.strImagePath)
            self.isImgChanged = true
        }
        else {
            guard GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic != nil else {
                return
            }

            if(GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic?.hasUrlPrefix())!
            {
                urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic!)
            }
            else {
                let fileName = GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic?.lastPathComponent
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                GlobalShareData.sharedGlobal.strImagePath = urlOriginalImage.absoluteString
            }
        }
        Alamofire.request(urlOriginalImage!).responseImage { response in
            debugPrint(response)
            if let image = response.result.value {
                let scalImg = image.af_imageScaled(to: CGSize(width:self.btnImgProfilePic.frame.size.width, height: self.btnImgProfilePic.frame.size.height))
                self.btnImgProfilePic.setImage(scalImg, for: .normal)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    
    @IBAction func onBtnDoneTapped(_ sender: Any) {
        customview.doneAction()
    }
    @IBAction func onBtnEditTapped(_ sender: Any) {
        btnCancel.isHidden = false
        btnDone.isHidden = false

        if btnImgProfilePic.imageView?.image == nil {
            CameraHandler.shared.showProfileActionSheet(vc: self,withDeletePhoto:false)
            CameraHandler.shared.isFromProfile = true
            CameraHandler.shared.didFinishCapturingImage = { (image, imgUrl) in
                GlobalShareData.sharedGlobal.strImagePath = (imgUrl?.absoluteString)!
                self.btnImgProfilePic.setImage(image, for: .normal)
                self.isImgChanged = true
            }
        }
        else {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let objviewProfileImgVC = storyBoard.instantiateViewController(withIdentifier: "viewProfileImgVC") as! viewProfileImgVC
            self.navigationController?.pushViewController(objviewProfileImgVC, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        GlobalShareData.sharedGlobal.strImagePath = ""
    }
    @IBAction func onBtnCancelTapped(_ sender: Any) {
        self.navigationController?.popViewController()
    }
    func processedFormData(formData: Dictionary<String, String>) {
        do {
            var strUser : String  = formData["0"]!
            strUser = strUser.replacingOccurrences(of: "+", with:"")
            let param = ["cell": strUser,"firstName":txtFirstName?.text,"lastName":txtLastName?.text,"displayName":txtDisplayName?.text,"email":formData["1"]]
            let objUserData = UserData()
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
            var filePath = ""
            if isImgChanged {
                filePath = GlobalShareData.sharedGlobal.strImagePath
            }
            objUserData.updateUserProfileData(param: param as [String : AnyObject], filePath:filePath ) { (objUsr) in
                DispatchQueue.main.async {
                    hud.hide(animated: true, afterDelay: 0)
                    self.showCustomAlert(strTitle: "", strDetails: "Profile data is updated successfully.", completion: { (str) in
                        let realm = try! Realm()
                            try! realm.write {
                                realm.add(objUsr, update: true)
                            }
                        self.navigationController?.popViewController()
                    })
                }
            }
        } catch let jsonError{
            print(jsonError)
            
        }
        
    }
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        btnCancel.isHidden = false
        btnDone.isHidden = false

        return true
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
