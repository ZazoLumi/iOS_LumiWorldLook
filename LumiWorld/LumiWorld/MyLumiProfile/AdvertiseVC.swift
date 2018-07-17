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
class AdvertiseVC: UIViewController,UITableViewDelegate,UITableViewDataSource,TNSliderDelegate,UITextViewDelegate {
    

      var inputTV: UITextView!
      var bottomView: UIView!
    
    @IBOutlet weak var tblCommentData: UITableView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComments: UIButton!
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
    var nhours : String!
    var nminutes : String!
    var nseconds : String!
    var seconds = 10
    var timer = Timer()
    let h = UIScreen.main.bounds.height
    let w = UIScreen.main.bounds.width
    var submitButton : UIButton!

    @IBOutlet weak var btnCloseAdv: UIButton!
    //var player:AVPlayer?
   // var playerItem:AVPlayerItem?
    fileprivate var player = Player()
    let timeFormatter = NumberFormatter()
    
    var audioPlayer: AVAudioPlayer?     // holds an audio player instance. This is an optional!
    var audioTimer: Timer?            // holds a timer instance
    var isDraggingTimeSlider = false    // Keep track of when the time slide is being dragged
    
    var isPlaying = false {             // keep track of when the player is playing
        didSet {                        // This is a computed property. Changing the value
            playPauseAudio()
        }
    }

    deinit {
        self.player.willMove(toParentViewController: self)
        self.player.view.removeFromSuperview()
        self.player.removeFromParentViewController()
    }


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
    }
    var keyboardHeight = 0
    @objc func keyboardWillShow(_ n: Notification?) {
        if let keyboardSize = (n?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = Int(keyboardSize.height)-35
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
            self.tabBarController?.tabBar.isHidden = false

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
            self.tabBarController?.tabBar.isHidden = true

        }) { finished in
            //default disable scroll here to avoid bouncing
        }
    }
    @objc func onBtnSendComments(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = NSLocalizedString("Sending...", comment: "HUD loading title")
        let objAdvData = AdvertiseData()
        objAdvData.sendAdvertiseComments(param: ["lumineerId":GlobalShareData.sharedGlobal.objCurrentLumineer.id as AnyObject,"comments":inputTV.text as AnyObject,"lumiMobile":GlobalShareData.sharedGlobal.userCellNumber as AnyObject,"advertiseId":GlobalShareData.sharedGlobal.objCurrentAdv.advertiseId as AnyObject]) { (success) in
            if success {
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    self.inputTV.resignFirstResponder()
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
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
        self.lblAdvTitle.text = GlobalShareData.sharedGlobal.objCurrentAdv.contentTitle
        if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count > 0 {
            let count = GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count
            btnComments.setTitle("\(count) Comments", for: .normal)
            btnComments.setTitle("\(count) Comments", for: .selected)
        }
        if GlobalShareData.sharedGlobal.objCurrentAdv.likeCount > 0 {
            let count = Int(GlobalShareData.sharedGlobal.objCurrentAdv.likeCount)
            btnLike.setTitle("\(count)", for: .normal)
            btnLike.setTitle("\(count)", for: .selected)
        }

        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
            self.imgAdvType.image = UIImage(named:"Asset106")
            var imageView : UIImageView
            imageView  = UIImageView(frame:CGRect(x: 0, y: 0, width:Int(self.viewAdvContent.frame.size.width), height:Int(self.viewAdvContent.frame.size.height)));
            self.viewAdvContent.addSubview(imageView)
            imageView.contentMode = .scaleAspectFill
            let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName
            let urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
            Alamofire.request(urlOriginalImage).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    let scalImg = image.af_imageScaled(to: CGSize(width:imageView.frame.size.width, height: imageView.frame.size.height))
                    imageView.image = scalImg
                    self.runTimer()
                    self.viewAdvContent.bringSubview(toFront: self.viewAdvTimer)

                }
            }
        }
        else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
            self.imgAdvType.image = UIImage(named:"Asset102")
            let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName
           let urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)

            
            self.player.playerDelegate = self
            self.player.playbackDelegate = self
            self.player.view.frame = self.viewAdvContent.bounds
            
           // self.addChildViewController(self.player)
            self.viewAdvContent.addSubview(self.player.view)
            self.player.didMove(toParentViewController: self)
            
            self.player.url = urlOriginalImage
            
            self.player.playbackLoops = true
            
            self.player.fillMode = PlayerFillMode.resizeAspectFit.avFoundationType

