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

class SubjectCell: UITableViewCell {
    @IBOutlet weak var imgStatus: UIImageView!
    
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgMessage: UIImageView!
    @IBOutlet weak var constImgWidth: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgMessage.layer.cornerRadius = self.imgMessage.bounds.size.height * 0.50
        self.imgMessage.layer.borderWidth = 0.5;
        self.imgMessage.layer.borderColor = UIColor.clear.cgColor;
        
    }
    
    
}

class LumineerProfileVC: UIViewController,ExpandableLabelDelegate {
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
        lblExpandableDescription.setLessLinkWith(lessLink: "Close", attributes: [.foregroundColor:UIColor.red], position: .left)
        
        lblExpandableDescription.shouldCollapse = true
        lblExpandableDescription.textReplacementType = .word
        lblExpandableDescription.numberOfLines = 2
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleRatingTapFrom(recognizer:)))
        self.ratingVC.addGestureRecognizer(tapGestureRecognizer)
        self.ratingVC.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLumineerData()
        self.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = GlobalShareData.sharedGlobal.objCurrentLumineer.name
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel


    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func calculateCurrentHeight() {
        var tableHeight = 0
        if !btnInboxCount.isSelected {
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
        objLumineer = GlobalShareData.sharedGlobal.objCurrentLumineer
        let imgThumb = UIImage.decodeBase64(strEncodeData:objLumineer.enterpriseLogo)
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: self.imgProfilePic.frame.size.width-10, height: self.imgProfilePic.frame.size.height-10))
        self.imgProfilePic.image = scalImg
        self.lblCompanyName.text = objLumineer.name
        if let data = objLumineer.detailedDescription?.count {
            self.lblExpandableDescription.text = objLumineer.detailedDescription
        }
        else {
            self.lblExpandableDescription.text = objLumineer.shortDescription
        }
        viewActivityHeights.constant = 0
        lblActivity.isHidden = true
        if objLumineer.status == 1 {
            btnFollowLumineer.isSelected = true
        }
        else {
            btnFollowLumineer.isSelected = false
        }

//        let insets: UIEdgeInsets = UIEdgeInsetsMake(-10, 0, 0, 0)
//        let alignedImage = UIImage(named: "Artboard 142xxxhdpi")?.withAlignmentRectInsets(insets)
//        self.navigationController?.navigationBar.backIndicatorImage = alignedImage
//        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = alignedImage
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
            self.btnInboxCount.setTitle("\(strCount) Count", for: .normal)
            try! realm.write({
                self.objLumineer.unreadCount = (json["unreadCount"]?.intValue)!})
        }
        objLumineer.getLumineerCompanyFollowingCounts(){ (json) in
            let strCount = json["noOfFollowers"]!
            self.lblFollowers.text = "\(strCount) Followers"
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
        objLumiMessage.getLumiMessage(param: ["cellNumber":GlobalShareData.sharedGlobal.userCellNumber,"startIndex":"0","endIndex":"10000","lastViewDate":escapedString!]) { (objLumineer) in
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
                    
                    let section = ["title":objUniqueItem, "text":uniqueObjects[0].messageSubject,"date":Date().getFormattedDate(string: uniqueObjects[0].newsfeedPostedTime!, formatter: ""),"data":uniqueObjects,"imgName":strImageName] as [String : Any]
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
        objPopupSendMessage.activityType = activityType
        self.objPopupSendMessage.view.cornerRadius = 10
        self.addChildViewController(self.objPopupSendMessage)
        self.objPopupSendMessage.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-340)/2, width:self.view.frame.size.width , height:340);                             self.view.addSubview(self.objPopupSendMessage.view)
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
        btnAccount.isSelected = !sender.isSelected
        if btnAccount.isSelected {
            addMessgePopup(activityType:"Accounts")
        }else {
            removeMessgePopup()
        }
        btnAccount.isSelected = false
    }
    @IBAction func onBtnInboxCountTapped(_ sender: UIButton) {
        btnInboxCount.isSelected = !sender.isSelected
        
        if btnInboxCount.isSelected {
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
                self.calculateCurrentHeight()
            })
        }else {
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
        sender.isSelected = !sender.isSelected
        let companyRegistrationNumber = objLumineer.companyRegistrationNumber!
        var strUniqueID: String = GlobalShareData.sharedGlobal.userCellNumber!
        strUniqueID += "_"
        strUniqueID += companyRegistrationNumber
        let strStatus : String = sender.isSelected ? "1":"0"
        let objLumiList = LumineerList()
        DispatchQueue.global(qos: .userInitiated).async {
            objLumiList.setLumineerCompanyFollowUnFollowData(id:GlobalShareData.sharedGlobal.userCellNumber,companyregistrationnumber:companyRegistrationNumber,uniqueID: strUniqueID, status:strStatus , completionHandler: { (List) in
            })
        }
        
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
        lblTitle.text = aryActivityData[section]["title"] as! String
        innerView.addSubview(lblTitle)
        
        let lblTime = UILabel(frame: CGRect(x: lblTitle.frame.size.width+2, y: 5, width: 90, height: 12))
        lblTime.font  = UIFont.init(name: "Helvetica", size: 10)
        lblTime.textColor = UIColor.lumiGray
        lblTime.backgroundColor = UIColor.clear
        lblTime.textAlignment = .center
        lblTime.text = aryActivityData[section]["date"] as! String
        innerView.addSubview(lblTime)

        
        let imgIcon = UIImageView(frame: CGRect(x: 10, y: 21, width: 16, height: 16));
        imgIcon.image = UIImage(named: aryActivityData[section]["imgName"] as! String)
        imgIcon.contentMode = .scaleAspectFit
        innerView.addSubview(imgIcon)
        
        let lblDesc = UILabel(frame: CGRect(x: 30, y: 21, width: innerView.frame.size.width-20, height: 16))
        lblDesc.font  = UIFont.init(name: "Helvetica", size: 12)
        lblDesc.textColor = UIColor.lumiGray
        lblDesc.backgroundColor = UIColor.clear
        lblDesc.text = aryActivityData[section]["text"] as! String
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
            let urlOriginalImage = URL.init(string: objLumiMessage.fileName!)
            Alamofire.request(urlOriginalImage!).responseImage { response in
                debugPrint(response)
                
                if let image = response.result.value {
                    let scalImg = image.af_imageScaled(to: CGSize(width: 25, height: 25))
                    cell.imgMessage.image = scalImg
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

        var chatVC: UIViewController?
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
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
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
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
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
    case messageTimeStamp
    case lumineerTimeStamp
    case pendingVerification
}

