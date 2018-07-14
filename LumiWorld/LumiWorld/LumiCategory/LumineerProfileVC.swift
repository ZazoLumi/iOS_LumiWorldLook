//
//  LumineerProfileVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/04/05.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import Alamofire
import AVKit
import MBProgressHUD

class SubjectCell: UITableViewCell {
    @IBOutlet weak var imgStatus: UIImageView!
    
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgMessage: UIImageView!
    @IBOutlet weak var constImgWidth: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.imgMessage.layer.cornerRadius = self.imgMessage.bounds.size.height * 0.50
//        self.imgMessage.layer.borderWidth = 0.5;
//        self.imgMessage.layer.borderColor = UIColor.clear.cgColor;
        
    }
    
    
}

class LumineerProfileVC: UIViewController,ExpandableLabelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    let kHeaderSectionTag: Int = 6900;
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var currentTotalHeights: Int = 0
    @IBOutlet weak var btnSupport: UIButton!
    @IBOutlet weak var lblLumiProfileTxt: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var tblActivityData: UITableView!
    @IBOutlet weak var ratingVC: FloatRatingView!
    @IBOutlet weak var lblExpandableDescription: ExpandableLabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnInboxCount: UIButton!
    @IBOutlet weak var lblFollowers: UILabel!
    var aryActivityData: [[String:AnyObject]]!
    var objLumineer : LumineerList!
    var objAdvertiseVC : AdvertiseVC!
    var isInboxCountSelected = false
    
    @IBOutlet weak var lblActivity: UIView!
    @IBOutlet weak var viewActivityHeights: NSLayoutConstraint!
    @IBOutlet weak var btnFollowLumineer: UIButton!
    @IBOutlet weak var mainViewHeights: NSLayoutConstraint!
    var objPopupSendMessage : PopupSendMessage! = nil
    //
    // MARK: Lifecycle methods
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.addBackButtonOnLeft()
        NotificationCenter.default.addObserver(self, selector: #selector(getLatestLumiMessages), name: Notification.Name("popupRemoved"), object: nil)

        lblExpandableDescription.delegate = self
        lblExpandableDescription.setLessLinkWith(lessLink: "Close", attributes: [.foregroundColor:UIColor.red], position: .center)
        
        lblExpandableDescription.shouldCollapse = true
        lblExpandableDescription.textReplacementType = .word
        lblExpandableDescription.numberOfLines = 2
       // lblExpandableDescription.textAlignment = .right
        lblExpandableDescription.textAlignment = .center

        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleRatingTapFrom(recognizer:)))
        self.ratingVC.addGestureRecognizer(tapGestureRecognizer)
        self.ratingVC.isUserInteractionEnabled = true
        viewActivityHeights.constant = 0
        lblActivity.isHidden = true
        lblLumiProfileTxt.text =  "Hi \(GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!), how can we help you?"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLumineerData()
        self.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = GlobalShareData.sharedGlobal.objCurrentLumineer.displayName
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel
        displayAdvertiseContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateCurrentHeight() {
        var tableHeight = 0
        if !isInboxCountSelected {
            tableHeight = 0
        }
        else if self.aryActivityData != nil, self.expandedSectionHeaderNumber == -1 ,(self.aryActivityData.count)>0{
            tableHeight = self.aryActivityData.count * 46
        }
        else if self.aryActivityData != nil, (self.aryActivityData.count)>0 {
            tableHeight = (self.aryActivityData.count * 46) + 64

        }
        mainViewHeights.constant
            =  (appDelegate.window?.bounds.size.height)! + lblExpandableDescription.frame.size.height + CGFloat(tableHeight)
    }
    
    func setupLumineerData() {
        var strBaseDataLogo : String? = ""
        objLumineer = GlobalShareData.sharedGlobal.objCurrentLumineer
        self.lblCompanyName.text = objLumineer.displayName
        if let data = objLumineer.detailedDescription?.count {
            self.lblExpandableDescription.text = objLumineer.detailedDescription
            lblExpandableDescription.textAlignment = .center
        }
        else {
            self.lblExpandableDescription.text = objLumineer.shortDescription
            lblExpandableDescription.textAlignment = .center
        }
        if objLumineer.status == 1 {
            strBaseDataLogo = objLumineer.enterpriseLogo
            btnFollowLumineer.isSelected = true
        }
        else {
            strBaseDataLogo = objLumineer.enterpriseLogoOpt
            btnFollowLumineer.isSelected = false
        }
        let imgThumb = UIImage.decodeBase64(strEncodeData:strBaseDataLogo)
       // let scalImg = imgThumb.af_imageScaled(to: CGSize(width: self.imgProfilePic.frame.size.width, height: self.imgProfilePic.frame.size.height))
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: self.imgProfilePic.frame.size.width-10, height: self.imgProfilePic.frame.size.height-10))

        self.imgProfilePic.image = scalImg
       // self.imgProfilePic.contentMode = .scaleAspectFill
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        
        
        let realm = try! Realm()
        objLumineer.getLumineerAllRatings() { (json) in
            self.ratingVC.rating = Double((json["finalRating"]?.intValue)!)
            try! realm.write({
                self.objLumineer.ratings = (json["finalRating"]?.intValue)!})
        }
        
