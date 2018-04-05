//
//  LumineerProfileVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/04/05.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class LumineerProfileVC: UIViewController,ExpandableLabelDelegate {

    @IBOutlet weak var lblExpandableDescription: ExpandableLabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnInboxCount: UIButton!
    @IBOutlet weak var lblFollowers: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblExpandableDescription.delegate = self
        lblExpandableDescription.setLessLinkWith(lessLink: "Close", attributes: [.foregroundColor:UIColor.red], position: .left)
        
        lblExpandableDescription.shouldCollapse = true
        lblExpandableDescription.textReplacementType = .word
        lblExpandableDescription.numberOfLines = 2
        lblExpandableDescription.text = "On third line our text need be collapsed because we have ordinary text, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."

        // Do any additional setup after loading the view.
    }
    
    //
    // MARK: ExpandableLabel Delegate
    //
    
    func willExpandLabel(_ label: ExpandableLabel) {
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = true
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = false
        lblExpandableDescription.numberOfLines = 2

    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = true
        lblExpandableDescription.numberOfLines = 2

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBtnFacebookTapped(_ sender: Any) {
    }
    
    @IBAction func onBtnTwitterTapped(_ sender: Any) {
    }
    @IBAction func onBtnInstagramTapped(_ sender: Any) {
    }
    @IBAction func onBtnLinkedInTapped(_ sender: Any) {
    }
    @IBAction func onBtnPhoneCallTapped(_ sender: Any) {
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
