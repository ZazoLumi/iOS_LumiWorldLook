//
//  AdvertiseVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/07/11.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import AVKit
import TNSlider
import Alamofire
import MBProgressHUD
import IQKeyboardManagerSwift
import RealmSwift

enum ScreenType {
    case Advertise
    case Content
}


class advCommentCell: UITableViewCell {
    @IBOutlet var imgLumineerProfile: UIImageView!
    @IBOutlet var lblLumineerTitle: UILabel!
    @IBOutlet var lblMessageDetails: UILabel!
    @IBOutlet var lblMessageTime: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
                self.imgLumineerProfile.layer.cornerRadius = self.imgLumineerProfile.bounds.size.height/2
                self.imgLumineerProfile.layer.borderWidth = 0.5;
                self.imgLumineerProfile.layer.borderColor = UIColor.lumiGreen?.cgColor;
    }
}
class AdvertiseVC: UIViewController,UITableViewDelegate,UITableViewDataSource,TNSliderDelegate,UITextViewDelegate {
    
    @IBOutlet weak var constTopViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var constAdsOperationHeight: NSLayoutConstraint!
    @IBOutlet weak var viewTopItems: UIView!
    var inputTV: UITextView!
      var bottomView: UIView!
    
    @IBOutlet weak var tblCommentData: UITableView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var viewAddiotionalOperation: UIView!
    @IBOutlet weak var constFileProgressHeight: NSLayoutConstraint!
    @IBOutlet weak var constCommentsHeight: NSLayoutConstraint!

    @IBOutlet weak var constAdvContainerHeight: NSLayoutConstraint!
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
    var aryCommentsData : Result<AdvComments>!
    var nhours : String = "00"
    var nminutes : String = "00"
    var nseconds : String = "00"
    var seconds = 5
    var timer = Timer()
    let h = UIScreen.main.bounds.height
    let w = UIScreen.main.bounds.width
    var submitButton : UIButton!
    var mediaZoom: MediaZoom?

    @IBOutlet weak var btnCloseAdv: UIButton!
    
    var screenType : ScreenType = .Advertise

    //var player:AVPlayer?
   // var playerItem:AVPlayerItem?
    //fileprivate var player = Player()
    var playerView: AGVideoPlayerView!
    let timeFormatter = NumberFormatter()
    
    var audioPlayer: AVAudioPlayer?     // holds an audio player instance. This is an optional!
    var audioTimer: Timer?            // holds a timer instance
    var isDraggingTimeSlider = false    // Keep track of when the time slide is being dragged
    
    var isPlaying = false {             // keep track of when the player is playing
        didSet {                        // This is a computed property. Changing the value
            playPauseAudio()
        }
    }
    fileprivate var documentInteractionController = UIDocumentInteractionController()

    deinit {
        //self.playerView.removeFromSuperview()
    }

