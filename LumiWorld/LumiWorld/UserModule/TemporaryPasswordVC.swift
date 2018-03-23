//
//  TemporaryPasswordVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/20.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class TemporaryPasswordVC: UIViewController,FormDataDelegate {
    var customview : CustomTableView!
    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        let dict1: [Rule] = [RequiredRule(), PasswordRule()]
        
         customview = CustomTableView(placeholders: [["Mobile Number","Code"]], texts: [["",""]], images:[["Artboard 71xxxhdpi","Artboard 72xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict1],["rule":dict]],fieldType:[[1,6]])
        customview.formDelegate = self
        viewTblData.addSubview(customview)

    }
    @IBAction func onBtnSignInTapped(_ sender: Any) {
        customview.doneAction()
    }
    
    @IBAction func onBtnResendCodeTapped(_ sender: Any) {
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
        
    }

}