//todo \(String(describing: GlobalShareData.sharedGlobal.currentUserDetails.displayName))
        objLumineer.getLumineerCompanyUnReadMessageCounts(param:["cellNumber":GlobalShareData.sharedGlobal.userCellNumber ,"lumineerName":""]) { (json) in
            let strCount = json["unreadCount"]!
            self.btnInboxCount.setTitle("\(strCount) INBOX", for: .normal)
            try! realm.write({
                self.objLumineer.unreadCount = (json["unreadCount"]?.intValue)!})
        }
        objLumineer.getLumineerCompanyFollowingCounts(){ (json) in
            let strCount = json["noOfFollowers"]!
            self.lblFollowers.text = "\(strCount) FOLLOWERS"
            try! realm.write({
                self.objLumineer.followersCount = (json["noOfFollowers"]?.intValue)!})
        }
        objLumineer.getLumineerSocialMediaDetails(){ (json) in
        }
       getLatestLumiMessages()
        self.calculateCurrentHeight()
    }
    
    @objc func getLatestLumiMessages() {
        let objLumiMessage = LumiMessage()
        let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.messageTimeStamp)
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        objLumiMessage.getLumiMessage(param: ["cellNumber":GlobalShareData.sharedGlobal.userCellNumber,"startIndex":"0","endIndex":"10000","lastViewDate":escapedString!], nParentId: GlobalShareData.sharedGlobal.objCurrentLumineer.parentid) { (objLumineer) in
            let realm = try! Realm()
            let distinctTypes = Array(Set(realm.objects(LumiMessage.self).value(forKey: "messageCategory") as! [String]))
            self.aryActivityData = []
            for objUniqueItem in distinctTypes {
                var aryLumiMessage = objLumineer.lumiMessages.filter("messageCategory = %@",objUniqueItem)
                aryLumiMessage = aryLumiMessage.sorted(byKeyPath: "id", ascending: false)

                var uniqueObjects : [LumiMessage] = [LumiMessage]()
                for obj in aryLumiMessage {
                    if obj.value(forKeyPath:"messageSubject") != nil {
                        let value = obj.value(forKeyPath:"messageSubject") as! String
                        var isContain = false
                        for newObj in uniqueObjects {
                            if newObj.messageSubject == value {
                                isContain = true
                            }
                        }
                        if !isContain {
                            uniqueObjects.append(obj)
                        }
                    }
                }
                uniqueObjects = uniqueObjects.sorted(by: { $0.id > $1.id })
                var strImageName : String!
                if uniqueObjects.count > 0 {
                    if uniqueObjects[0].isReadByLumi  {
                        strImageName = "Artboard 92xxhdpi"
                    }
                    else {
                        strImageName = "Artboard 91xxhdpi"
                    }
                    
                    let section = ["title":objUniqueItem, "text":uniqueObjects[0].messageSubject as Any,"date":Date().getFormattedDate(string: uniqueObjects[0].newsfeedPostedTime!, formatter: ""),"data":uniqueObjects,"imgName":strImageName] as [String : Any]
                    self.aryActivityData.append(section as [String : AnyObject])
                    
                }
            }
            self.tblActivityData.reloadData()
        }
    }

    //
    // MARK: ExpandableLabel Delegate
    //
    
    func willExpandLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.textAlignment = .center
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = true
        calculateCurrentHeight()
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = false
        lblExpandableDescription.numberOfLines = 2
        calculateCurrentHeight()
   }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = true
        lblExpandableDescription.numberOfLines = 2
        lblExpandableDescription.textAlignment = .center

    }


    
    //
    // MARK: Social media methods
    //

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

    //
    // MARK: Custom methods
    //
    
    func addMessgePopup(activityType:String) {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objPopupSendMessage = storyBoard.instantiateViewController(withIdentifier: "PopupSendMessage") as! PopupSendMessage
        GlobalShareData.sharedGlobal.currentScreenValue = currentScreen.messageThread.rawValue
        objPopupSendMessage.activityType = activityType
        self.objPopupSendMessage.view.cornerRadius = 10
        self.addChildViewController(self.objPopupSendMessage)
        self.objPopupSendMessage.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-340)/2, width:self.view.frame.size.width , height:340);
        self.view.addSubview(self.objPopupSendMessage.view)
        self.objPopupSendMessage.didMove(toParentViewController: self)

    }
    
    func removeMessgePopup() {
        objPopupSendMessage.view.removeFromSuperview()
    }
    @objc func handleRatingTapFrom(recognizer : UITapGestureRecognizer)
    {
        showRatingAlert(currntRating:ratingVC.rating) { (rating) in
            let param = ["rating": rating as Any,"ratingDesc":"","enterpriseId":self.objLumineer.id,"cellNumber":GlobalShareData.sharedGlobal.userCellNumber,"userName":""] as [String : Any]
            //todo \(String(describing: GlobalShareData.sharedGlobal.currentUserDetails.displayName))
            self.objLumineer.setLumineerCompanyRatings(param: param as [String : AnyObject], completionHandler: { (response) in
                self.objLumineer.getLumineerAllRatings() { (json) in
                    self.ratingVC.rating = Double((json["finalRating"]?.intValue)!)
                  let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                    hud.mode = .text
                    hud.label.text = NSLocalizedString("Rating added successfully", comment: "HUD message title")
                    hud.offset = CGPoint(x: 0.0, y: 120)
                    hud.hide(animated: true, afterDelay: 3.0)
                }
            })
            
        }
    }

    @IBAction func onBtnProductTapped(_ sender: UIButton) {
        btnProduct.isSelected = !sender.isSelected
        if btnProduct.isSelected {
            addMessgePopup(activityType:"Products")
        }else {
            removeMessgePopup()
        }
        btnProduct.isSelected = false
    }
    
    @IBAction func onBtnSupportTapped(_ sender: UIButton) {
        btnSupport.isSelected = !sender.isSelected
        if btnSupport.isSelected {
            addMessgePopup(activityType:"Support")
        }else {
            removeMessgePopup()
        }
        btnSupport.isSelected = false
    }
    @IBAction func onBtnAccountsTapped(_ sender: UIButton) {
      //  photoLibrary()
        btnAccount.isSelected = !sender.isSelected
        if btnAccount.isSelected {
            addMessgePopup(activityType:"Accounts")
        }else {
            removeMessgePopup()
        }
        btnAccount.isSelected = false
    }
    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            //myPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            myPickerController.allowsEditing = true
