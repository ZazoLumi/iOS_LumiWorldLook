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

class ContentGalleryCell : UITableViewCell, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var lblAdvTitle: UILabel!
    @IBOutlet weak var lblAdvPostedTime: UILabel!
    @IBOutlet weak var commentTblHeight : NSLayoutConstraint!

    @IBOutlet weak var imgAdvType: UIImageView!
    @IBOutlet weak var lblLumineerName: UILabel!
    @IBOutlet weak var imgLumineerProfile: UIImageView!
    @IBOutlet weak var imgAdsContent: UIImageView!
    
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if aryCommentsData.count > 0 {commentTblHeight.constant = CGFloat((aryCommentsData.count * 54) + 10) }
        else {commentTblHeight.constant = 0}
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
                        let scalImg = image.af_imageScaled(to: CGSize(width:self.imgLumineerProfile.frame.size.width, height: self.imgLumineerProfile.frame.size.height))
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
//            let objLumineer = GlobalShareData.sharedGlobal.objCurrentLumineer
//            cell.lblLumineerTitle.text = objLumineer?.displayName
//            let imgThumb = UIImage.decodeBase64(strEncodeData:objLumineer?.enterpriseLogo)
//            cell.imgLumineerProfile.image = imgThumb
        }
        cell.lblMessageTime.text = Date().getFormattedDate(string: (objComment.strCreatedDate)!, formatter: "yyyy-MM-dd HH:mm")
        cell.lblMessageDetails.text = objComment.commentBody

        return cell
    }
}

//    lazy var mvPlayerView: AGVideoPlayerView = {
//        let playerView = AGVideoPlayerView()
//        playerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width).isActive = true
//        playerView.heightAnchor.constraint(equalToConstant: 170).isActive = true
//        //        playerView.leadingAnchor.constraint(equalTo: 0)
//        //        playerView.videoUrl = url1!
//        playerView.shouldAutoplay = true
//        playerView.shouldAutoRepeat = true
//        playerView.showsCustomControls = false
//        playerView.shouldSwitchToFullscreen = false
//        playerView.isMuted = true
//        return playerView
//    }()

