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


class MyLumiProfileVC: UIViewController {
    var url1 : URL?
    var objInviteFriendVC : inviteFriendVC!
    var objSendMessageTo : sendMessageTo!
    var objSuggestACompany : suggestCompany!
    var objsuggestALumineer : suggestALumineer!
    var objAdvertiseVC : AdvertiseVC!

    
    @IBOutlet weak var scrollable: ScrollableStackView!
    
    var numberOfPages = 0
    var currentPage = 0
    var aryAdsData : [[String:AnyObject]] = []
    @IBOutlet weak var scrlAdvertiseView: ScrollableStackView!
    @IBOutlet weak var lblFCount: UILabel!
    @IBOutlet weak var lblDCount: UILabel!
    @IBOutlet weak var lblACount: UILabel!
    @IBOutlet weak var lblCCount: UILabel!
    var timerScroll : Timer!
    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    var playerView: AGVideoPlayerView! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.title = GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName!.uppercased() + "'S LUMI PROFILE"
        self.url1 = URL(fileURLWithPath: Bundle.main.path(forResource: "LumiWorldWelcom", ofType: "mp4")!)
        // Do any additional setup after loading the view.
        setupBottomScrollableUI()

        //playVideo()

    }
    override func viewWillAppear(_ animated: Bool) {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        setupProfileData()
        //playerView.playerController.player?.play()
        //        let value = UIInterfaceOrientation.portrait.rawValue
//        UIDevice.current.setValue(value, forKey: "orientation")
        setupAdsScrollableUI()

    }
    override func viewDidAppear(_ animated: Bool) {

    }
    override func viewWillDisappear(_ animated: Bool) {
        clearScrollContent()
        playerView.showsCustomControls = false
        //playerView.playerController.player?.pause()
       // playerView.isMuted = true //Mute the video.
    }
    
    func setupProfileData() {
        GlobalShareData.sharedGlobal.objCurretnVC = self
        lblDisplayName.text = GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName
        let urlOriginalImage : URL!
        if GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic != nil {
        if(GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic?.hasUrlPrefix())! {
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
    func onBtnYonOHaveTapped() {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objsuggestALumineer = storyBoard.instantiateViewController(withIdentifier: "suggestALumineer") as! suggestALumineer
        self.addChildViewController(self.objsuggestALumineer)
        self.objsuggestALumineer.view.frame = CGRect(x: 30, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width-60 , height:440);
        self.view.addSubview(self.objsuggestALumineer.view)
        self.objsuggestALumineer
            .didMove(toParentViewController: self)
    }
    func onBtnShowSaveAdsTapped() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let objFaqVC = storyBoard.instantiateViewController(withIdentifier: "SavedAds") as! SavedAds
        GlobalShareData.sharedGlobal.objCurretnVC.navigationController?.pushViewController(objFaqVC, animated: true)
    }

    
     func onBtnMessageTapped() {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objSendMessageTo = storyBoard.instantiateViewController(withIdentifier: "sendMessageTo") as! sendMessageTo
        self.addChildViewController(self.objSendMessageTo)
        self.objSendMessageTo.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-230)/2, width:self.view.frame.size.width , height:300);
        self.view.addSubview(self.objSendMessageTo.view)
        self.objSendMessageTo.didMove(toParentViewController: self)

    }
     func onBtnSuggestLumineerTapped() {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objSuggestACompany = storyBoard.instantiateViewController(withIdentifier: "suggestCompany") as! suggestCompany
        self.addChildViewController(self.objSuggestACompany)
        self.objSuggestACompany.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width , height:430);
        self.view.addSubview(self.objSuggestACompany.view)
        self.objSuggestACompany.didMove(toParentViewController: self)

    }
     func onBtnInviteFriendsTapped() {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objInviteFriendVC = storyBoard.instantiateViewController(withIdentifier: "inviteFriendVC") as! inviteFriendVC
        self.addChildViewController(self.objInviteFriendVC)
        self.objInviteFriendVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:450);
        self.view.addSubview(self.objInviteFriendVC.view)
        self.objInviteFriendVC.didMove(toParentViewController: self)
    }
    
    func setupBottomScrollableUI() {
        scrollable.stackView.distribution = .fillEqually
        scrollable.stackView.alignment = .center
        scrollable.stackView.axis = .horizontal
        scrollable.stackView.spacing = 22
        scrollable.scrollView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        let imgArray = ["Asset 19","Asset 20","Asset 21","Asset 22","Asset 20"]
        for i in 0 ..< 5 {
            let image = UIImage.init(named: imgArray[i])
            let button = UIButton.init(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: (image?.size.width)! , height: (image?.size.height)!)
            button.backgroundColor = UIColor.clear
            button.setTitle("", for: .normal)
            button.setImage(image, for: .normal)
            button.tag = 20000 + i
            button.heightAnchor.constraint(equalToConstant: (image?.size.height)!).isActive = true
            button.widthAnchor.constraint(equalToConstant: (image?.size.width)!).isActive = true
            button.addTarget(self, action:#selector(actionBttomMenuTapped(_:)), for: .touchUpInside)
            scrollable.stackView.addArrangedSubview(button)
        }
    }
    
    func setupAdsScrollableUI() {
        scrlAdvertiseView.stackView.distribution = .equalSpacing
        scrlAdvertiseView.stackView.alignment = .top
        scrlAdvertiseView.stackView.axis = .horizontal
        scrlAdvertiseView.stackView.spacing = 12
        scrlAdvertiseView.scrollView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 0)
        scrlAdvertiseView.scrollView.isPagingEnabled = true
        scrlAdvertiseView.scrollView.delegate = self

        aryAdsData = GlobalShareData.sharedGlobal.getAllAdvertise()
        for i in 0 ..< aryAdsData.count + 1{
            if i == aryAdsData.count {
                let width = CGFloat(aryAdsData.count>0 ? 40 : 20)
                playerView = AGVideoPlayerView.init(frame: CGRect(x: 0, y:0, width: scrlAdvertiseView.frame.size.width, height: scrlAdvertiseView.frame.size.height))
                playerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width-width).isActive = true
                playerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height-240).isActive = true
                playerView.videoUrl = url1!
                playerView.shouldAutoplay = true
                playerView.shouldAutoRepeat = true
                playerView.showsCustomControls = false
                playerView.shouldSwitchToFullscreen = false
                playerView.isMuted = true
                scrlAdvertiseView.stackView.addArrangedSubview(playerView)
                playerView.translatesAutoresizingMaskIntoConstraints = false

            }
            else {
            let objectData = aryAdsData[i]
            let customAdsView = CustomAds.init(frame: CGRect(x: 0, y: 0, width: 280 , height: UIScreen.main.bounds.size.height))
            customAdsView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width-40).isActive = true
            customAdsView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.height-240).isActive = true
            customAdsView.translatesAutoresizingMaskIntoConstraints = true

                customAdsView.tag = 50000 + i
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleAdsViewTap(recognizer:)))
                customAdsView.addGestureRecognizer(tapGestureRecognizer)
                customAdsView.isUserInteractionEnabled = true

            let objAdv = objectData["message"] as? AdvertiseData

            customAdsView.lblLumineerName.text = objectData["title"] as? String
            let strBaseDataLogo = objectData["profileImg"] as? String
            let imgThumb = UIImage.decodeBase64(strEncodeData:strBaseDataLogo)
            customAdsView.imgLumineerProfile.image = imgThumb
            customAdsView.lblAdvTitle.text = objAdv?.contentTitle
            let imgMsgType : UIImage!
            var urlOriginalImage : URL? = nil

            if objAdv?.contentType == "Video" {
                customAdsView.imgPlayIcon.isHidden = false
                if objAdv?.adFilePath != nil {
                    if(objAdv?.adFilePath?.hasUrlPrefix())!
                    {
                        urlOriginalImage = URL.init(string: (objAdv?.adFilePath!)!)
                    }
                    else {
                        var fileName = objAdv?.adFileName?.replacingOccurrences(of: " ", with: "-")
                        _ = fileName?.pathExtension
                        let pathPrefix = fileName?.deletingPathExtension
                        fileName = "\(pathPrefix!).png"
                        urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    }
                }
                imgMsgType = UIImage(named:"Asset102")
            }
            else if objAdv?.contentType == "Audio" {
                customAdsView.imgPlayIcon.isHidden = false
                imgMsgType = UIImage(named:"Asset104")
            }
            else {
                customAdsView.imgPlayIcon.isHidden = true
                if objAdv?.adFilePath != nil {
                    if(objAdv?.adFilePath?.hasUrlPrefix())!
                    {
                        urlOriginalImage = URL.init(string: (objAdv?.adFilePath!)!)
                    }
                    else {
                        let fileName = objAdv?.adFileName?.replacingOccurrences(of: " ", with: "-")
                        urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    }
                }
                imgMsgType = UIImage(named:"Asset106")
            customAdsView.imgAdvType.image = imgMsgType
            
            }
            customAdsView.imgAdsContent.contentMode = .scaleAspectFit
            customAdsView.lblAdvPostedTime.text = Date().getFormattedDate(string: (objAdv?.strAdvertiseDate!)!, formatter: "")
            
            scrlAdvertiseView.stackView.addArrangedSubview(customAdsView)
            if urlOriginalImage != nil {
            Alamofire.request(urlOriginalImage!).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    customAdsView.imgAdsContent.image = image
                }
                }}
            }}

        if aryAdsData.count > 0 {
            numberOfPages = aryAdsData.count + 1
           timerScroll = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(moveToNextPage), userInfo: nil, repeats: true)
            }
    }


    @objc func actionBttomMenuTapped(_ sender: UIButton){
        let tag = sender.tag
        
        if tag == 20000 {
            self.onBtnInviteFriendsTapped()
        }
        else if tag == 20001 {
            self.onBtnSuggestLumineerTapped()
        }
        else if tag == 20002 {
            self.onBtnYonOHaveTapped()
        }
        else if tag == 20003 {
            self.onBtnMessageTapped()
        }
        else if tag == 20004 {
            self.onBtnShowSaveAdsTapped()
        }
    }
    
    func clearScrollContent() {
        for content in scrlAdvertiseView.scrollView.subviews {
            content.removeSubviews()
        }
        if timerScroll != nil {
            timerScroll.invalidate()
        }
        currentPage = 0
        self.scrlAdvertiseView.scrollView.contentOffset = .zero
    }
    
    @objc func moveToNextPage (){
        let pageWidth:CGFloat =  self.scrlAdvertiseView.scrollView.contentSize.width / CGFloat(numberOfPages)

        if currentPage == numberOfPages {
            currentPage = 0
            playerView.playerController.player?.play()
            self.scrlAdvertiseView.scrollView.scrollRectToVisible(CGRect(x:0, y:0, width:pageWidth, height:self.scrlAdvertiseView.scrollView.frame.height), animated: true)
        }
        else {
            let maxWidth:CGFloat = self.scrlAdvertiseView.scrollView.contentSize.width
                var contentOffset:CGFloat = self.scrlAdvertiseView.scrollView.contentOffset.x
                if currentPage % 2 != 0  {
                    contentOffset += 20
                }
            var slideToX = contentOffset + pageWidth
            
            if  contentOffset + pageWidth == maxWidth
            {
                slideToX = 0
            }
            self.scrlAdvertiseView.scrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.scrlAdvertiseView.scrollView.frame.height), animated: true)
                currentPage += 1
