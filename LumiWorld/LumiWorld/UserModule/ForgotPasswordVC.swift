//
//  ForgotPasswordVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/20.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    var customview : CustomTableView!
    @IBOutlet weak var viewTblData: UIView!
    override func viewDidLoad() {
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let dict: [Rule] = [RequiredRule(), PhoneNumberRule()]
        
         customview = CustomTableView(placeholders: [["Mobile Number"]], texts: [[""]], images:[["Artboard 71xxxhdpi"]], frame:CGRect(x: 0
            , y: 0, width: viewTblData.frame.size.width, height: viewTblData.frame.size.height),rrules:[["rule":dict]],fieldType:[[1]])
        
        viewTblData.addSubview(customview)

    }
    @IBAction func onBtnSignInTapped(_ sender: Any) {
        UIApplication.shared.keyWindow?.rootViewController = ExampleProvider.customIrregularityStyle(delegate: nil)
    }
    
    @IBAction func onBtnResetPasswordTapped(_ sender: Any) {
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

}
