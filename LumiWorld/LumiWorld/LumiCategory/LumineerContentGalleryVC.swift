//
//  LumineerAdvertiseVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/10/03.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import RealmSwift
import AVKit
import Alamofire
import MBProgressHUD
import IQKeyboardManagerSwift

class ContentGalleryCell : UITableViewCell, UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    @IBOutlet weak var lblAdvTitle: UILabel!
    @IBOutlet weak var lblAdvPostedTime: UILabel!
    @IBOutlet weak var commentTblHeight : NSLayoutConstraint!

    @IBOutlet weak var btnMuteUnmute: UIButton!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var imgAdvType: UIImageView!
    @IBOutlet weak var lblLumineerName: UILabel!
    @IBOutlet weak var imgLumineerProfile: UIImageView!
    @IBOutlet weak var imgAdsContent: UIImageView!
    @IBOutlet weak var imgAudioPlay: UIImageView!

    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnFullScreen: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var mvPlayerView: AGVideoPlayerView!
    @IBOutlet weak var cellTableView: UITableView!
    var aryCommentsData : [ContentComments] = []
    @IBOutlet weak var inputTV: UITextView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak  var submitButton : UIButton!
    let h = UIScreen.main.bounds.height
    let w = UIScreen.main.bounds.width

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if aryCommentsData.count > 0 {commentTblHeight.constant = CGFloat((aryCommentsData.count * 54) + 34) }
        else if btnComments.isSelected {commentTblHeight.constant = 40}
        else {
            commentTblHeight.constant = 0
        }
        return aryCommentsData.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "advCommentCell", for: indexPath as IndexPath) as! advCommentCell
        let objComment = aryCommentsData[indexPath.row] as ContentComments
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
            let realm = try! Realm()
            cell.lblLumineerTitle.text = objComment.lumineerName
            let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",Int(objComment.lumineerId))
            if objsLumineer.count > 0 {
                let imgThumb = UIImage.decodeBase64(strEncodeData:objsLumineer.first?.enterpriseLogo)
                cell.imgLumineerProfile.image = imgThumb
            }
        }
        var strDate = (objComment.strUpdatedDate)!
        if strDate.contains(".") {
            strDate = strDate.components(separatedBy: ".").first!
        }
        cell.lblMessageTime.text = Date().getFormattedDate(string: strDate, formatter: "yyyy-MM-dd HH:mm")
        cell.lblMessageDetails.text = objComment.commentBody

        return cell
    }
    
   @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        inputTV.resignFirstResponder()
    }
}


class LumineerContentGalleryVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var aryContentData: [[String:AnyObject]] = []
    var objContentertiseVC : AdvertiseVC!
    weak var delegate: ScrollContentSize?
    var objPlayer: AVAudioPlayer?
    var mediaZoom: MediaZoom?
    fileprivate var documentInteractionController = UIDocumentInteractionController()
    var objCurrentContent : LumineerGalleryData!
    var currentCell : ContentGalleryCell!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(LumiCategoryVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lumiGreen
        
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        self.tableView.addSubview(self.refreshControl)
        self.tableView!.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        aryContentData = []
        self.getLatestLumineersContents()
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationItem.title = "LUMI WORLD GALLERY"
    }
    override func viewWillDisappear(_ animated: Bool) {
//        inputTV.text = ""
//        inputTV.resignFirstResponder()
        objPlayer?.stop()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumineersContents()
    }

    @objc func getLatestLumineersContents() {
        aryContentData = GlobalShareData.sharedGlobal.getAllGallaryContents()
//        let sorted = aryContentData.sorted { left, right -> Bool in
//            guard let rightKey = right["message"]?.updatedDate else { return true }
//            guard let leftKey = left["message"]?.updatedDate else { return true }
//            return leftKey > rightKey
//        }
//        self.aryContentData.removeAll()
//        self.aryContentData.append(contentsOf: sorted)
        self.tableView.reloadData()
//        setupBottomView()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryContentData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell :  ContentGalleryCell!
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerGalleryData

        if objContent?.contentType == "video" {
            cell = tableView.dequeueReusableCell(withIdentifier: "ContentVideoCell", for: indexPath) as! ContentGalleryCell
        }
        else if objContent?.contentType == "image" {
            cell = tableView.dequeueReusableCell(withIdentifier: "ContentGalleryCell", for: indexPath) as! ContentGalleryCell
        }
        else  {
            cell = tableView.dequeueReusableCell(withIdentifier: "ContentAudioCell", for: indexPath) as! ContentGalleryCell
        }
        
        cell.lblLumineerName.text = objCellData["title"] as? String
        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData["profileImg"] as? String)
        let scalImg = imgThumb.af_imageAspectScaled(toFill: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))
        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;
        cell.lblAdvTitle.text = objContent?.contentTitle

        let imgMsgType : UIImage!
        var urlOriginalImage : URL? = nil
        if objContent?.contentType == "video" {
            if objContent?.adMediaURL != nil {
                    if(objContent?.adMediaURL?.hasUrlPrefix())!{
                        urlOriginalImage = URL.init(string: (objContent?.adMediaURL!)!)
                    }
                    else {
                        let fileName = objContent?.contentFileName?.replacingOccurrences(of: " ", with: "-")
                        urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    }
                    cell.mvPlayerView.videoUrl = urlOriginalImage!
                    cell.mvPlayerView.shouldAutoplay = true
                    cell.mvPlayerView.shouldAutoRepeat = true
                    cell.mvPlayerView.showsCustomControls = false
                    cell.mvPlayerView.shouldSwitchToFullscreen = false
                    cell.mvPlayerView.isMuted = true
                }
            imgMsgType = UIImage(named:"Asset102")
        }
        else if objContent?.contentType == "audio" {
            imgMsgType = UIImage(named:"Asset104")
            cell.btnPlayPause.addTarget(self, action: #selector(didTapPlayPauseBtn(_:)), for: .touchUpInside)
            cell.btnPlayPause.tag = indexPath.row + 80000
            
            cell.btnMuteUnmute.addTarget(self, action: #selector(didTapMuteUnmuteBtn(_:)), for: .touchUpInside)
            cell.btnMuteUnmute.tag = indexPath.row + 70000
            cell.contentView.bringSubview(toFront: cell.btnMuteUnmute)
            cell.contentView.bringSubview(toFront: cell.btnPlayPause)
            let imgThumb = UIImage.decodeBase64(strEncodeData:(objContent?.thumbnail!)! )
            let scalImg = imgThumb.af_imageAspectScaled(toFill: CGSize(width: cell.imgAdsContent.frame.size.width, height: cell.imgAdsContent.frame.size.height))
            cell.imgAdsContent.image = scalImg

        }
        else {
            if objContent?.adMediaURL != nil {
                if(objContent?.adMediaURL?.hasUrlPrefix())!
                {
                    urlOriginalImage = URL.init(string: (objContent?.adMediaURL!)!)
                }
                else {
                    let fileName = objContent?.contentFileName?.replacingOccurrences(of: " ", with: "-")
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
            }
            imgMsgType = UIImage(named:"Asset106")
            if urlOriginalImage != nil {
                Alamofire.request(urlOriginalImage!).responseImage { response in
                    debugPrint(response)
                    if let image = response.result.value {
                        let scalImg = image.af_imageAspectScaled(toFill: CGSize(width: cell.imgAdsContent.size.width, height: cell.imgAdsContent.size.height))
                        cell.imgAdsContent.image = scalImg
                    }
                }}
            cell.imgAdsContent.contentMode = .scaleAspectFit
        }
        cell.imgAdvType.image = imgMsgType
        cell.lblAdvPostedTime.text = Date().getFormattedDate(string: (objContent?.strCreatedDate!)!, formatter: "yyyy-MM-dd HH:mm")
        cell.btnFullScreen.addTarget(self, action: #selector(didTapFullScreenBtn(_:)), for: .touchUpInside)
        cell.btnFullScreen.tag = indexPath.row + 50000
        
        cell.btnShare.addTarget(self, action: #selector(didTapShareBtn(_:)), for: .touchUpInside)
        cell.btnShare.tag = indexPath.row + 40000

        cell.btnComments.addTarget(self, action: #selector(didTapCommentsBtn(_:)), for: .touchUpInside)
        cell.btnComments.tag = indexPath.row + 10000

        cell.btnLike.addTarget(self, action: #selector(didTapLikeBtn(_:)), for: .touchUpInside)
        cell.btnLike.tag = indexPath.row + 20000
        let likeCount = Int((objContent?.likeCount)!)
        if likeCount > 0 {
            cell.btnLike.setTitle("\(likeCount)", for: .normal)
            cell.btnLike.setTitle("\(likeCount)", for: .selected)
        }
        cell.btnLike.isSelected = (objContent?.isGlrLiked)!
        cell.btnReport.addTarget(self, action: #selector(didTapReportBtn(_:)), for: .touchUpInside)
        cell.btnReport.tag = indexPath.row + 30000
        
        cell.btnSave.addTarget(self, action: #selector(didTapSaveBtn(_:)), for: .touchUpInside)
        cell.btnSave.tag = indexPath.row + 60000
        


        cell.aryCommentsData = []
        cell.aryCommentsData = (objContent?.glrComments.map {return $0})!
        if cell.aryCommentsData.count > 0 {
            let count = cell.aryCommentsData.count
            cell.btnComments.setTitle("\(count) Comments", for: .normal)
            cell.btnComments.setTitle("\(count) Comments", for: .selected)
        }
        if objCellData["isSelected"] as? String == "true" {
            cell.cellTableView.reloadData()
            cell.submitButton.addTarget(self, action: #selector(self.onBtnSendComments(_:)), for: .touchUpInside)
        }
        else {
            cell.aryCommentsData = []
            cell.cellTableView.reloadData()
            cell.commentTblHeight.constant = 0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Raw:\(indexPath.row)")
        guard let contentCell = (cell as? ContentGalleryCell) else { return };
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerGalleryData
        if objContent?.contentType == "audio" {
            let urlOriginalImage : URL!
            if objContent?.adMediaURL != nil {
                if(objContent?.adMediaURL?.hasUrlPrefix())!
                {
                    urlOriginalImage = URL.init(string: (objContent?.adMediaURL!)!)
                }
                else {
                    let fileName = objContent?.contentFileName?.replacingOccurrences(of: " ", with: "-")
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
                playAudioFile(urlOriginalImage: urlOriginalImage)
                contentCell.viewContainer.bringSubview(toFront: contentCell.btnPlayPause)
                contentCell.viewContainer.bringSubview(toFront: contentCell.btnMuteUnmute)
                contentCell.btnPlayPause.isSelected = true
                contentCell.btnMuteUnmute.isSelected = false
            }
        }
        else if objContent?.contentType == "video" {
            let visibleCells = tableView.visibleCells;
            _ = visibleCells.startIndex;
                contentCell.mvPlayerView.playerController.player?.play()
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let contentCell = (cell as? ContentGalleryCell) else { return };
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerGalleryData
        if objContent?.contentType == "audio" {
            objPlayer?.stop()
            contentCell.btnPlayPause.isSelected = false
        }
        else if objContent?.contentType == "video" {
            let visibleCells = tableView.visibleCells;
            let minIndex = visibleCells.startIndex;
            if tableView.visibleCells.index(of: cell) == minIndex {
                contentCell.mvPlayerView.playerController.player?.pause()
            }
        }    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func didTapFullScreenBtn(_ sender: UIButton) {
        let index = sender.tag - 50000
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? ContentGalleryCell;
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerGalleryData
        if objContent?.contentType == "audio" {
        
        }
        else if objContent?.contentType == "video" {
            NotificationCenter.default.post(name: .playerDidChangeFullscreenMode, object: true)
            cell?.mvPlayerView.hanldeOrientation()
        }
        else {
            self.mediaZoom = MediaZoom(with: (cell?.imgAdsContent)!, animationTime: 0.5, useBlur: true)
            view.addSubview(mediaZoom!)
            mediaZoom?.show()
            
        }
    }
    
    @objc func didTapSaveBtn(_ sender: UIButton) {
        let index = sender.tag - 60000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerGalleryData
        
        var msgText : String = ""
        let realm = try! Realm()
        
        let type = objContent?.contentType?.uppercased()
        if (objContent?.isGlrSaved)! {
            msgText =  "\(type!) IS ALREADY SAVED"
        }
        else {
            try! realm.write({
                objContent?.isGlrSaved = true})
            msgText =  "\(type!) SAVED TO WATCH LATER"
            
        }
        let hud = MBProgressHUD.showAdded(to: self.view!, animated: true)
        hud.mode = .text
        hud.label.text = NSLocalizedString(msgText, comment: "HUD message title")
        hud.label.font = UIFont.init(name: "HelveticaNeue", size: 14)
        hud.offset = CGPoint(x:0, y: UIScreen.main.bounds.height/2)// CGPoint(x: (super.view.width/2)-50, y: super.view.height/2)
        hud.hide(animated: true, afterDelay: 3.0)
    }
   

    @objc func didTapPlayPauseBtn(_ sender: UIButton) {
        let index = sender.tag - 80000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        _ = objCellData["message"] as? LumineerGalleryData
        let _ : URL!
        currentCell = tableView.cellForRow(at: indexPath) as? ContentGalleryCell;
        currentCell.btnPlayPause.isSelected = !sender.isSelected
        if sender.isSelected {objPlayer?.play()}
        else {objPlayer?.stop()}
    }
    
    @objc func didTapMuteUnmuteBtn(_ sender: UIButton) {
        let index = sender.tag - 70000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        _ = objCellData["message"] as? LumineerGalleryData
        let _ : URL!
        currentCell = tableView.cellForRow(at: indexPath) as? ContentGalleryCell;
        currentCell.btnMuteUnmute.isSelected = !sender.isSelected
        
        if sender.isSelected {
            objPlayer?.volume = 1.0
        }
        else {
            objPlayer?.volume = 0
        }
    }

    @objc func didTapShareBtn(_ sender: UIButton) {
        let index = sender.tag - 40000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerGalleryData
        let urlOriginalImage : URL!

        if objContent?.adMediaURL != nil {
            if(!(objContent?.adMediaURL?.hasUrlPrefix())!)
            {
                let fileName = objContent?.contentFileName?.replacingOccurrences(of: " ", with: "-")
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                documentInteractionController.delegate = self
                documentInteractionController.url = urlOriginalImage
                documentInteractionController.presentPreview(animated: true)

            }
        }
    }
    
    @objc func didTapReportBtn(_ sender: UIButton) {
        let index = sender.tag - 30000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        objCurrentContent = objCellData["message"] as? LumineerGalleryData
    }
    
    @objc func didTapLikeBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let index = sender.tag - 20000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        objCurrentContent = objCellData["message"] as? LumineerGalleryData
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = NSLocalizedString("Sending...", comment: "HUD loading title")
        let isLike = (sender.isSelected ? "true" : "false") as String
        let objAdvData = LumineerContent()
        let dictDetails = ["contentFilePath":objCurrentContent.contentFilePath! as AnyObject,"likeBody":"" as AnyObject,"like":isLike as AnyObject,"lumineerId":(objCurrentContent.lumineerId) as AnyObject,"contentID":objCurrentContent.galleryID! as AnyObject,"lumineerName":objCurrentContent.lumineerName! as AnyObject]
       // let dictDetails = ["contentFilePath":objCurrentContent.contentFilePath! as AnyObject,"likeBody":"" as AnyObject,"like":(sender.isSelected ? "true" : "false") as AnyObject,"lumineerId":(objCurrentContent.lumineerId) as AnyObject,"contentID":objCurrentContent.contentID! as AnyObject,"lumineerName":objCurrentContent.lumineerName! as AnyObject]

        objAdvData.sendContentLikes(param: dictDetails) { (success) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
            if success {
                GlobalShareData.sharedGlobal.getAllLatestLumineerData()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                    self.getLatestLumineersContents()
                })
            }
        }
    }
    
    @objc func didTapCommentsBtn(_ sender: UIButton) {
        let index = sender.tag - 10000
        let indexPath = IndexPath(row: index, section: 0)
        currentCell = tableView.cellForRow(at: indexPath) as? ContentGalleryCell;
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        objCurrentContent = objCellData["message"] as? LumineerGalleryData
        //currentCell.inputTV.becomeFirstResponder()
        if sender.isSelected {
            print("false")
            aryContentData[indexPath.row]["isSelected"] = "false" as AnyObject
            sender.isSelected = false
        }else {
            print("true")
            aryContentData[indexPath.row]["isSelected"]  = "true" as AnyObject
            sender.isSelected = true
        }
        tableView.reloadData()
    }

    func playAudioFile(urlOriginalImage : URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // For iOS 11
            objPlayer = try AVAudioPlayer(contentsOf: urlOriginalImage, fileTypeHint: AVFileType.mp3.rawValue)
            guard let aPlayer = objPlayer else { return }
            aPlayer.play()
            aPlayer.volume = 0
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

    @objc func onBtnSendComments(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = NSLocalizedString("Sending...", comment: "HUD loading title")
            let objAdvData = LumineerContent()
        let dictDetails = ["contentFilePath":objCurrentContent.contentFilePath! as AnyObject,"commentBody":currentCell.inputTV.text! as AnyObject,"lumineerId":(objCurrentContent.lumineerId) as AnyObject,"contentID":objCurrentContent.galleryID! as AnyObject,"lumineerName":objCurrentContent.lumineerName! as AnyObject]

                objAdvData.sendContentComments(param: dictDetails) { (success) in
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        self.currentCell.inputTV.text = ""
                        self.currentCell.inputTV.resignFirstResponder()
                    }
                    if success {
                        DispatchQueue.main.async {
                            if self.objCurrentContent.glrComments.count > 0 {
                                let count = self.objCurrentContent.glrComments.count
                                self.currentCell.btnComments.setTitle("\(count) Comments", for: .normal)
                                self.currentCell.btnComments.setTitle("\(count) Comments", for: .selected)
                            }
                            if self.objCurrentContent.glrComments.count > 1 {
                                self.currentCell.cellTableView.contentOffset = .zero
                            }
                            GlobalShareData.sharedGlobal.getAllLatestLumineerData()
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                                self.getLatestLumineersContents()
                            })

                        }
                    }
                }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