//            myPickerController.navigationBar.isTranslucent = false
            myPickerController.navigationBar.barTintColor = UIColor.blue // Background color
            myPickerController.navigationBar.tintColor = UIColor.white // Cancel button ~ any UITabBarButton items
            myPickerController.navigationBar.titleTextAttributes = [
                kCTForegroundColorAttributeName as NSAttributedStringKey : UIColor.white]
           self.present(myPickerController, animated: true, completion: nil) //self.navigationController?.present(myPickerController, animated: true, completion: nil)
        }
    }
    @IBAction func onBtnInboxCountTapped(_ sender: UIButton) {
       // btnInboxCount.isSelected = !sender.isSelected
        
        if !isInboxCountSelected {
            isInboxCountSelected = true
            UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                if self.aryActivityData != nil, (self.aryActivityData.count)>0{
                    self.viewActivityHeights.constant = CGFloat(self.aryActivityData.count * 46) + 30
                }
                else {
                    self.viewActivityHeights.constant = 0
                }
                self.lblActivity.isHidden = false
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.btnInboxCount.tintColor = UIColor.lightGray
                self.calculateCurrentHeight()
            })
        }else {
            isInboxCountSelected = false
            btnInboxCount.tintColor = UIColor.init(hexString: "DA1913")
            UIView.animate(withDuration: 0.6, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.viewActivityHeights.constant = 0
                self.view.layoutIfNeeded()
            },  completion: { (finished: Bool) in
                self.calculateCurrentHeight()
                self.lblActivity.isHidden = true
            })
        }
    }
    @IBAction func onBtnFollowTapped(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected = !sender.isSelected
            let companyRegistrationNumber = objLumineer.companyRegistrationNumber!
            var strUniqueID: String = GlobalShareData.sharedGlobal.userCellNumber!
            strUniqueID += "_"
            strUniqueID += companyRegistrationNumber
            let strStatus : String = sender.isSelected ? "1":"0"
            let objLumiList = LumineerList()
            DispatchQueue.global(qos: .userInitiated).async {
                objLumiList.setLumineerCompanyFollowUnFollowData(id:GlobalShareData.sharedGlobal.userCellNumber,companyregistrationnumber:companyRegistrationNumber,uniqueID: strUniqueID, status:strStatus , completionHandler: { (List) in
                    let imgThumb = UIImage.decodeBase64(strEncodeData:self.objLumineer.enterpriseLogo)
                    let scalImg = imgThumb.af_imageScaled(to: CGSize(width: self.imgProfilePic.frame.size.width-10, height: self.imgProfilePic.frame.size.height-10))
                    self.imgProfilePic.image = scalImg

                })
            }
        }
    }
    
    func displayAdvertiseContent() {
        //todo
        let realm = try! Realm()
        let result  = realm.objects(AdvertiseData.self).filter("contentType == 'Video'")
        if result.count > 0 {
            GlobalShareData.sharedGlobal.objCurrentAdv = result[0]
        }
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objAdvertiseVC = storyBoard.instantiateViewController(withIdentifier: "AdvertiseVC") as! AdvertiseVC
        self.addChildViewController(self.objAdvertiseVC)
        let height = objAdvertiseVC.setupInitialConstraints()
        self.objAdvertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:CGFloat(height));
        self.view.addSubview(self.objAdvertiseVC.view)
        self.objAdvertiseVC
            .didMove(toParentViewController: self)
    }
}