//            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
//            tapGestureRecognizer.numberOfTapsRequired = 1
//           // self.player.view.addGestureRecognizer(tapGestureRecognizer)
        }
        else {
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
    
    func setupInitialConstraints()  {
        var totalHeight = 350
        constCommentsHeight.constant = 0
        viewFileProgress.isHidden = false
        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
            constFileProgressHeight.constant = 0
            viewFileProgress.isHidden = true
        }
        else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
            constAdvContainerHeight.constant = 60
            totalHeight -= 180
        }
        if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count > 0 {
            constCommentsHeight.constant = 100
            totalHeight += 100
        }
        setupBottomView()
        let yPos = (Int(UIScreen.main.bounds.height) - totalHeight)/2
        self.view.frame = CGRect(x: 0, y: yPos, width:Int(self.view.frame.size.width), height:totalHeight);
        tblCommentData.reloadData()

    }
    func slider(_ slider: TNSlider, displayTextForValue value: Float) -> String {
        let seconds : Int64 = Int64(value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        player.seek(to: targetTime) { (result) in
            self.player.playFromCurrentTime()
        }
        return String(format: "%.2f%%", value)
    }
    
    @IBAction func sliderValueChanged(_ playbackSlider: TNSlider) {
        print(playbackSlider.value)
        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
            guard let audioPlayer = audioPlayer else {
                return
            }
            audioPlayer.currentTime = audioPlayer.duration * Double(playbackSlider.value)
        }

    }
    
    @IBAction func playButtonTapped(_ sender:UIButton)
    {
        btnPlayPause.isSelected = !sender.isSelected
        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
            if btnPlayPause.isSelected {
                self.player.pause()
            }else {
                self.player.playFromCurrentTime()
            }
        }
        else {
            isPlaying = !isPlaying
        }
    }
    override func viewDidAppear(_ animated: Bool) {
       // self.view.frame = CGRect(x: 30, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width-60 , height:240);
        displayAdvertiseContent()
    }
    @IBAction func onBtnCommentsTapped(_ sender: UIButton) {
        btnComments.isSelected = !sender.isSelected
//        setupInitialConstraints()
        inputTV.becomeFirstResponder()

        
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
    @IBAction func onBtnLikeTapped(_ sender: UIButton) {
        btnLike.isSelected = !sender.isSelected
        let objAdvData = AdvertiseData()
        objAdvData.setLikeAdvertiseByLumi(param: ["isLike":!sender.isSelected as AnyObject,"lumiMobile":GlobalShareData.sharedGlobal.userCellNumber as AnyObject,"advertiseId":GlobalShareData.sharedGlobal.objCurrentAdv.advertiseId as AnyObject]) { (success) in
            if success {
            }
        }

    }
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "advCommentCell", for: indexPath) as! advCommentCell
        var objComment : AdvComments!
        objComment = GlobalShareData.sharedGlobal.objCurrentAdv.advComments[indexPath.row] as AdvComments
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
                        let scalImg = image.af_imageScaled(to: CGSize(width:self.imgLumineerProfile.frame.size.width, height: self.imgLumineerProfile.frame.size.height))
                        cell.imgLumineerProfile.image = scalImg
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
        cell.lblMessageTime.text = objComment?.strCommentPostedDate
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
            let type = GlobalShareData.sharedGlobal.objCurrentAdv.contentType?.uppercased()
            lblAdvTimerSeconds.text = "YOU CAN CLOSE THE \(type!) IN \(seconds)"
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)),
                                     userInfo: nil, repeats: true)
    }

    @IBAction func onBtnCloseAdvertise(_ sender: Any) {
        self.parent?.view.backgroundColor = UIColor.white
        self.view.superview?.removeBlurEffect()
        removeAnimate()
        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
            audioPlayer?.stop()}
        else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Video" {
            player.stop()
        }
        inputTV.resignFirstResponder()
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
        let fileName = GlobalShareData.sharedGlobal.objCurrentAdv.adFileName
        let contentURL = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)

        // TODO: Use catch here and check for errors.
        audioPlayer = try! AVAudioPlayer(contentsOf: contentURL as URL)
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
        self.lblFileDuration.text = "\(minsStr):\(secsStr) / \(self.nminutes!):\(self.nseconds!)"

        // Check that we aren't dragging the time slider before updating it
        if !isDraggingTimeSlider {
            print(percentCompleted)
            fileProgressSlider.value = Float(currentTime)
        }
        if percentCompleted == 0.0 {
            audioTimer?.invalidate()
            btnPlayPause.isSelected = true
            audioPlayer?.stop()
            inputTV.resignFirstResponder()
            onBtnCloseAdvertise((Any).self)
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
        view.addSubview(bottomView)
        
        inputTV = UITextView()
        inputTV.font = UIFont.systemFont(ofSize: 14.0)
        inputTV.frame = CGRect(x: 5, y: 0, width: w - 64, height: (inputTV.font?.lineHeight)!)
        inputTV.delegate = self
        inputTV.autocorrectionType = .no
//        inputTV.textContainer.lineFragmentPadding = 0
//        inputTV.textContainerInset = .zero
        inputTV.cornerRadius = 10
        inputTV.borderWidth = 2
        inputTV.borderColor = UIColor.lumiGreen
        bottomView.addSubview(inputTV)
        
        submitButton = UIButton.init(type: .custom)
        submitButton.frame = CGRect(x: w - 60, y: 0, width: 60, height: 60)
        submitButton.addTarget(self, action: #selector(self.onBtnSendComments), for: .touchUpInside)
        submitButton.setImage(UIImage.init(named: "Artboard 134xxhdpi"), for: .normal)
        submitButton.contentHorizontalAlignment = .center
        submitButton.isUserInteractionEnabled = true
        bottomView.addSubview(submitButton)
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }


}

