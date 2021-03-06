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
protocol ScrollContentSize : class {
    func changeScrollContentSize(_ heiht: Int)
    func resetScrollContentOffset()
}


class LumineerProfileVC: UIViewController,ExpandableLabelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate, ScrollContentSize  {
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
    var objLumineerHomeVC : LumineerHomeVC!
    

    var isInboxCountSelected = false
    
    @IBOutlet weak var lblActivity: UIView!
    @IBOutlet weak var viewActivityHeights: NSLayoutConstraint!
    @IBOutlet weak var btnFollowLumineer: UIButton!
    @IBOutlet weak var mainViewHeights: NSLayoutConstraint!
    var objPopupSendMessage : PopupSendMessage! = nil
    var isVLoaded = false
    private var pageController: UIPageViewController!
    private var arrPageTexts:[UIViewController] = []
    private var currentPage: Int!
    
    @IBOutlet var segmentedControlView : UIView!
    @IBOutlet var scrollContentView : UIScrollView!

    var segmentedControl: CustomSegmentedContrl!

    //
    // MARK: Lifecycle methods
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.addBackButtonOnLeft()
        
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
        //viewActivityHeights.constant = 0
//        lblActivity.isHidden = true
//        lblLumiProfileTxt.text =  "Hi \(GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!), how can we help you?"
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
        GlobalShareData.sharedGlobal.objCurretnVC = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isVLoaded {
            isVLoaded = true
            setupSegmentData() }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func setupSegmentData() {
        segmentedControl = CustomSegmentedContrl.init(frame: CGRect.init(x: 10, y: 0, width: UIScreen.main.bounds.width + 450, height: segmentedControlView.frame.size.height))
        segmentedControl.backgroundColor = .clear
        segmentedControl.commaSeperatedButtonTitles = "HOME,KLEENSLATE, MYWORKPLACE,MESSAGE,ADS,SHOP,SCHEDULER,COLLABS"
        segmentedControl.addTarget(self, action: #selector(onChangeOfSegment(_:)), for: .valueChanged)
        currentPage = 0
        segmentedControlView.addSubview(segmentedControl)

        createPageViewController()
    }
    
    private func createPageViewController() {
        
        pageController = UIPageViewController.init(transitionStyle: UIPageViewController.TransitionStyle.scroll, navigationOrientation: UIPageViewController.NavigationOrientation.horizontal, options: nil)
        
        pageController.view.backgroundColor = UIColor.clear
        pageController.delegate = self
        pageController.dataSource = self
        
        if let scrollView = pageController.view.subviews.filter({$0.isKind(of: UIScrollView.self)}).first as? UIScrollView {
            scrollView.isScrollEnabled = false
        }
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pageController.view.frame = CGRect(x: 0, y: 5, width: UIScreen.main.bounds.width, height: 5000)
        }
        
        // arrPageTexts = [vc1, vc2, vc3]
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objLumineerHomeVC = storyBoard.instantiateViewController(withIdentifier: "LumineerHomeVC") as? LumineerHomeVC
     
        let objLumineerMessageVC = storyBoard.instantiateViewController(withIdentifier: "LumineerMessagesVC") as! LumineerMessagesVC
        
        let objLumineerAdvertiseVC = storyBoard.instantiateViewController(withIdentifier: "LumineerAdvertiseVC") as! LumineerAdvertiseVC
        
        let objCoomingsoon = storyBoard.instantiateViewController(withIdentifier: "coomingsoon") as! coomingsoon

        GlobalShareData.sharedGlobal.sagmentViewHeight = Int(scrollContentView.frame.size.height)
        objLumineerMessageVC.delegate = self
        objLumineerAdvertiseVC.delegate = self
        objLumineerHomeVC.delegate = self

        arrPageTexts.append(objLumineerHomeVC)
        arrPageTexts.append(objCoomingsoon)
        arrPageTexts.append(objCoomingsoon)
        arrPageTexts.append(objLumineerMessageVC)
        arrPageTexts.append(objLumineerAdvertiseVC)
        arrPageTexts.append(objCoomingsoon)
        arrPageTexts.append(objCoomingsoon)
        arrPageTexts.append(objCoomingsoon)
        pageController.setViewControllers([objLumineerHomeVC], direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
        
        self.addChild(pageController)
        scrollContentView.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        
    }
    
    private func indexofviewController(viewCOntroller: UIViewController) -> Int {
        if(arrPageTexts .contains(viewCOntroller)) {
            return arrPageTexts.firstIndex(of: viewCOntroller)!
        }
        return -1
    }
    
    //MARK: - Pagination Delegate Methods
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = indexofviewController(viewCOntroller: viewController)
        if(index != -1) {
            index = index - 1
        }
        if(index < 0) {
            return nil
        }
        else {
            return arrPageTexts[index]
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = indexofviewController(viewCOntroller: viewController)
        if(index != -1) {
            index = index + 1
        }
        if(index >= arrPageTexts.count) {
            return nil
        }
        else {
            return arrPageTexts[index]
        }
    }
    
    func pageViewController(_ pageViewController1: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if(completed) {
            currentPage = arrPageTexts.firstIndex(of: (pageViewController1.viewControllers?.last)!)
            self.segmentedControl.updateSegmentedControlSegs(index: currentPage)
        }
    }
    
    @objc func onChangeOfSegment(_ sender: CustomSegmentedContrl) {
        switch sender.selectedSegmentIndex {
        case 0:
            pageController.setViewControllers([arrPageTexts[0]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
            currentPage = 0
        case 1:
            if currentPage > 1{
                pageController.setViewControllers([arrPageTexts[1]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
                currentPage = 1
            }else{
                pageController.setViewControllers([arrPageTexts[1]], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
                currentPage = 1
            }
        case 2:
            if currentPage < 2 {
                pageController.setViewControllers([arrPageTexts[2]], direction: UIPageViewController.NavigationDirection.forward, animated: true, completion: nil)
                currentPage = 2
            }else{
                pageController.setViewControllers([arrPageTexts[2]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
                currentPage = 2
            }
        case 3:
            pageController.setViewControllers([arrPageTexts[3]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
            currentPage = 3
        case 4:
            pageController.setViewControllers([arrPageTexts[4]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
            currentPage = 4
        case 5:
            pageController.setViewControllers([arrPageTexts[5]], direction: UIPageViewController.NavigationDirection.reverse, animated: true, completion: nil)
            currentPage = 5
        default:
            break
        }
    }

    func changeScrollContentSize(_ heiht: Int) {
        scrollContentView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(heiht))
        if currentPage != 0 {
            let viewCtrl = arrPageTexts[currentPage] as UIViewController
            viewCtrl.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: viewCtrl.view.frame.size.height)
        }
//        self.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(heiht))
     //   self.pageController.view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(heiht))

    }
    
    func resetScrollContentOffset() {
        self.scrollContentView.contentOffset = .zero
        scrollContentView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.pageController.view.frame.size.height)
        
    }

    func calculateCurrentHeight() {
        mainViewHeights.constant
            =  (appDelegate.window?.bounds.size.height)! + lblExpandableDescription.frame.size.height
//        print(scrollContentView.frame)
//        scrollContentView.frame = CGRect(x: 0, y: 0, width: scrollContentView.frame.size.width, height: scrollContentView.frame.size.height)
//        print(scrollContentView.frame)

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
        let scalImg = imgThumb.af_imageAspectScaled(toFill: CGSize(width: self.imgProfilePic.frame.size.width, height: self.imgProfilePic.frame.size.height))

        self.imgProfilePic.image = scalImg
         self.imgProfilePic.contentMode = .scaleAspectFill
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style:.plain, target: nil, action: nil)
        
        
        let realm = try! Realm()
        objLumineer.getLumineerAllRatings() { (json) in
            self.ratingVC.rating = Double((json["finalRating"]?.intValue)!)
            try! realm.write({
                self.objLumineer.ratings = (json["finalRating"]?.intValue)!})
        }
        
        //todo \(String(describing: GlobalShareData.sharedGlobal.currentUserDetails.displayName))
        objLumineer.getLumineerCompanyUnReadMessageCounts(param:["cellNumber":GlobalShareData.sharedGlobal.userCellNumber ,"lumineerName":objLumineer.displayName!]) { (json) in
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
        //getLatestLumiMessages()
        //self.calculateCurrentHeight()
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
        mainViewHeights.constant = 230
        //calculateCurrentHeight()
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
                    hud.label.font = UIFont.init(name: "HelveticaNeue", size: 14)
                    hud.offset = self.view.center
                    hud.hide(animated: true, afterDelay: 3.0)
                }
            })
            
        }
    }
    
    @IBAction func onBtnInboxCountTapped(_ sender: UIButton) {
        // btnInboxCount.isSelected = !sender.isSelected
        self.tabBarController?.selectedIndex = 1
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
                    let scalImg = imgThumb.af_imageAspectScaled(toFill: CGSize(width: self.imgProfilePic.frame.size.width, height: self.imgProfilePic.frame.size.height))

                    self.imgProfilePic.image = scalImg
                    
                })
            }
        }
    }
    
    func displayAdvertiseContent() {
        //todo
        let aryAdsData = GlobalShareData.sharedGlobal.getCurrentAdvertise()
        for object in aryAdsData {
            let lumineerId = object["lumineerId"] as! Int
            if lumineerId == GlobalShareData.sharedGlobal.objCurrentLumineer.id {
                GlobalShareData.sharedGlobal.objCurrentAdv = object["message"] as? AdvertiseData
                self.view.addBlurEffect()
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                objAdvertiseVC = storyBoard.instantiateViewController(withIdentifier: "AdvertiseVC") as? AdvertiseVC
                self.addChild(self.objAdvertiseVC)
                self.objAdvertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:390);
                self.view.addSubview(self.objAdvertiseVC.view)
                self.objAdvertiseVC
                    .didMove(toParent: self)
                break
                
            }
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
        if !UIAccessibility.isReduceTransparencyEnabled {
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
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
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
    
    func getFormattedUCTimestamp(key: UserDefaultsKeys) -> String{
        var timeStamp : String!
        let olderTimestamp = UserDefaults.standard.getStringValue(key: key) as String
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let myString = formatter.string(from: Date())
        UserDefaults.standard.setStringValue(value: myString, key: key)
        timeStamp = olderTimestamp
        return timeStamp
    }
    
    func getFormattedDate(string: String , formatter:String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy HH:mm"
        let date = dateFormatterGet.date(from:string)
        guard date != nil else {
            return ""
        }
        let calendar = Calendar.current
        
        if calendar.isDateInYesterday(date!) {
            dateFormatter.dateFormat = "HH:mm a"
            let dateString = dateFormatter.string(from: date!)
            return "Yesterday, \(dateString)"
        }
        else if calendar.isDateInToday(date!) {
            dateFormatter.dateFormat = "HH:mm a"
            let dateString = dateFormatter.string(from: date!)
            return "Today, \(dateString)"
            
        }
        print(dateFormatter.string(from: date!)) // Jan 20,2018
        return dateFormatter.string(from: date!);
    }
    
    func getDateFromString(strCurrentDate: String, curFormatter:String, expFormatter:String) -> Date {
        var dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = curFormatter
        let date = dateFormatterGet.date(from:strCurrentDate)!
        
        dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = expFormatter
        let strDate = dateFormatterGet.string(from: date)
        
        return dateFormatterGet.date(from:strDate)!
    }
    
    func getCurrentUpdtedDateFromString(string: String , formatter:String) -> Date {
        let cDate = Date()
        let tempformatter = DateFormatter()
        tempformatter.dateFormat = "yyyy-MM-dd"
        let result = tempformatter.string(from: cDate)
        
        let arycom = string.components(separatedBy: " ")
        if arycom.count == 2 {
            let newString = "\(result) \(arycom.last!)"
            
            var dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm"
            let date = dateFormatterGet.date(from:newString)!
            
            dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = formatter
            let strDate = dateFormatterGet.string(from: date)
            return dateFormatterGet.date(from:strDate)!
        }
        return Date()
    }
}

extension UserDefaults {
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
}

enum UserDefaultsKeys : String {
    case gallaryTimeStamp
    case contentTimeStamp
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

extension Date {
    func secondsFromBeginningOfTheDay() -> TimeInterval {
        let calendar = Calendar.current
        // omitting fractions of seconds for simplicity
        let dateComponents = calendar.dateComponents([.hour, .minute, .second], from: self)
        
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60 + dateComponents.second!
        
        return TimeInterval(dateSeconds)
    }
    
    // Interval between two times of the day in seconds
    func timeOfDayInterval(toDate date: Date) -> TimeInterval {
        let date1Seconds = self.secondsFromBeginningOfTheDay()
        let date2Seconds = date.secondsFromBeginningOfTheDay()
        return date2Seconds - date1Seconds
    }
}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

