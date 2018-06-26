//
//  MyLumiProfileVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import Alamofire
import  RealmSwift
import AVKit
import VGPlayer
import SnapKit

class MyLumiProfileVC: UIViewController {
    var player = VGPlayer()
    var url1 : URL?
    var objInviteFriendVC : inviteFriendVC!
    var objSendMessageTo : sendMessageTo!
    var objSuggestACompany : suggestCompany!
    var objsuggestALumineer : suggestALumineer!
    
    @IBOutlet weak var scrlAdvertiseView: UIView!
    @IBOutlet weak var lblFCount: UILabel!
    @IBOutlet weak var lblDCount: UILabel!
    @IBOutlet weak var lblACount: UILabel!
    @IBOutlet weak var lblCCount: UILabel!

    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.title = GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName!.uppercased() + "'S LUMI PROFILE"
        self.url1 = URL(fileURLWithPath: Bundle.main.path(forResource: "LumiWorldWelcom", ofType: "mp4")!)
        playVideo()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        setupProfileData()
        self.player.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        for view in scrlAdvertiseView.subviews {
            view.removeSubviews()
        }
        self.player.pause()
    }
    
    func setupProfileData() {
        GlobalShareData.sharedGlobal.objCurretnVC = self
        lblDisplayName.text = GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName
        let urlOriginalImage : URL!
        if(GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic?.hasUrlPrefix())!
        {
            urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic!)
        }
        else {
            let fileName = GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic?.lastPathComponent
            urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
        }
        Alamofire.request(urlOriginalImage!).responseImage { response in
            debugPrint(response)
            if let image = response.result.value {
                let scalImg = image.af_imageScaled(to: CGSize(width:self.imgProfilePic.frame.size.width, height: self.imgProfilePic.frame.size.height))
                self.imgProfilePic.image = scalImg
            }
        }
        let realm = try! Realm()
       // let count = realm.objects(LumineerList.self).filter("status.@count > 0")
       let follows = realm.objects(LumineerList.self).filter("status == 1")
        self.lblFCount.text = "\(follows.count)"
        let conversation = realm.objects(LumiMessage.self)
        self.lblCCount.text = "\(conversation.count)"
        self.lblACount.text = "0"
        self.lblDCount.text = "0"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
        self.imgProfilePic.addGestureRecognizer(tapGestureRecognizer)
        self.imgProfilePic.isUserInteractionEnabled = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let objLumiProfileDetails = storyBoard.instantiateViewController(withIdentifier: "LumiProfileDetails") as! LumiProfileDetails
        self.navigationController?.pushViewController(objLumiProfileDetails, animated: true)
    }
    @IBAction func onBtnYonOHaveTapped(_ sender: Any) {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objsuggestALumineer = storyBoard.instantiateViewController(withIdentifier: "suggestALumineer") as! suggestALumineer
        self.addChildViewController(self.objsuggestALumineer)
        self.objsuggestALumineer.view.frame = CGRect(x: 30, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width-60 , height:440);
        self.view.addSubview(self.objsuggestALumineer.view)
        self.objsuggestALumineer
            .didMove(toParentViewController: self)
    }
    
    @IBAction func onBtnMessageTapped(_ sender: Any) {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objSendMessageTo = storyBoard.instantiateViewController(withIdentifier: "sendMessageTo") as! sendMessageTo
        self.addChildViewController(self.objSendMessageTo)
        self.objSendMessageTo.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-230)/2, width:self.view.frame.size.width , height:300);
        self.view.addSubview(self.objSendMessageTo.view)
        self.objSendMessageTo.didMove(toParentViewController: self)

    }
    @IBAction func onBtnSuggestLumineerTapped(_ sender: Any) {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objSuggestACompany = storyBoard.instantiateViewController(withIdentifier: "suggestCompany") as! suggestCompany
        self.addChildViewController(self.objSuggestACompany)
        self.objSuggestACompany.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width , height:430);
        self.view.addSubview(self.objSuggestACompany.view)
        self.objSuggestACompany.didMove(toParentViewController: self)

    }
    @IBAction func onBtnInviteFriendsTapped(_ sender: Any) {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objInviteFriendVC = storyBoard.instantiateViewController(withIdentifier: "inviteFriendVC") as! inviteFriendVC
        self.addChildViewController(self.objInviteFriendVC)
        self.objInviteFriendVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:450);
        self.view.addSubview(self.objInviteFriendVC.view)
        self.objInviteFriendVC.didMove(toParentViewController: self)
    }
    private func playVideo() {
        self.player.replaceVideo(url1!)
        scrlAdvertiseView.addSubview(self.player.displayView)
        self.player.play()
        self.player.backgroundMode = .proceed
        self.player.delegate = self
        self.player.displayView.delegate = self
        self.player.displayView.titleLabel.text = ""
        self.player.displayView.snp.makeConstraints { [weak self] (make) in
            guard let strongSelf = scrlAdvertiseView else { return }
            make.top.equalTo(strongSelf.snp.top)
            make.bottom.equalTo(strongSelf.snp.bottom)
            make.left.equalTo(strongSelf.snp.left)
            make.right.equalTo(strongSelf.snp.right)
            //make.height.equalTo(strongSelf.snp.width).multipliedBy(3.0/4.0) // you can 9.0/16.0
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

extension MyLumiProfileVC: VGPlayerDelegate {
    func vgPlayer(_ player: VGPlayer, playerFailed error: VGPlayerError) {
        print(error)
    }
    func vgPlayer(_ player: VGPlayer, stateDidChange state: VGPlayerState) {
        print("player State ",state)
    }
    func vgPlayer(_ player: VGPlayer, bufferStateDidChange state: VGPlayerBufferstate) {
        print("buffer State", state)
    }
    
}

extension MyLumiProfileVC: VGPlayerViewDelegate {
    
    func vgPlayerView(_ playerView: VGPlayerView, willFullscreen fullscreen: Bool) {
        
    }
    func vgPlayerView(didTappedClose playerView: VGPlayerView) {
        if playerView.isFullScreen {
           // playerView.exitFullscreen()
        } else {
          //  self.navigationController?.popViewController(animated: true)
        }
        
    }
    func vgPlayerView(didDisplayControl playerView: VGPlayerView) {
      //  UIApplication.shared.setStatusBarHidden(!playerView.isDisplayControl, with: .fade)
    }
}