    func canRotate() -> Void {}

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dimAlphaRedColor =  UIColor.lumiGreen?.withAlphaComponent(0.5)
        viewAdvTimer.backgroundColor =  dimAlphaRedColor
        setupInitialConstraints()
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")

        
    }
    var keyboardHeight = 0
    @objc func keyboardWillShow(_ n: Notification?) {
        if let keyboardSize = (n?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = Int(keyboardSize.height)
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
            print(keyboardHeight)
            textViewDidChange(inputTV)
        }
    }
    @objc func keyboardWillHide(_ n: Notification?) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
            self.bottomView.frame = CGRect(x: 0, y:Int(Int(self.h) + 44), width:Int(self.w), height: Int(44))
            self.inputTV.frame = CGRect(x: 10, y: 0, width:Int( self.w - 64), height: 44)
            self.submitButton.frame = CGRect(x: Int(self.w - 60), y: Int(0), width: 60, height: 44)

        }) { finished in
            //default disable scroll here to avoid bouncing
        }

    }

    func textViewDidChange(_ textView: UITextView) {
        //1. letters and submit button vars
        //3. set height vars
        inputTV.isScrollEnabled = true
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.bottomView.frame = CGRect(x: 0, y:Int(Int(self.h) - self.keyboardHeight), width:Int(self.w), height: Int(44))
            self.inputTV.frame = CGRect(x: 10, y: 18, width:Int( self.w - 64), height: 34)
            self.submitButton.frame = CGRect(x: Int(self.w - 60), y: Int(18), width: 60, height: 34)

        }) { finished in
            //default disable scroll here to avoid bouncing
        }
    }
    @objc func onBtnSendComments(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = NSLocalizedString("Sending...", comment: "HUD loading title")
        if screenType == .Advertise {

        let objAdvData = AdvertiseData()
        let dictDetails = ["lumineerId":GlobalShareData.sharedGlobal.objCurrentLumineer.id as AnyObject,"comments":inputTV.text as AnyObject,"lumiMobile":GlobalShareData.sharedGlobal.userCellNumber as AnyObject,"advertiseId":GlobalShareData.sharedGlobal.objCurrentAdv.advertiseId as AnyObject]
        if btnComments.isSelected {
            objAdvData.sendAdvertiseComments(param: dictDetails) { (success) in
                if success {
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        self.inputTV.text = ""
                        self.inputTV.resignFirstResponder()
                        self.tblCommentData.reloadData()
                        if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count > 0 {
                            let count = GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count
                            self.btnComments.setTitle("\(count) Comments", for: .normal)
                            self.btnComments.setTitle("\(count) Comments", for: .selected)
                        }
                        if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count > 1 {
                            self.tblCommentData.contentOffset = .zero}
                        self.setupInitialConstraints()
                    }
                }
            }
        }
        else if btnReport.isSelected {
            objAdvData.sendAdvertiseReports(param: dictDetails) { (success) in
                if success {
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        let hudNew = MBProgressHUD.showAdded(to: self.view!, animated: true)
                        hudNew.mode = .text
                        hudNew.label.text = NSLocalizedString("AdReport is posted successfully.", comment: "HUD message title")
                        hudNew.label.font = UIFont.init(name: "HelveticaNeue", size: 14)
                        hudNew.offset = CGPoint(x:0, y: UIScreen.main.bounds.height/2)
                        hudNew.hide(animated: true, afterDelay: 3.0)
                        self.inputTV.text = ""
                        self.inputTV.resignFirstResponder()
                    }
                }
            }
        }
        }
        else {
            
        }
        btnReport.isSelected = false
        btnComments.isSelected = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        inputTV.text = ""
        inputTV.resignFirstResponder()
        btnReport.isSelected = false
        btnComments.isSelected = false
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        
    }
    
    func displayAdvertiseContent() {
        var strBaseDataLogo : String? = ""
      let objLumineer = GlobalShareData.sharedGlobal.objCurrentLumineer
        self.lblLumineerName.text = objLumineer?.displayName
        self.tblCommentData!.tableFooterView = UIView()
        strBaseDataLogo = objLumineer?.enterpriseLogo
        let imgThumb = UIImage.decodeBase64(strEncodeData:strBaseDataLogo)
        self.imgLumineerProfile.image = imgThumb
        if screenType == .Advertise {
            self.lblAdvTitle.text = GlobalShareData.sharedGlobal.objCurrentAdv.contentTitle
            if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count > 0 {
                let count = GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count
                btnComments.setTitle("\(count) Comments", for: .normal)
                btnComments.setTitle("\(count) Comments", for: .selected)
            }
            let count = Int(GlobalShareData.sharedGlobal.objCurrentAdv.likeCount)
            btnLike.setTitle("\(count)", for: .normal)
            btnLike.setTitle("\(count)", for: .selected)
            if GlobalShareData.sharedGlobal.objCurrentAdv.isAdsLiked {
                btnLike.isSelected = true
            }
            
            if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
                self.imgAdvType.image = UIImage(named:"Asset106")
                var imageView : UIImageView
                imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width:Int(self.view.frame.size.width), height:Int(self.viewAdvContent.frame.size.height)));
                self.viewAdvContent.addSubview(imageView)
                imageView.contentMode = .scaleAspectFit
                let urlOriginalImage : URL!
                if GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath != nil {
                    if(GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath?.hasUrlPrefix())!
                    {
                        urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath!)
                    }
                    else {
                        let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName?.replacingOccurrences(of: " ", with: "-")
                        urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    }
                    Alamofire.request(urlOriginalImage).responseImage { response in
                        debugPrint(response)
                        if let image = response.result.value {
                            let scalImg = image.af_imageAspectScaled(toFill: CGSize(width:imageView.frame.size.width, height: imageView.frame.size.height))
                            imageView.image = scalImg
                            self.mediaZoom = MediaZoom(with: imageView, animationTime: 0.5, useBlur: true)
                            self.runTimer()
                            self.viewAdvContent.bringSubview(toFront: self.viewAdvTimer)
                        }
                    }
                }
            }
            else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
                self.imgAdvType.image = UIImage(named:"Asset102")
                GlobalShareData.sharedGlobal.isVideoPlaying = true
                let urlOriginalImage : URL!
                if GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath != nil {
                    if(GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath?.hasUrlPrefix())!
                    {
                        urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath!)
                    }
                    else {
                        let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName?.replacingOccurrences(of: " ", with: "-")
                        urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    }
                    self.viewAdvContent.bringSubview(toFront: self.viewAdvTimer)
                    
                    /*self.player.playerDelegate = self
                     self.player.playbackDelegate = self
                     self.player.view.frame = CGRect(x: 0, y: 0, width:Int(self.view.frame.size.width), height:Int(self.viewAdvContent.frame.size.height));
                     
                     // self.addChildViewController(self.player)
                     self.viewAdvContent.addSubview(self.player.view)
                     self.player.didMove(toParentViewController: self)
                     
                     self.player.url = urlOriginalImage
                     
                     self.player.playbackLoops = true
                     
                     self.player.fillMode = PlayerFillMode.resizeAspectFit.avFoundationType*/
                    playerView = AGVideoPlayerView.init(frame: CGRect(x: 0, y: 0, width:Int(self.view.frame.size.width), height:Int(self.viewAdvContent.frame.size.height)))
                    playerView.playbackDelegate = self;
                    playerView.videoUrl = urlOriginalImage!
                    playerView.shouldAutoplay = true
                    playerView.shouldAutoRepeat = true
                    playerView.showsCustomControls = false
                    playerView.shouldSwitchToFullscreen = false
                    self.viewAdvContent.addSubview(self.playerView)
                    playerView.translatesAutoresizingMaskIntoConstraints = false
                    let attributes: [NSLayoutAttribute] = [.top, .bottom, .right, .left]
                    NSLayoutConstraint.activate(attributes.map {
                        NSLayoutConstraint(item: playerView, attribute: $0, relatedBy: .equal, toItem: playerView.superview, attribute: $0, multiplier: 1, constant: 0)
                    })
                    
                }
                
            }
            else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
                self.imgAdvType.image = UIImage(named:"Asset104")
                timeFormatter.minimumIntegerDigits = 2
                timeFormatter.minimumFractionDigits = 0
                timeFormatter.roundingMode = .down
                
                // Load the sound and set up the timer.
                
                queueSound()
                makeTimer()
                self.runTimer()
                isPlaying = true
                audioPlayer?.play()
            }

        }
        else {
                self.lblAdvTitle.text = GlobalShareData.sharedGlobal.objCurrentContent.contentTitle
            if GlobalShareData.sharedGlobal.objCurrentContent.ctnComments.count > 0 {
                    let count = GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count
                    btnComments.setTitle("\(count) Comments", for: .normal)
                    btnComments.setTitle("\(count) Comments", for: .selected)
                }
                let count = Int(GlobalShareData.sharedGlobal.objCurrentContent.likeCount)
                btnLike.setTitle("\(count)", for: .normal)
                btnLike.setTitle("\(count)", for: .selected)
                if GlobalShareData.sharedGlobal.objCurrentContent.isCtsLiked {
                    btnLike.isSelected = true
                }
                
                if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "image" {
                    self.imgAdvType.image = UIImage(named:"Asset106")
                    var imageView : UIImageView
                    imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width:Int(self.view.frame.size.width), height:Int(self.viewAdvContent.frame.size.height)));
                    self.viewAdvContent.addSubview(imageView)
                    imageView.contentMode = .scaleAspectFit
                    let urlOriginalImage : URL!
                    if GlobalShareData.sharedGlobal.objCurrentContent.adMediaURL != nil {
                        if(GlobalShareData.sharedGlobal.objCurrentContent.adMediaURL?.hasUrlPrefix())!
                        {
                            urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentContent.adMediaURL!)
                        }
                        else {
                            let fileName = GlobalShareData.sharedGlobal.objCurrentContent.contentFileName?.replacingOccurrences(of: " ", with: "-")
                            urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                        }
                        Alamofire.request(urlOriginalImage).responseImage { response in
                            debugPrint(response)
                            if let image = response.result.value {
                                let scalImg = image.af_imageAspectScaled(toFill: CGSize(width:imageView.frame.size.width, height: imageView.frame.size.height))
                                imageView.image = scalImg
                                self.mediaZoom = MediaZoom(with: imageView, animationTime: 0.5, useBlur: true)
                                self.runTimer()
                                self.viewAdvContent.bringSubview(toFront: self.viewAdvTimer)
                            }
                        }
                    }
                }
                else if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "video" {
                    self.imgAdvType.image = UIImage(named:"Asset102")
                    GlobalShareData.sharedGlobal.isVideoPlaying = true
                    let urlOriginalImage : URL!
                    if GlobalShareData.sharedGlobal.objCurrentContent.adMediaURL != nil {
                        if(GlobalShareData.sharedGlobal.objCurrentContent.adMediaURL?.hasUrlPrefix())!
                        {
                            urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentContent.adMediaURL!)
                        }
                        else {
                            let fileName = GlobalShareData.sharedGlobal.objCurrentContent.contentFileName?.replacingOccurrences(of: " ", with: "-")
                            urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                        }
                        self.viewAdvContent.bringSubview(toFront: self.viewAdvTimer)
                        
                        /*self.player.playerDelegate = self
                         self.player.playbackDelegate = self
                         self.player.view.frame = CGRect(x: 0, y: 0, width:Int(self.view.frame.size.width), height:Int(self.viewAdvContent.frame.size.height));
                         
                         // self.addChildViewController(self.player)
                         self.viewAdvContent.addSubview(self.player.view)
                         self.player.didMove(toParentViewController: self)
                         
                         self.player.url = urlOriginalImage
                         
                         self.player.playbackLoops = true
                         
                         self.player.fillMode = PlayerFillMode.resizeAspectFit.avFoundationType*/
                        playerView = AGVideoPlayerView.init(frame: CGRect(x: 0, y: 0, width:Int(self.view.frame.size.width), height:Int(self.viewAdvContent.frame.size.height)))
                        playerView.playbackDelegate = self;
                        playerView.videoUrl = urlOriginalImage!
                        playerView.shouldAutoplay = true
                        playerView.shouldAutoRepeat = true
                        playerView.showsCustomControls = false
                        playerView.shouldSwitchToFullscreen = false
                        self.viewAdvContent.addSubview(self.playerView)
                        playerView.translatesAutoresizingMaskIntoConstraints = false
                        let attributes: [NSLayoutAttribute] = [.top, .bottom, .right, .left]
                        NSLayoutConstraint.activate(attributes.map {
                            NSLayoutConstraint(item: playerView, attribute: $0, relatedBy: .equal, toItem: playerView.superview, attribute: $0, multiplier: 1, constant: 0)
                        })
                        
                    }
                    
                }
                else if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "audio" {
                    self.imgAdvType.image = UIImage(named:"Asset104")
                    timeFormatter.minimumIntegerDigits = 2
                    timeFormatter.minimumFractionDigits = 0
                    timeFormatter.roundingMode = .down
                    
                    // Load the sound and set up the timer.
                    
                    queueSound()
                    makeTimer()
                    self.runTimer()
                    isPlaying = true
                    audioPlayer?.play()
                }
        }
        
    }
    
    func setupInitialConstraints()  {
        var totalHeight = 350
        constCommentsHeight.constant = 0
        viewFileProgress.isHidden = false
        if screenType == .Advertise {
            if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
                constFileProgressHeight.constant = 0
                viewFileProgress.isHidden = true
            }
            else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
                constAdvContainerHeight.constant = 60
                totalHeight -= 160
            }
            if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count > 0 {
                let commentsHeight = (Int(UIScreen.main.bounds.height) - totalHeight - 140)
                var setHeights = commentsHeight
                if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count * 54 < commentsHeight{
                    setHeights = GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count * 54
                }
                constCommentsHeight.constant = CGFloat(setHeights)
                totalHeight += setHeights
            }

        }
        else {
                if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "image" {
                    constFileProgressHeight.constant = 0
                    viewFileProgress.isHidden = true
                }
                else if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "audio" {
                    constAdvContainerHeight.constant = 60
                    totalHeight -= 160
                }
            if GlobalShareData.sharedGlobal.objCurrentContent.ctnComments.count > 0 {
                    let commentsHeight = (Int(UIScreen.main.bounds.height) - totalHeight - 140)
                    var setHeights = commentsHeight
                if GlobalShareData.sharedGlobal.objCurrentContent.ctnComments.count * 54 < commentsHeight{
                    setHeights = GlobalShareData.sharedGlobal.objCurrentContent.ctnComments.count * 54
                    }
                    constCommentsHeight.constant = CGFloat(setHeights)
                    totalHeight += setHeights
                }
                
        }
        setupBottomView()
        let yPos = (Int(UIScreen.main.bounds.height) - totalHeight)/2
        self.view.frame = CGRect(x: 0, y: yPos, width:Int(self.view.frame.size.width), height:totalHeight);
        DispatchQueue.main.async {
            self.tblCommentData.reloadData()}
    }
    func slider(_ slider: TNSlider, displayTextForValue value: Float) -> String {
        let seconds : Int64 = Int64(value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        self.playerView.playerController.player?.seek(to: targetTime) { (result) in
            //todo self.player.playFromCurrentTime()
        }
        return String(format: "%.2f%%", value)
    }
    
    @IBAction func sliderValueChanged(_ playbackSlider: TNSlider) {
        print(playbackSlider.value)
        if screenType == .Advertise {
            if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
                guard let audioPlayer = audioPlayer else {
                    return
                }
                audioPlayer.currentTime = audioPlayer.duration * Double(playbackSlider.value)
            }
        }
        else {
            if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "audio" {
                guard let audioPlayer = audioPlayer else {
                    return
                }
                audioPlayer.currentTime = audioPlayer.duration * Double(playbackSlider.value)
            }

        }
        
    }
    
    @IBAction func playButtonTapped(_ sender:UIButton)
    {
        btnPlayPause.isSelected = !sender.isSelected
        if screenType == .Advertise {
            if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
                if btnPlayPause.isSelected {
                    self.playerView.playerController.player?.pause()
                }else {
                    self.playerView.playerController.player?.play()
                }
            }
            else {
                isPlaying = !isPlaying
                }
            }
        else {
            if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "video" {
                if btnPlayPause.isSelected {
                    self.playerView.playerController.player?.pause()
                }else {
                    self.playerView.playerController.player?.play()
                }
            }
            else {
                isPlaying = !isPlaying
            }

        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if !GlobalShareData.sharedGlobal.isVideoPlaying {
            displayAdvertiseContent() }
    }
    
    @IBAction func onBtnCommentsTapped(_ sender: UIButton) {
        btnComments.isSelected = !sender.isSelected
        btnReport.isSelected = false
        inputTV.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onBtnFullScreenTapped(_ sender: UIButton) {
        if screenType == .Advertise {
            if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
                GlobalShareData.sharedGlobal.objCurretnVC.view.addSubview(mediaZoom!)
                mediaZoom?.show()
            }
            else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
                    NotificationCenter.default.post(name: .playerDidChangeFullscreenMode, object: true)
                    playerView.hanldeOrientation()
                }
        }
        else {
            if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "image" {
                GlobalShareData.sharedGlobal.objCurretnVC.view.addSubview(mediaZoom!)
                mediaZoom?.show()
            }
            else if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "video" {
                NotificationCenter.default.post(name: .playerDidChangeFullscreenMode, object: true)
                playerView.hanldeOrientation()
            }
        }
    }
    
    @IBAction func onBtnSaveFileTapped(_ sender: Any) {
        GlobalShareData.sharedGlobal.saveAdsRecord()
    }
    @IBAction func onBtnReportTapped(_ sender: UIButton) {
        btnReport.isSelected = !sender.isSelected
        btnReport.isSelected = false
        inputTV.becomeFirstResponder()
    }
    @IBAction func onBtnShareTapped(_ sender: Any) {
        let urlOriginalImage : URL!
        if screenType == .Advertise {
            if GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath != nil {
                if(GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath?.hasUrlPrefix())!
                {
                    urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath!)
                }
                else {
                    let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName?.replacingOccurrences(of: " ", with: "-")
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
                documentInteractionController.delegate = self
                documentInteractionController.url = urlOriginalImage
                documentInteractionController.presentPreview(animated: true)
                }
        }
        else {
            
        }
    }
    @IBAction func onBtnLikeTapped(_ sender: UIButton) {
        btnLike.isSelected = !sender.isSelected
        if screenType == .Advertise {

        let objAdvData = AdvertiseData()
        objAdvData.setLikeAdvertiseByLumi(param: ["isLike":sender.isSelected as AnyObject,"lumiMobile":GlobalShareData.sharedGlobal.userCellNumber as AnyObject,"advertiseId":GlobalShareData.sharedGlobal.objCurrentAdv.advertiseId as AnyObject]) { (success) in
            if success {
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    let result = realm.objects(AdvertiseData.self).filter("advertiseId = \(GlobalShareData.sharedGlobal.objCurrentAdv.advertiseId)")
                    if result.count > 0 {
                        var count = Int(GlobalShareData.sharedGlobal.objCurrentAdv.likeCount)
                        try! realm.write {
                            if result[0].isAdsLiked {
                                result[0].isAdsLiked = false
                                GlobalShareData.sharedGlobal.objCurrentAdv.isAdsLiked = false
                                count = count - 1
                                GlobalShareData.sharedGlobal.objCurrentAdv.likeCount -= 1;
                            }else {
                                result[0].isAdsLiked = true
                                count = count + 1
                                GlobalShareData.sharedGlobal.objCurrentAdv.isAdsLiked = true
                                GlobalShareData.sharedGlobal.objCurrentAdv.likeCount += 1;
                            }
                            }
                        self.btnLike.setTitle("\(count)", for: .normal)
                        self.btnLike.setTitle("\(count)", for: .selected)
                    }
                }
            }
        }
        }
        else {
            
        }
    }
    
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if screenType == .Content {
            return 0
        }
            return GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "advCommentCell", for: indexPath) as! advCommentCell
        var objComment : AdvComments!
        if screenType == .Advertise {
            objComment = GlobalShareData.sharedGlobal.objCurrentAdv.advComments[indexPath.row] as AdvComments }
        else {
            
        }
        if objComment.isPostedByLumi {
            let urlOriginalImage : URL!
            if GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic != nil {
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
                        let scalImg = image.af_imageAspectScaled(toFill: CGSize(width:self.imgLumineerProfile.frame.size.width, height: self.imgLumineerProfile.frame.size.height))
                        cell.imgLumineerProfile.image = scalImg
                         cell.imgLumineerProfile?.clipsToBounds = true;
//                        cell.imgLumineerProfile.contentMode = .scaleAspectFit
//                        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
//

                    }
                }
            }
            cell.lblLumineerTitle.text = GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName

        }
        else {
            let objLumineer = GlobalShareData.sharedGlobal.objCurrentLumineer
            cell.lblLumineerTitle.text = objLumineer?.displayName
            let imgThumb = UIImage.decodeBase64(strEncodeData:objLumineer?.enterpriseLogo)
            cell.imgLumineerProfile.image = imgThumb
        }
        cell.lblMessageTime.text = Date().getFormattedDate(string: (objComment?.strCommentPostedDate)!, formatter: "yyyy-MM-dd HH:mm")
        cell.lblMessageDetails.text = objComment?.comments
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func getStringFrom(seconds: Int) -> String {
        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }

    @objc func updateTimer(){
        if seconds < 1 {
            timer.invalidate()
            lblAdvTimerSeconds.isHidden = true
            btnCloseAdv.isHidden = false
            //Send alert to indicate time's up.
        } else {
            seconds -= 1
            if screenType == .Advertise {
                let type = GlobalShareData.sharedGlobal.objCurrentAdv.contentType?.uppercased()
                    lblAdvTimerSeconds.text = "YOU CAN CLOSE THE \(type!) IN \(seconds)"
            }
            else {
                let type = GlobalShareData.sharedGlobal.objCurrentContent.contentType?.uppercased()
                lblAdvTimerSeconds.text = "YOU CAN CLOSE THE \(type!) IN \(seconds)"

            }
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)),
                                     userInfo: nil, repeats: true)
    }

    @IBAction func onBtnCloseAdvertise(_ sender: Any) {
        inputTV.resignFirstResponder()
        self.parent?.view.backgroundColor = UIColor.white
        self.view.superview?.removeBlurEffect()
        removeAnimate()
        GlobalShareData.sharedGlobal.isVideoPlaying = false
        if screenType == .Advertise {
            if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
                audioPlayer?.stop()}
            else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
                self.playerView.playerController.player?.pause()
                }
        }
        else {
            if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "audio" {
                audioPlayer?.stop()}
            else if GlobalShareData.sharedGlobal.objCurrentContent.contentType == "video" {
                self.playerView.playerController.player?.pause()
            }

        }
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
    
    
    func playPauseAudio() {
        // audioPlayer is optional use guard to check it before using it.
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        // Check is playing then play or pause
        if isPlaying {
            audioPlayer.play()
        } else {
            audioPlayer.pause()
        }
    }
    
    
    
    func queueSound() {
        // Use this methid to load up the sound.
        let urlOriginalImage : URL!
        if screenType == .Advertise {
        if GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath != nil {
            if(GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath?.hasUrlPrefix())!
            {
                urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentAdv.adFilePath!)
            }
            else {
                let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName?.replacingOccurrences(of: " ", with: "-")
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
            }
            audioPlayer = try! AVAudioPlayer(contentsOf: urlOriginalImage as URL)
        }
        }
        else {
            
        }