//            if currentPage == numberOfPages {
//                GlobalShareData.sharedGlobal.isVideoPlaying = true
//
//            }
//            else {
//                GlobalShareData.sharedGlobal.isVideoPlaying = false
//            }
        }
    }

    @objc func handleAdsViewTap(recognizer : UITapGestureRecognizer)
    {
        var tag = recognizer.view!.tag - 50000
        
        guard tag < aryAdsData.count else {
            return
        }
        let objectData = aryAdsData[tag]
        let objAdv = objectData["message"] as? AdvertiseData
        GlobalShareData.sharedGlobal.isVideoPlaying = false
        GlobalShareData.sharedGlobal.objCurrentAdv = objAdv
        let realm = try! Realm()
        let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objAdv?.lumineerId.int ?? Int.self)
        if objsLumineer.count > 0 {
            let lumineer = objsLumineer[0]
            GlobalShareData.sharedGlobal.objCurrentLumineer = lumineer
        }
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objAdvertiseVC = storyBoard.instantiateViewController(withIdentifier: "AdvertiseVC") as! AdvertiseVC
        self.addChildViewController(self.objAdvertiseVC)
        self.objAdvertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:390);
        self.view.addSubview(self.objAdvertiseVC.view)
        self.objAdvertiseVC
            .didMove(toParentViewController: self)

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

extension MyLumiProfileVC: UIScrollViewDelegate {
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        var contentOffset:CGFloat = self.scrlAdvertiseView.scrollView.contentOffset.x
//        currentPage = Int(contentOffset / CGFloat(numberOfPages))
//    }
}