//
// MARK: Tableview Delegate & DataSource
//

extension LumineerProfileVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame

        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height))
        headerView.backgroundColor = UIColor.clear
        headerView.cornerRadius = 5

        let innerView = UIView.init(frame: CGRect(x: 0, y: 5, width: headerView.frame.size.width, height: 40))
        innerView.backgroundColor = UIColor.init(red: 238, green: 238, blue: 238)
        innerView.cornerRadius = 5
        
        let lblTitle = UILabel(frame: CGRect(x: 10, y: 5, width: innerView.frame.size.width-110, height: 16))
        lblTitle.font  = UIFont.init(name: "Helvetica-Bold", size: 14)
        lblTitle.textColor = UIColor.black
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.text = aryActivityData[section]["title"] as? String
        innerView.addSubview(lblTitle)
        
        let lblTime = UILabel(frame: CGRect(x: lblTitle.frame.size.width+2, y: 5, width: 90, height: 12))
        lblTime.font  = UIFont.init(name: "Helvetica", size: 10)
        lblTime.textColor = UIColor.lumiGray
        lblTime.backgroundColor = UIColor.clear
        lblTime.textAlignment = .center
        lblTime.text = aryActivityData[section]["date"] as? String
        innerView.addSubview(lblTime)

        
        let imgIcon = UIImageView(frame: CGRect(x: 10, y: 21, width: 16, height: 16));
        imgIcon.image = UIImage(named: aryActivityData[section]["imgName"] as! String)
        imgIcon.contentMode = .scaleAspectFit
        innerView.addSubview(imgIcon)
        
        let lblDesc = UILabel(frame: CGRect(x: 30, y: 21, width: innerView.frame.size.width-20, height: 16))
        lblDesc.font  = UIFont.init(name: "Helvetica", size: 12)
        lblDesc.textColor = UIColor.lumiGray
        lblDesc.backgroundColor = UIColor.clear
        lblDesc.text = aryActivityData[section]["text"] as? String
        innerView.addSubview(lblDesc)

        
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 20, y: 5, width: 14, height: 14));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.contentMode = .scaleAspectFit
        theImageView.tag = kHeaderSectionTag + section
        innerView.addSubview(theImageView)
        headerView.addSubview(innerView)

        // make headers touchable
        headerView.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(LumineerProfileVC.sectionHeaderWasTouched(_:)))
        headerView.addGestureRecognizer(headerTapGesture)
        return headerView
        
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        guard aryActivityData != nil else {
            return 0
        }
        return aryActivityData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            return self.aryActivityData[section]["data"]!.count;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! SubjectCell
        let sectionData = self.aryActivityData[indexPath.section]["data"] as! [LumiMessage]
        let objLumiMessage = sectionData[indexPath.row] as LumiMessage
        cell.lblSubject.text = objLumiMessage.messageSubject
        cell.lblDate.text = Date().getFormattedDate(string: objLumiMessage.newsfeedPostedTime!, formatter: "")
        cell.lblMessage.text = objLumiMessage.newsFeedBody

        if objLumiMessage.fileName == nil {
            cell.constImgWidth.constant = 0
        }
        else {
            cell.constImgWidth.constant = 25
            var urlOriginalImage : URL!
            if(objLumiMessage.fileName?.hasUrlPrefix())!
            {
                urlOriginalImage = URL.init(string: objLumiMessage.fileName!)
            }
            else {
                let fileName = objLumiMessage.fileName?.lastPathComponent
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
            }

            if objLumiMessage.contentType == "Video" && objLumiMessage.imageURL != nil {
                let fileName = objLumiMessage.imageURL
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                Alamofire.request(urlOriginalImage!).responseImage { response in
                    debugPrint(response)
                    
                    if let image = response.result.value {
                        let scalImg = image.af_imageScaled(to: CGSize(width: 25, height: 25))
                        cell.imgMessage.image = scalImg
                    }
                }
            }
            else if objLumiMessage.contentType == "Document" {
                let image = UIImage.init(named: "docFile")
                let scalImg = image?.af_imageScaled(to: CGSize(width: 25, height: 25))
                cell.imgMessage.image = scalImg
            }
            else {
                Alamofire.request(urlOriginalImage!).responseImage { response in
                    debugPrint(response)
                    
                    if let image = response.result.value {
                        let scalImg = image.af_imageScaled(to: CGSize(width: 25, height: 25))
                        cell.imgMessage.image = scalImg
                    }
                }

            }
            }
        var strImageName : String!
        
        if objLumiMessage.isReadByLumi {
            strImageName = "Artboard 92xxhdpi"
        }
        else {
            strImageName = "Artboard 91xxhdpi"
        }
        cell.imgStatus.image = UIImage(named:strImageName)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            let sectionData = self.aryActivityData[indexPath.section]["data"] as! [LumiMessage]
            let objLumiMessage = sectionData[indexPath.row] as LumiMessage
            objLumiMessage.setLumiSubjectThreadDelete(enterpriseId: objLumiMessage.enterpriseID, messageSubjectId: objLumiMessage.messageSubjectId, completionHandler: { (result) in
                if result {
                    self.getLatestLumiMessages()
                    self.calculateCurrentHeight()
                }
            })
        }
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        do {
            let headerView = sender.view
            let section    = headerView?.tag
            let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
            
            if (self.expandedSectionHeaderNumber == -1) {
                self.expandedSectionHeaderNumber = section!
                tableViewExpandSection(section!, imageView: eImageView!)
            } else {
                let cImageView = tblActivityData.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                if (self.expandedSectionHeaderNumber == section) {
                    tableViewCollapeSection(section!, imageView: eImageView)
                } else {
                    tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView)
                    tableViewExpandSection(section!, imageView: eImageView!)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView?) {
        do {
            guard section != -1 else {
                return
            }
            
            let sectionData = self.aryActivityData[section]["data"] as! [LumiMessage]
            self.expandedSectionHeaderNumber = -1;
            if (sectionData.count == 0) {
                return;
            } else {
                if imageView != nil {
                    UIView.animate(withDuration: 0.4, animations: {
                        imageView?.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
                    })
                }
                var indexesPath = [IndexPath]()
                for i in 0 ..< sectionData.count {
                    let index = IndexPath(row: i, section: section)
                    indexesPath.append(index)
                }
                self.viewActivityHeights.constant = CGFloat(self.aryActivityData.count * 46) + 30

                self.tblActivityData!.beginUpdates()
                self.tblActivityData!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
                self.tblActivityData!.endUpdates()
                calculateCurrentHeight()
                
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = botChat
        let sectionData = self.aryActivityData[indexPath.section]["data"] as! [LumiMessage]
        GlobalShareData.sharedGlobal.objCurrentLumiMessage = sectionData[indexPath.row] as LumiMessage
        GlobalShareData.sharedGlobal.currentScreenValue = currentScreen.messageThread.rawValue

        var chatVC: TGChatViewController?
            chatVC = TGChatViewController(chat: chat)
            //chatVC.

        if let vc = chatVC {
            navigationController?.pushViewController(vc, animated: true)
        }
        let sectionHeaderView = tableView.headerView(forSection: indexPath.section)
        let eImageView = sectionHeaderView?.viewWithTag(kHeaderSectionTag + indexPath.section) as? UIImageView
        let cImageView = tblActivityData.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
        if (self.expandedSectionHeaderNumber == indexPath.section) {
            tableViewCollapeSection(indexPath.section, imageView: eImageView)
        } else {
            tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView)
            tableViewExpandSection(indexPath.section, imageView: eImageView!)
        }


        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        do {
            let sectionData = self.aryActivityData[section]["data"] as! [LumiMessage]
            
            if (sectionData.count == 0) {
                self.expandedSectionHeaderNumber = -1;
                return;
            } else {
                UIView.animate(withDuration: 0.4, animations: {
                    imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
                })
                var indexesPath = [IndexPath]()
                for i in 0 ..< sectionData.count {
                    let index = IndexPath(row: i, section: section)
                    indexesPath.append(index)
                }
                self.viewActivityHeights.constant = CGFloat(self.aryActivityData.count * 46) + 100

                self.expandedSectionHeaderNumber = section
                self.tblActivityData!.beginUpdates()
                self.tblActivityData!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
                self.tblActivityData!.endUpdates()
                calculateCurrentHeight()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    //MARK: - Delegate methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true, completion: nil)
    }
    

}

let botChat: Chat = {
    let chat = Chat()
    chat.type = "bot"
    chat.targetId = "89757"
    chat.chatId = chat.type + "_" + chat.targetId
    chat.title = "Gothons From Planet Percal #25"
    chat.detail = "bot"
    return chat
}()

struct SectionData {
    let title: String
    let text: String
    let date: String
    let imgName: String
    let data : Results<LumiMessage>
    
    init(title: String,text: String,date: String, data: Results<LumiMessage>,imgName:String) {
        self.title = title
        self.text = text
        self.date = date
        self.data  = data
        self.imgName = imgName
    }
    var numberOfItems: Int {
        return data.count
    }

//    subscript(index: Int, key:Results<LumiMessage>) -> String {
//        guard let coordinate = data[index][LumiMessage] else {
//            return ""
//        }
//        return coordinate
//    }

//    subscript(index: Int) -> [String:String]? {
//        guard let coordinate = self.data[index] as! [String: String] else {
//            return nil
//        }
//        return coordinate
//    }
    
    
}
extension UIView {
    func addBlurEffect()  {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.backgroundColor = .black
        }

    }
    /// Remove UIBlurEffect from UIView
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
}

extension UIViewController {
    var appDelegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}



extension Date {
    func getFormattedTimestamp(key: UserDefaultsKeys) -> String{
        var timeStamp : String!
        let olderTimestamp = UserDefaults.standard.getStringValue(key: key) as String
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: Date())
        UserDefaults.standard.setStringValue(value: myString, key: key)
        timeStamp = olderTimestamp
        return timeStamp
    }

     func getFormattedDate(string: String , formatter:String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy HH:mm"
        let date = dateFormatterGet.date(from:string)!
        
        let calendar = Calendar.current
        
        if calendar.isDateInYesterday(date) {
            dateFormatter.dateFormat = "HH:mm a"
            let dateString = dateFormatter.string(from: date)
            return "Yesterday, \(dateString)"
        }
        else if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm a"
            let dateString = dateFormatter.string(from: date)
            return "Today, \(dateString)"

        }
        print(dateFormatter.string(from: date)) // Jan 20,2018
        return dateFormatter.string(from: date);
    }
    
    func getDateFromString(string: String , formatter:String) -> Date {
        var dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatterGet.date(from:string)!

        dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        let strDate = dateFormatterGet.string(from: date)

        return dateFormatterGet.date(from:strDate)!
    }
}