//        let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName
//        let contentURL = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)

        // TODO: Use catch here and check for errors.
    }
    
    
    func makeTimer() {
        // This function sets up the timer.
        if audioTimer != nil {
            audioTimer!.invalidate()
        }
        
        // audioTimer = Timer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.onTimer(_:)), userInfo: nil, repeats: true)
        audioPlayer?.volume = 10
        audioTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer(timer:)), userInfo: nil, repeats: true)
        
        fileProgressSlider!.maximum = Float((self.audioPlayer?.duration)!)
        fileProgressSlider!.continuous = false
        fileProgressSlider!.tintColor = UIColor.green
        hmsFrom(seconds: Int((self.audioPlayer?.duration)!)) { hours, minutes, seconds in
            self.nhours = self.getStringFrom(seconds: hours)
            self.nminutes = self.getStringFrom(seconds: minutes)
            self.nseconds = self.getStringFrom(seconds: seconds)
            //            print("\(self.nhours):\(minutes):\(seconds)")
        }

    }
    
    @objc func onTimer(timer: Timer) {
        // Check the audioPlayer, it's optinal remember. Get the current time and duration
        guard let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration else {
            return
        }
        
        // Calculate minutes, seconds, and percent completed
        let mins = currentTime / 60
        // let secs = currentTime % 60
        let secs = currentTime.truncatingRemainder(dividingBy: 60)
        let percentCompleted = currentTime / duration
        // Use the number formatter, it might return nil so guard
        //    guard let minsStr = timeFormatter.stringFromNumber(NSNumber(mins)), let secsStr = timeFormatter.stringFromNumber(NSNumber(secs)) else {
        //      return
        //    }
        
        guard let minsStr = timeFormatter.string(from: NSNumber(value: mins)), let secsStr = timeFormatter.string(from: NSNumber(value: secs)) else {
            return
        }
        
        
        // Everything is cool so update the timeLabel and progress bar
        self.lblFileDuration.text = "\(minsStr):\(secsStr) / \(self.nminutes):\(self.nseconds)"

        // Check that we aren't dragging the time slider before updating it
        if !isDraggingTimeSlider {
            print(percentCompleted)
            fileProgressSlider.value = Float(currentTime)
        }
        if percentCompleted == 0.0 {
            audioTimer?.invalidate()
            btnPlayPause.isSelected = true
            audioPlayer?.stop()
//            inputTV.text = ""
//            inputTV.resignFirstResponder()
//            onBtnCloseAdvertise((Any).self)
        }
    }
    
    @IBAction func timeSliderTouchDown(sender: TNSlider) {
        isDraggingTimeSlider = true
    }
    
    @IBAction func timeSliderTouchUp(sender: TNSlider) {
        isDraggingTimeSlider = false
    }
    
    @IBAction func timeSliderTouchUpOutside(sender: TNSlider) {
        isDraggingTimeSlider = false
    }
    
    func setupBottomView() {
        bottomView = UIView.init(frame: CGRect(x: 0, y: h + 34, width: w, height: 34))
        bottomView.backgroundColor = .clear
        self.tabBarController?.view.addSubview(bottomView)
        
        inputTV = UITextView()
        inputTV.font = UIFont.systemFont(ofSize: 14.0)
        inputTV.frame = CGRect(x: 5, y: 0, width: w - 64, height: (inputTV.font?.lineHeight)!)
        inputTV.delegate = self
       // inputTV.autocorrectionType = .no
        inputTV.cornerRadius = 10
        inputTV.borderWidth = 1
        inputTV.borderColor = UIColor.lumiGreen
        bottomView.addSubview(inputTV)
        
        submitButton = UIButton.init(type: .custom)
        submitButton.frame = CGRect(x: w - 60, y: 0, width: 60, height: 60)
        submitButton.addTarget(self, action: #selector(self.onBtnSendComments), for: .touchUpInside)
        submitButton.setImage(UIImage.init(named: "Artboard 134xxhdpi"), for: .normal)
        submitButton.contentHorizontalAlignment = .center
        submitButton.isUserInteractionEnabled = true
        bottomView.addSubview(submitButton)
        
        //self.bottomView.bringSubview(toFront: (self.tabBarController?.view)!)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            btnReport.isSelected = false
            btnComments.isSelected = false
            return false
        }
        return true
    }

}


