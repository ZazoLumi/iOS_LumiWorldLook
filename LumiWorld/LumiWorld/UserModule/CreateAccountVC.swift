//
//  CreateAccountVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/20.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class CreateAccountVC: UIViewController {
    @IBOutlet weak var btnTermsAndCondition: UIButton!
    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), FullNameRule()]
        let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
        let dict2: [Rule] = [RequiredRule(), MinLengthRule()]
        let dict3: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict4: [Rule] = [RequiredRule(), PasswordRule()]
        let dict5: [Rule] = [RequiredRule(), PasswordRule()]
        
        let customview = CustomTableView(placeholders: [["Name","Surname","My Lumi Profile Name","Mobile Number","Password","Repeat New Password"]], texts: [["","","","","",""]], images:[["Artboard 70xxxhdpi","Artboard 70xxxhdpi","Artboard 70xxxhdpi","Artboard 71xxxhdpi","Artboard 72xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict],["rule":dict1],["rule":dict2],["rule":dict3],["rule":dict4],["rule":dict5]])
        viewTblData.addSubview(customview)
        
    }

    @IBAction func onBtnTermAndConditionTapped(_ sender: Any) {
        btnTermsAndCondition.isSelected  ? (btnTermsAndCondition.isSelected = false) : (btnTermsAndCondition.isSelected = true)
        
    }
    @IBAction func onBtnChangePasswordTapped(_ sender: Any) {
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
    
}
