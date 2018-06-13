//
//  inviteFriendVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/06/06.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MBProgressHUD
import RealmSwift
import ActionSheetPicker_3_0
class suggestLumineerCell: UITableViewCell {
    @IBOutlet weak var btnAddLumineer: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        btnAddLumineer.layer.cornerRadius = btnAddLumineer.bounds.size.height/2
//        btnAddLumineer.layer.borderWidth = 0.5;
//        btnAddLumineer.layer.borderColor = UIColor.lumiGreen?.cgColor;
    }
}
class suggestALumineer: UIViewController,FormDataDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var btnSubmit: UIButton!
    var customview : CustomTableView!
    @IBOutlet weak var lumineerDataHeight: NSLayoutConstraint!
    @IBOutlet weak var tblLumineerData: UITableView!
    @IBOutlet weak var viewTblData: UIView!
    @IBOutlet weak var lblUserName : UILabel!
    var pickerView : UIPickerView!
    var arySelectedLumineer : [[String: String]] = [[:]]
    var aryLumineers : [String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
       // self.tblLumineerData.register(addLumineerCell.self, forCellReuseIdentifier: "addLumineerCell")
        lblUserName.text = "Hi \(GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!)"
        getAllLuminners()
        self.btnSubmit.isEnabled = false
        self.tblLumineerData!.tableFooterView = UIView()
        arySelectedLumineer = [["key":"1","value":"","isSelected":"false"],["key":"2","value":"","isSelected":"false"]]
        self.tblLumineerData.reloadData()
        lumineerDataHeight.constant = 76
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        if !GlobalShareData.sharedGlobal.isContactPicked {
            let dict: [Rule] = [RequiredRule(), MinLengthRule()]
            let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
            let dict2: [Rule] = [RequiredRule(), PhoneNumberRule()]
            customview = CustomTableView(placeholders: [["Name","Surname","Mobile Number"]], texts: [["","",""]], images:[["Artboard 70xxxhdpi","Artboard 70xxxhdpi","Artboard 71xxxhdpi"]], frame:CGRect(x: 0
                , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1],["rule":dict2]],fieldType:[[4,5,1]])
            customview.formDelegate = self
            customview.isFromProfile = true
            viewTblData.addSubview(customview)
        }
        GlobalShareData.sharedGlobal.isContactPicked = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
       // customview.isFromProfile = false
    }
    func showAnimate() {
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
            var strUserMobile : String  = formData["2"]!
            strUserMobile = strUserMobile.replacingOccurrences(of: "+", with:"")
            
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
            var strLumineerNames = ""
            for dict in arySelectedLumineer {
                if (dict["value"]?.count)! > 0 {
                    if strLumineerNames.count > 0{
                        strLumineerNames.append(", ")
                    }
                    strLumineerNames.append(dict["value"]!)
                }
            }
            let param = ["lumiFirstName": GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName,"lumiLastName": GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName, "lumiMobile":GlobalShareData.sharedGlobal.objCurrentUserDetails.cell,"lumineerNames":strLumineerNames,"lumiOrFrenFirstName":strUserName,"lumiOrFrenLastName":strUserSurname,"lumiOrFrenMobile":strUserMobile,"inviteMessage":""]
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISuggestALumineer)"
            
            let paramCreateRelationship = ["requestDtls":jsonString!, "url":urlString,"filePath":"","fileName":""]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(paramCreateRelationship, withCompletionBlock: { (dict, error) in
                    DispatchQueue.main.async {

                    MBProgressHUD.hide(for: (self.navigationController?.view)!, animated: true)

                    guard dict?.count != 0 else {
                        return
                    }
                    
                    let strResponseCode = dict!["responseCode"] as! Int
                    guard strResponseCode != 0 else {
                        DispatchQueue.main.async {
                            let message = dict!["response"] as! String
                            self.navigationController?.showCustomAlert(strTitle: "", strDetails: message, completion: { (str) in
                            })
                        }
                        return
                    }

                    self.navigationController?.showCustomAlert(strTitle: self.lblUserName.text!, strDetails: "Thank you  for suggesting Lumi World to \(strUserName) \n We will be contacting \(strUserName) shortly. \n Team Lumi World", completion: { (str) in
                        self.onBtnClosePopupTapped((Any).self)
                    }) }

                })
            } catch let jsonError {
                print(jsonError)
            }

            
        } catch let jsonError{
            print(jsonError)
            
        }
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 38
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arySelectedLumineer.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestLumineerCell", for: indexPath) as! suggestLumineerCell
        cell.btnAddLumineer.tag = indexPath.row + 100
        if arySelectedLumineer.count == 3 && arySelectedLumineer.count-1 == indexPath.row && (arySelectedLumineer[indexPath.row-1]["value"]?.count)! > 0 {
            cell.btnAddLumineer.isEnabled = true
            cell.btnAddLumineer.addTarget(self, action: #selector(btnTapAddLumineer(_:)), for: .touchUpInside)
            if (arySelectedLumineer[indexPath.row]["value"]?.count)! > 0 {
                cell.btnAddLumineer.setTitle(arySelectedLumineer[indexPath.row]["value"], for: .normal)
                cell.btnAddLumineer.setImage(UIImage.init(), for: .normal)
            }
        }
       else if arySelectedLumineer.count == 2 && arySelectedLumineer.count-1 == indexPath.row && (arySelectedLumineer[indexPath.row-1]["value"]?.count)! > 0 {
            cell.btnAddLumineer.isEnabled = true
            cell.btnAddLumineer.addTarget(self, action: #selector(btnTapAddLumineer(_:)), for: .touchUpInside)
            if (arySelectedLumineer[indexPath.row]["value"]?.count)! > 0 {
                cell.btnAddLumineer.setTitle(arySelectedLumineer[indexPath.row]["value"], for: .normal)
                cell.btnAddLumineer.setImage(UIImage.init(), for: .normal)
            }
        }
        else if arySelectedLumineer.count-1 == indexPath.row {
            cell.btnAddLumineer.isEnabled = false
        }
        else {
            cell.btnAddLumineer.isEnabled = true
            cell.btnAddLumineer.addTarget(self, action: #selector(btnTapAddLumineer(_:)), for: .touchUpInside)
            if (arySelectedLumineer[indexPath.row]["value"]?.count)! > 0 {
                cell.btnAddLumineer.setTitle(arySelectedLumineer[indexPath.row]["value"], for: .normal)
                cell.btnAddLumineer.setImage(UIImage.init(), for: .normal)
            }
        }
        return cell
    }
    @objc func btnTapAddLumineer(_ sender: UIButton) {
        let cellIndex = sender.tag-100
        ActionSheetStringPicker.show(withTitle: "Select Lumineers", rows: aryLumineers, initialSelection: 0, doneBlock: { (picker, index,sender) in
            self.arySelectedLumineer[cellIndex]["value"] = self.aryLumineers[index]
            if self.arySelectedLumineer.count == 2 {
                self.arySelectedLumineer.append(["key":"3","value":"","isSelected":"false"])
                self.lumineerDataHeight.constant = 114
            }
            if (self.arySelectedLumineer[0]["value"]?.count)! > 0 {
                self.btnSubmit.isEnabled = true
            }
            self.tblLumineerData.reloadData()
        }, cancel: { (picker) in
            
        }, origin: sender)

    }
    func getAllLuminners() {
        aryLumineers = []
        let realm = try! Realm()
        let realmObjects = realm.objects(LumiCategory.self)
        if realmObjects.count > 0 {
            for objCategory in realmObjects{
                for lumineer in objCategory.lumineerList {
                    let  objLumineer = lumineer as LumineerList
                    aryLumineers.append(objLumineer.displayName!)
                }
            }
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
