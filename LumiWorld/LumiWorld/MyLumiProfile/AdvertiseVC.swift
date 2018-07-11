//
//  AdvertiseVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/07/11.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
class advCommentCell: UITableViewCell {
    @IBOutlet var imgLumineerProfile: UIImageView!
    @IBOutlet var lblLumineerTitle: UILabel!
    @IBOutlet var lblMessageDetails: UILabel!
    @IBOutlet var lblMessageTime: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        //        self.imgLumineerProfile.layer.cornerRadius = self.imgLumineerProfile.bounds.size.height/2
        //        self.imgLumineerProfile.layer.borderWidth = 0.5;
        //        self.imgLumineerProfile.layer.borderColor = UIColor.lumiGreen?.cgColor;
    }
}
class AdvertiseVC: UIViewController {

    @IBOutlet weak var tblCommentData: UITableView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var viewAddiotionalOperation: UIView!
    @IBOutlet weak var constFileProgressHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFileProgress: UIView!
    @IBOutlet weak var lblFileDuration: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var fileProgressSlider: TNSlider!
    @IBOutlet weak var lblAdvTimerSeconds: UILabel!
    @IBOutlet weak var viewAdvTimer: UIView!
    @IBOutlet weak var viewAdvContent: UIView!
    @IBOutlet weak var lblAdvTitle: UILabel!
    @IBOutlet weak var imgAdvType: UIImageView!
    @IBOutlet weak var lblLumineerName: UILabel!
    @IBOutlet weak var imgLumineerProfile: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onBtnCommentsTapped(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onBtnFullScreenTapped(_ sender: Any) {
    }
    @IBAction func onBtnSaveFileTapped(_ sender: Any) {
    }
    @IBAction func onBtnReportTapped(_ sender: Any) {
    }
    @IBAction func onBtnShareTapped(_ sender: Any) {
    }
    @IBAction func onBtnLikeTapped(_ sender: Any) {
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
