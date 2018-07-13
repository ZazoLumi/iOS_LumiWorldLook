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
class AdvertiseVC: UIViewController,UITableViewDelegate,UITableViewDataSource {

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
    
    func displayAdvertiseContent() {
        var strBaseDataLogo : String? = ""
      let objLumineer = GlobalShareData.sharedGlobal.objCurrentLumineer
        self.lblLumineerName.text = objLumineer?.displayName

        strBaseDataLogo = objLumineer?.enterpriseLogo
        let imgThumb = UIImage.decodeBase64(strEncodeData:strBaseDataLogo)
        self.imgLumineerProfile.image = imgThumb
       // self.lblAdvTitle.text = GlobalShareData.sharedGlobal.objCurrentAdv.contentTitle
//        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
//            
//        }
//        else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
//            
//        }
//        else {
//            
//        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
       // self.view.frame = CGRect(x: 30, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width-60 , height:240);
        displayAdvertiseContent()
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
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "advCommentCell", for: indexPath)
//        var objLumineer : LumineerList!
//        objLumineer = aryLumineers[indexPath.row] as LumineerList
//        cell.textLabel?.text = objLumineer.displayName
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
