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
class LumiProfileDetails: UIViewController,FormDataDelegate {
    var customview : CustomTableView!

    @IBOutlet weak var txtDisplayName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var btnImgProfilePic: UIButton!
    @IBOutlet weak var viewProfileTbl1: UIView!
    @IBOutlet weak var viewProfileTbl: UIView!
    var strImagePath : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.addBackButtonOnLeft()
        self.navigationItem.title = "MY LUMI PROFILE"
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes

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
        let urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic!)
        Alamofire.request(urlOriginalImage!).responseImage { response in
            debugPrint(response)
            if let image = response.result.value {
                let scalImg = image.af_imageScaled(to: CGSize(width:self.btnImgProfilePic.frame.size.width, height: self.btnImgProfilePic.frame.size.height))
                self.btnImgProfilePic.setImage(scalImg, for: .normal)
            }

        }
    }
    @IBAction func onBtnDoneTapped(_ sender: Any) {
        customview.doneAction()
    }
    @IBAction func onBtnEditTapped(_ sender: Any) {
        if btnImgProfilePic.imageView?.image == nil {
            CameraHandler.shared.showProfileActionSheet(vc: self,withDeletePhoto:false)
            CameraHandler.shared.isFromProfile = true
            CameraHandler.shared.didFinishCapturingImage = { (image, imgUrl) in
                self.strImagePath = (imgUrl?.absoluteString)!
                self.btnImgProfilePic.setImage(image, for: .normal)
            }
        }
    }

    @IBAction func onBtnCancelTapped(_ sender: Any) {
        self.navigationController?.popViewController()
    }
    func processedFormData(formData: Dictionary<String, String>) {
        do {
            var strUser : String  = formData["0"]!
            strUser = strUser.replacingOccurrences(of: "+", with:"")
            let param = ["cell": strUser,"firstName":txtFirstName?.text,"lastName":txtLastName?.text,"displayName":txtDisplayName?.text,"email":txtFirstName?.text]
            let objUserData = UserData()
            objUserData.updateUserProfileData(param: param as [String : AnyObject], filePath: strImagePath) { (objUsr) in
                DispatchQueue.main.async {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