extension AdvertiseVC {
    
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        switch (self.player.playbackState.rawValue) {
        case PlaybackState.stopped.rawValue:
            //self.player.playFromBeginning()
            break
        case PlaybackState.paused.rawValue:
            self.player.playFromCurrentTime()
            break
        case PlaybackState.playing.rawValue:
            self.player.pause()
            break
        case PlaybackState.failed.rawValue:
            self.player.pause()
            break
        default:
            self.player.pause()
            break
        }
    }
    
    
}

// MARK: - PlayerDelegate

extension AdvertiseVC:PlayerDelegate {
    func playerReady(_ player: Player) {
        fileProgressSlider!.maximum = Float(self.player.maximumDuration)
        fileProgressSlider!.continuous = false
        fileProgressSlider!.tintColor = UIColor.green
        hmsFrom(seconds: Int(self.player.maximumDuration)) { hours, minutes, seconds in
            self.nhours = self.getStringFrom(seconds: hours)
             self.nminutes = self.getStringFrom(seconds: minutes)
             self.nseconds = self.getStringFrom(seconds: seconds)
            
            if hours != 0 {
                self.lblFileDuration.text = "00:00:00 / \(self.nhours!):\(self.nminutes!):\(self.nseconds!)"
            }
            else {
                self.lblFileDuration.text = "00:00 / \(self.nminutes!):\(self.nseconds!)"
            }
//            print("\(self.nhours):\(minutes):\(seconds)")
        }
        self.player.playFromBeginning()
        runTimer()
        self.viewAdvContent.bringSubview(toFront: viewAdvTimer)

    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    func playerBufferTimeDidChange(_ bufferTime: Double) {
        
    }
    
}

// MARK: - PlayerPlaybackDelegate

extension AdvertiseVC:PlayerPlaybackDelegate {
    
    func playerCurrentTimeDidChange(_ player: Player) {
        self.fileProgressSlider!.value = Float(self.player.currentTime)
        hmsFrom(seconds: Int(self.player.currentTime)) { hours, minutes, seconds in
            let newhours = self.getStringFrom(seconds: hours)
            let minutes = self.getStringFrom(seconds: minutes)
            let seconds = self.getStringFrom(seconds: seconds)
            
            if hours != 0 {
                self.lblFileDuration.text = "\(newhours):\(minutes):\(seconds) / \(self.nhours!):\(self.nminutes!):\(self.nseconds!)"
            }
            else {
                self.lblFileDuration.text = "\(minutes):\(seconds) / \(self.nminutes!):\(self.nseconds!)"
            }
        }
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        self.player.pause()
    }
    
    func playerPlaybackWillLoop(_ player: Player) {
        self.player.stop()
        btnPlayPause.isSelected = true
        onBtnCloseAdvertise((Any).self)
    }
    
}


