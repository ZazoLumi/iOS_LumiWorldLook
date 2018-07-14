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
class AdvertiseVC: UIViewController,UITableViewDelegate,UITableViewDataSource,TNSliderDelegate {
    

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
    var nhours : String!
    var nminutes : String!
    var nseconds : String!
    var seconds = 10
    var timer = Timer()

    @IBOutlet weak var btnCloseAdv: UIButton!
    //var player:AVPlayer?
   // var playerItem:AVPlayerItem?
    fileprivate var player = Player()

    deinit {
        self.player.willMove(toParentViewController: self)
        self.player.view.removeFromSuperview()
        self.player.removeFromParentViewController()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let dimAlphaRedColor =  UIColor.lumiGreen?.withAlphaComponent(0.5)
        viewAdvTimer.backgroundColor =  dimAlphaRedColor
    }
    
    func displayAdvertiseContent() {
        var strBaseDataLogo : String? = ""
      let objLumineer = GlobalShareData.sharedGlobal.objCurrentLumineer
        self.lblLumineerName.text = objLumineer?.displayName

        strBaseDataLogo = objLumineer?.enterpriseLogo
        let imgThumb = UIImage.decodeBase64(strEncodeData:strBaseDataLogo)
        self.imgLumineerProfile.image = imgThumb
        self.lblAdvTitle.text = GlobalShareData.sharedGlobal.objCurrentAdv.contentTitle
        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
            
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
            
        }
        
    }
    
    func setupInitialConstraints() -> Int {
        var totalHeight = 390
        constCommentsHeight.constant = 0
        if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Image" {
            constFileProgressHeight.constant = 0
        }
        else if GlobalShareData.sharedGlobal.objCurrentAdv.contentType == "Audio" {
            constAdvContainerHeight.constant = 60
            totalHeight -= 190
        }
        return totalHeight
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

    }
    
    @IBAction func playButtonTapped(_ sender:UIButton)
    {
        btnPlayPause.isSelected = !sender.isSelected
        if btnPlayPause.isSelected {
            self.player.pause()
        }else {
            self.player.playFromCurrentTime()
        }

    }
    override func viewDidAppear(_ animated: Bool) {
       // self.view.frame = CGRect(x: 30, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width-60 , height:240);
        displayAdvertiseContent()
    }
    @IBAction func onBtnCommentsTapped(_ sender: Any) {
        if GlobalShareData.sharedGlobal.objCurrentAdv.advComments.count == 0 {
            constCommentsHeight.constant = 178
        }
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
        self.player.pause()
        btnPlayPause.isSelected = true
        onBtnCloseAdvertise((Any).self)
    }
    
}