// MARK: - PlayerPlaybackDelegate

extension AdvertiseVC:AGPlayerDelegate {
    func playerReady(_ playerVC: AVPlayerViewController) {
        var totalSeconds = 0
        
        if let duration = playerVC.player?.currentItem?.asset.duration {
            totalSeconds = Int(CMTimeGetSeconds(duration))
            fileProgressSlider!.maximum = Float(totalSeconds)
        }

        print("totalSeconds\(totalSeconds)")

        fileProgressSlider!.continuous = false
        fileProgressSlider!.tintColor = UIColor.green
        hmsFrom(seconds: totalSeconds) { hours, minutes, seconds in
            self.nhours = self.getStringFrom(seconds: hours)
            self.nminutes = self.getStringFrom(seconds: minutes)
            self.nseconds = self.getStringFrom(seconds: seconds)
            
            if hours != 0 {
                self.lblFileDuration.text = "00:00:00 / \(self.nhours):\(self.nminutes):\(self.nseconds)"
            }
            else {
                self.lblFileDuration.text = "00:00 / \(self.nminutes):\(self.nseconds)"
            }
            //            print("\(self.nhours):\(minutes):\(seconds)")
        }
        // todo self.playerView.playerController.player?.playFromBeginning()
        runTimer()
        self.viewAdvContent.bringSubview(toFront: viewAdvTimer)
        

    }
    