extension UserDefaults{
    
    //MARK: Check Login
    func setStringValue(value: String, key: UserDefaultsKeys) {
        set(value, forKey: key.rawValue)
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getStringValue(key: UserDefaultsKeys) -> String{
        guard ((UserDefaults.standard.value(forKey: key.rawValue) as? String) != nil) else {
           return ""
        }
        return string(forKey: key.rawValue)!
    }
    
    func setBoolValue(value: Bool, key: UserDefaultsKeys) {
        set(value, forKey:key.rawValue)
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getBoolValue(key: UserDefaultsKeys) -> Bool{
        guard ((UserDefaults.standard.value(forKey: key.rawValue) as? Bool) != nil) else {
            return false
        }
        return bool(forKey: key.rawValue)
    }


    
//    func isLoggedIn()-> Bool {
//        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
//    }
//
//    //MARK: Save User Data
//    func setUserID(value: Int){
//        set(value, forKey: UserDefaultsKeys.userID.rawValue)
//        //synchronize()
//    }
    
}
enum UserDefaultsKeys : String {
    case advertiseTimeStamp
    case messageTimeStamp
    case lumineerTimeStamp
    case supportTimeStamp
    case pendingVerification
    case isAlreadyLogin

}

enum currentScreen : String {
    case messageThread
    case supportThread
    case lumiFeed
    case lumiMessages
    case none

}