class LumineerContentGalleryVC: UIViewController, UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var aryContentData: [[String:AnyObject]] = []
    var objContentertiseVC : AdvertiseVC!
    weak var delegate: ScrollContentSize?
    var objPlayer: AVAudioPlayer?
    var mediaZoom: MediaZoom?
    fileprivate var documentInteractionController = UIDocumentInteractionController()
    var inputTV: UITextView!
    var bottomView: UIView!
    var submitButton : UIButton!
    let h = UIScreen.main.bounds.height
    let w = UIScreen.main.bounds.width
    var objCurrentContent : LumineerContent!
    var currentCell : ContentGalleryCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

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
        inputTV.text = ""
        inputTV.resignFirstResponder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func getLatestLumineersContents() {
        aryContentData = GlobalShareData.sharedGlobal.getAllContents()
//        let sorted = aryContentData.sorted { left, right -> Bool in
//            guard let rightKey = right["message"]?.updatedDate else { return true }
//            guard let leftKey = left["message"]?.updatedDate else { return true }
//            return leftKey > rightKey
//        }
//        self.aryContentData.removeAll()
//        self.aryContentData.append(contentsOf: sorted)
        self.tableView.reloadData()
        setupBottomView()
    }
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 220
//    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryContentData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell :  ContentGalleryCell!
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerContent

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
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))
        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;
        cell.lblAdvTitle.text = objContent?.contentTitle

        let imgMsgType : UIImage!
        var urlOriginalImage : URL? = nil
        if objContent?.contentType == "video" {
            if objContent?.adMediaURL != nil {
                    if(objContent?.adMediaURL?.hasUrlPrefix())!
                    {
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
                    cell.mvPlayerView.isMuted = false
                }
            imgMsgType = UIImage(named:"Asset102")
        }
        else if objContent?.contentType == "audio" {
            imgMsgType = UIImage(named:"Asset104")
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
                        let scalImg = image.af_imageScaled(to: CGSize(width: cell.imgAdsContent.size.width, height: cell.imgAdsContent.size.height))
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

        cell.btnReport.addTarget(self, action: #selector(didTapReportBtn(_:)), for: .touchUpInside)
        cell.btnReport.tag = indexPath.row + 30000
        
        cell.btnSave.addTarget(self, action: #selector(didTapSaveBtn(_:)), for: .touchUpInside)
        cell.btnSave.tag = indexPath.row + 60000

        cell.aryCommentsData = []
        cell.aryCommentsData = (objContent?.ctnComments.map {return $0})!
        if cell.aryCommentsData.count > 0 {cell.cellTableView.reloadData()
            let count = cell.aryCommentsData.count
            cell.btnComments.setTitle("\(count) Comments", for: .normal)
            cell.btnComments.setTitle("\(count) Comments", for: .selected)
        }
        else {
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
        let objContent = objCellData["message"] as? LumineerContent
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
        let objContent = objCellData["message"] as? LumineerContent
        if objContent?.contentType == "audio" {
            objPlayer?.stop()
        }
        else if objContent?.contentType == "video" {
            let visibleCells = tableView.visibleCells;
            let minIndex = visibleCells.startIndex;
            if tableView.visibleCells.index(of: cell) == minIndex {
                contentCell.mvPlayerView.playerController.player?.pause()
            }
        }    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       /* var objCellData : [String : Any]!
            objCellData = aryContentData[indexPath.row]
        
            let objContent = objCellData["message"] as? AdvertiseData
            GlobalShareData.sharedGlobal.isVideoPlaying = false
            GlobalShareData.sharedGlobal.objCurrentAdv = objContent
            let realm = try! Realm()
            let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objContent?.lumineerId.int ?? Int.self)
            if objsLumineer.count > 0 {
                let lumineer = objsLumineer[0]
                GlobalShareData.sharedGlobal.objCurrentLumineer = lumineer
            }
            GlobalShareData.sharedGlobal.objCurretnVC.view.addBlurEffect()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            objContentertiseVC = storyBoard.instantiateViewController(withIdentifier: "AdvertiseVC") as! AdvertiseVC
            GlobalShareData.sharedGlobal.objCurretnVC.addChildViewController(self.objContentertiseVC)
            self.objContentertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:390);
            GlobalShareData.sharedGlobal.objCurretnVC.view.addSubview(self.objContentertiseVC.view)
            self.objContentertiseVC
                .didMove(toParentViewController: self)
            */
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @objc func didTapFullScreenBtn(_ sender: UIButton) {
        let index = sender.tag - 50000
        let indexPath = IndexPath(row: index, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as? ContentGalleryCell;
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerContent
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
        let objContent = objCellData["message"] as? LumineerContent
        
        var msgText : String = ""
        let realm = try! Realm()
        
        let type = objContent?.contentType?.uppercased()
        if (objContent?.isCtsSaved)! {
            msgText =  "\(type!) IS ALREADY SAVED"
        }
        else {
            try! realm.write({
                objContent?.isCtsSaved = true})
            msgText =  "\(type!) SAVED TO WATCH LATER"
            
        }
        let hud = MBProgressHUD.showAdded(to: self.view!, animated: true)
        hud.mode = .text
        hud.label.text = NSLocalizedString(msgText, comment: "HUD message title")
        hud.label.font = UIFont.init(name: "HelveticaNeue", size: 14)
        hud.offset = CGPoint(x:0, y: UIScreen.main.bounds.height/2)// CGPoint(x: (super.view.width/2)-50, y: super.view.height/2)
        hud.hide(animated: true, afterDelay: 3.0)
        
    }
   


    @objc func didTapShareBtn(_ sender: UIButton) {
        let index = sender.tag - 40000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerContent
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
        objCurrentContent = objCellData["message"] as? LumineerContent
        
    }
    
    @objc func didTapLikeBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        let index = sender.tag - 20000
        let indexPath = IndexPath(row: index, section: 0)
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        objCurrentContent = objCellData["message"] as? LumineerContent
        let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = NSLocalizedString("Sending...", comment: "HUD loading title")
        let objAdvData = LumineerContent()
        let dictDetails = ["contentFilePath":objCurrentContent.contentFilePath! as AnyObject,"likeBody":"" as AnyObject,"like":sender.isSelected as AnyObject,"lumineerId":(objCurrentContent.lumineerId) as AnyObject,"contentID":objCurrentContent.contentID! as AnyObject,"lumineerName":objCurrentContent.lumineerName! as AnyObject]
        
        objAdvData.sendContentLikes(param: dictDetails) { (success) in
            DispatchQueue.main.async {
                hud.hide(animated: true)
            }
            if success {
                DispatchQueue.main.async {
                }
            }
        }

    }
    
    @objc func didTapCommentsBtn(_ sender: UIButton) {
        let index = sender.tag - 10000
        let indexPath = IndexPath(row: index, section: 0)
        currentCell = tableView.cellForRow(at: indexPath) as? ContentGalleryCell;
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        objCurrentContent = objCellData["message"] as? LumineerContent
        inputTV.becomeFirstResponder()

    }

    func playAudioFile(urlOriginalImage : URL) {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // For iOS 11
            objPlayer = try AVAudioPlayer(contentsOf: urlOriginalImage, fileTypeHint: AVFileType.mp3.rawValue)
            guard let aPlayer = objPlayer else { return }
            aPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }


 
    // MARK: - Comment Inputview
    
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
     
    var keyboardHeight = 0
    @objc func keyboardWillShow(_ n: Notification?) {
        if let keyboardSize = (n?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = Int(keyboardSize.height)
            print(keyboardHeight)
            textViewDidChange(inputTV)
            IQKeyboardManager.sharedManager().enableAutoToolbar = false
        }
    }
    @objc func keyboardWillHide(_ n: Notification?) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.bottomView.frame = CGRect(x: 0, y:Int(Int(self.h) + 44), width:Int(self.w), height: Int(44))
            self.inputTV.frame = CGRect(x: 10, y: 0, width:Int( self.w - 64), height: 44)
            self.submitButton.frame = CGRect(x: Int(self.w - 60), y: Int(0), width: 60, height: 44)
            IQKeyboardManager.sharedManager().enableAutoToolbar = true
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
            let objAdvData = LumineerContent()
        let dictDetails = ["contentFilePath":objCurrentContent.contentFilePath! as AnyObject,"commentBody":inputTV.text! as AnyObject,"lumineerId":(objCurrentContent.lumineerId) as AnyObject,"contentID":objCurrentContent.contentID! as AnyObject,"lumineerName":objCurrentContent.lumineerName! as AnyObject]

                objAdvData.sendContentComments(param: dictDetails) { (success) in
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                    }
                    if success {
                        DispatchQueue.main.async {
                            self.inputTV.text = ""
                            self.inputTV.resignFirstResponder()
                            if self.objCurrentContent.ctnComments.count > 0 {
                                let count = self.objCurrentContent.ctnComments.count
                                self.currentCell.btnComments.setTitle("\(count) Comments", for: .normal)
                                self.currentCell.btnComments.setTitle("\(count) Comments", for: .selected)
                            }
                            if self.objCurrentContent.ctnComments.count > 1 {
                                self.currentCell.cellTableView.contentOffset = .zero
                            }
                            self.getLatestLumineersContents()
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