    func playerCurrentTimeDidChange(_ playerVC: AVPlayerViewController) {
        self.fileProgressSlider!.value = Float(CMTimeGetSeconds((playerVC.player?.currentTime())!))
            //Float(playerVC.player?.currentTime)
        hmsFrom(seconds: Int(CMTimeGetSeconds((playerVC.player?.currentTime())!))) { hours, minutes, seconds in
            let newhours = self.getStringFrom(seconds: hours)
            let minutes = self.getStringFrom(seconds: minutes)
            let seconds = self.getStringFrom(seconds: seconds)
            
            if hours != 0 {
                self.lblFileDuration.text = "\(newhours):\(minutes):\(seconds) / \(self.nhours):\(self.nminutes):\(self.nseconds)"
            }
            else {
                self.lblFileDuration.text = "\(minutes):\(seconds) / \(self.nminutes):\(self.nseconds)"
            }
        }

    }
    
    func playerPlaybackDidEnd(_ playerVC: AVPlayerViewController) {
        playerVC.player?.pause()
    }
    
    func playerPlaybackWillLoop(_ playerVC: AVPlayerViewController) {
        playerVC.player?.pause()
        btnPlayPause.isSelected = true
        //onBtnCloseAdvertise((Any).self)
    }
    
    
//    func playerCurrentTimeDidChange(_ player: Player) {
//        self.fileProgressSlider!.value = Float(self.player.currentTime)
//        hmsFrom(seconds: Int(self.player.currentTime)) { hours, minutes, seconds in
//            let newhours = self.getStringFrom(seconds: hours)
//            let minutes = self.getStringFrom(seconds: minutes)
//            let seconds = self.getStringFrom(seconds: seconds)
//
//            if hours != 0 {
//                self.lblFileDuration.text = "\(newhours):\(minutes):\(seconds) / \(self.nhours):\(self.nminutes):\(self.nseconds)"
//            }
//            else {
//                self.lblFileDuration.text = "\(minutes):\(seconds) / \(self.nminutes):\(self.nseconds)"
//            }
//        }
//    }
//
//    func playerPlaybackWillStartFromBeginning(_ player: Player) {
//    }
//
//    func playerPlaybackDidEnd(_ player: Player) {
//        self.player.pause()
//    }
//
//    func playerPlaybackWillLoop(_ player: Player) {
//        self.player.stop()
//        btnPlayPause.isSelected = true
//        onBtnCloseAdvertise((Any).self)
//    }
    
    
}
    extension UIViewController : UIDocumentInteractionControllerDelegate {
        
        public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
            return self
        }
        
}
extension UIView {
    
    /**
     Rotate a view by specified degrees
     
     - parameter angle: angle in degrees
     */
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
    
}

