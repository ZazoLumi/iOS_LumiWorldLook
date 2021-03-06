//
//  MyLumiFeed.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import AVKit
import Alamofire
import Kingfisher
class lumiFeedCell: UITableViewCell {
    @IBOutlet var imgAerro: UIImageView!
    @IBOutlet var imgLumineerProfile: UIImageView!
    @IBOutlet var imgRedDot: UIImageView!
    @IBOutlet var lblLumineerTitle: UILabel!
    @IBOutlet var lblMessageDetails: UILabel!
    @IBOutlet var lblMessageTime: UILabel!
    @IBOutlet weak var constImgWidth: NSLayoutConstraint!
    @IBOutlet weak var imgMessage: UIImageView!
    @IBOutlet weak var constImgHeight: NSLayoutConstraint!
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.imgLumineerProfile.layer.cornerRadius = self.imgLumineerProfile.bounds.size.height/2
//        self.imgLumineerProfile.layer.borderWidth = 0.5;
//        self.imgLumineerProfile.layer.borderColor = UIColor.lumiGreen?.cgColor;
    }
}

class MyLumiFeedVC: UIViewController, UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var aryActivityData: [[String:AnyObject]] = []
    var arySearchData: [[String:AnyObject]] = []
    var strSearchText : NSString!
    let viewWelcome :  WelcomView! = nil
    var isLoadedFirstTime = false

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(MyLumiFeedVC.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.lumiGreen
        
        return refreshControl
    }()
    let searchController = UISearchController(searchResultsController: nil)
    var objAdvertiseVC : AdvertiseVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        //Static
        self.tableView.addSubview(self.refreshControl)
        self.tableView!.tableFooterView = UIView()
        isLoadedFirstTime = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = UITableView.automaticDimension
        self.getLatestLumiMessages()
        GlobalShareData.sharedGlobal.objCurretnVC = self
        self.navigationItem.title = "MY LUMI FEED"
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Feed"
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = []
        searchController.searchBar.delegate = self

    }
        
    override func viewWillDisappear(_ animated: Bool) {
        searchController.isActive = false
        self.tabBarController?.navigationItem.searchController = nil
    }


    @objc func getLatestLumiMessages() {
        let objLumiMessage = LumiMessage()
        let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.messageTimeStamp)
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        objLumiMessage.getLumiMessage(param: ["cellNumber":GlobalShareData.sharedGlobal.userCellNumber,"startIndex":"0","endIndex":"10000","lastViewDate":escapedString!], nParentId:-1) { (objLumineer) in
            let realm = try! Realm()
            self.aryActivityData = []
            let distinctTypes = Array(Set(realm.objects(LumiMessage.self).value(forKey: "messageSubjectId") as! [Int]))
            for objUniqueItem in distinctTypes {
               let result  = realm.objects(LumiCategory.self)
                for objCategory in result  {
                    for objNLumineer in objCategory.lumineerList {
                        var aryLumiMessage = objNLumineer.lumiMessages.filter("messageSubjectId = %@",objUniqueItem)
                        if aryLumiMessage.count > 0 {
                            aryLumiMessage = aryLumiMessage.sorted(byKeyPath: "id", ascending: false)
                            let message = aryLumiMessage[0]
                            try! realm.write {
                                if message.newsFeedBody == nil {
                                    message.newsFeedBody = ""
                                }
                            }

                            let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",message.enterpriseID)
                            let lumineer = objsLumineer[0]
                            let section = ["title":lumineer.name as Any,"createdTime":message.createdTime as Any, "message":message as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any,"type":"message"] as [String : Any]
                            self.aryActivityData.append(section as [String : AnyObject])
                        }
                    }
                }
            }
            let aryAdsData = GlobalShareData.sharedGlobal.getCurrentAdvertise()
            self.aryActivityData += aryAdsData

                if self.aryActivityData.count > 0 {
                    self.tableView.backgroundView = nil
                    let sorted = self.aryActivityData.sorted { left, right -> Bool in
                        guard let rightKey = right["message"]?.createdTime else { return true }
                        guard let leftKey = left["message"]?.createdTime else { return true }
                        return leftKey > rightKey
                    }
                    self.aryActivityData.removeAll()
                    self.aryActivityData.append(contentsOf: sorted)
                }
                else {

            }
            self.isLoadedFirstTime = false
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
            }
        
        }
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.backgroundView = nil
        if isFiltering() {
            if arySearchData.count == 0 && !searchBarIsEmpty() {
                let imgBg = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
                imgBg.image = UIImage.init(named: "Asset 335")
                imgBg.contentMode = .scaleAspectFit
                self.tableView.backgroundView = imgBg;
                return 0
            }
            return arySearchData.count
        }
        else {
            if self.aryActivityData.count == 0 && !isLoadedFirstTime{
                let viewWelcome = Bundle.main.loadNibNamed("WelcomView", owner:
                    self, options: nil)?.first as? WelcomView
                // self.view.addSubview(viewWelcome!)
                viewWelcome?.frame = CGRect(x:0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
                viewWelcome?.btnGetStarted.addTarget(self, action:#selector(MyLumiFeedVC.didTapGetStarted), for: .touchUpInside)
                self.tableView.backgroundView = viewWelcome
            }
            else if isLoadedFirstTime {
                let viewBg = UIView .init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
                viewBg.backgroundColor = UIColor.clear
               let dataMsgLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
                dataMsgLabel.text = "Retrieving data.\nPlease wait.."
                dataMsgLabel.numberOfLines = 0;
                dataMsgLabel.textAlignment = .center;
                dataMsgLabel.textColor = UIColor.init(hexString: "757576")
                dataMsgLabel.font = UIFont(name: "HelveticaNeue", size: 20)
                dataMsgLabel.sizeToFit()
                viewBg.addSubview(dataMsgLabel)
                self.tableView.backgroundView = dataMsgLabel;
            }
            else { self.tableView.backgroundView = nil}
        }
        strSearchText = ""
        return aryActivityData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lumiFeedCell", for: indexPath) as! lumiFeedCell
        var objCellData : [String : Any]!
        //  let section = ["title":lumineer.name as Any, "text":message.newsFeedBody as Any,"date":Date().getFormattedDate(string: message.newsfeedPostedTime!, formatter: ""),"profileImg":lumineer.enterpriseLogo as Any] as [String : Any]
        
        if isFiltering() {
            objCellData = arySearchData[indexPath.row]
        }
        else {
            objCellData = aryActivityData[indexPath.row]
        }
        cell.lblLumineerTitle.text = objCellData["title"] as? String
        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData["profileImg"] as? String)
        let scalImg = imgThumb.af_imageAspectScaled(toFill: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))

        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;
        cell.imgRedDot.isHidden = true
        if !isFiltering() && objCellData["type"] as? String == "adv" {
            let objAdv = objCellData["message"] as? AdvertiseData
            let myStr = underlinedString(string: (objAdv?.contentTitle?.htmlToString)! as NSString, term: "")
            cell.lblMessageDetails.attributedText = myStr
            var msgCatDate = "ADS"
            msgCatDate.append(" | \(Date().getFormattedDate(string: (objAdv?.strAdvertiseDate!)!, formatter: "yyyy-MM-dd HH:mm"))")
            cell.lblMessageTime.text = msgCatDate
            let imgMsgType : UIImage!
            if objAdv?.contentType == "Video" {
                imgMsgType = UIImage(named:"Asset102")
            }
            else if objAdv?.contentType == "Audio" {
                imgMsgType = UIImage(named:"Asset104")
            }
            else {
                imgMsgType = UIImage(named:"Asset106")
            }
            cell.imgMessage.image = imgMsgType
        }
        else {
            cell.imgRedDot.isHidden = false
            let message = objCellData["message"] as? LumiMessage
            let myStr = underlinedString(string: (message?.newsFeedBody?.htmlToString)! as NSString, term: strSearchText)
            cell.lblMessageDetails.attributedText = myStr
            var msgCatDate = message?.messageCategory
            msgCatDate?.append(" | \(Date().getFormattedDate(string: (message?.newsfeedPostedTime!)!, formatter: "yyyy-MM-dd HH:mm"))")
            cell.lblMessageTime.text = msgCatDate
            var strImageName : String!
            if (message?.isReadByLumi)! {
                strImageName = "Artboard 92xxhdpi"
                cell.backgroundColor = UIColor.init(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 0.8)
            }
            else {
                strImageName = "Asset714"
                cell.backgroundColor = UIColor.white
            }
            cell.imgRedDot?.image = UIImage(named:strImageName)
            if message?.fileName == nil {
                cell.constImgWidth.constant = 0
            }
            else {
                cell.constImgWidth.constant = 25
                var urlOriginalImage : URL!
                if(message?.fileName?.hasUrlPrefix())!
                {
                    let urlString = message?.fileName!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    urlOriginalImage = URL.init(string: urlString!)
                }
                else {
                    let fileName = message?.fileName?.lastPathComponent
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
                
                if message?.contentType == "Video" && message?.imageURL != nil{
                    let fileName = message?.imageURL
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    cell.imgMessage!.kf.setImage(
                        with: urlOriginalImage,
                        placeholder: nil,
                        options:[
                            
                            .cacheOriginalImage,.transition(.fade(1))
                        ],
                        progressBlock: { receivedSize, totalSize in
                    },
                        completionHandler: { result in
                            print(result)
                            let scalImg = cell.imgMessage.image?.kf.resize(to: cell.imgMessage.size, for: .aspectFill)
                            cell.imgMessage.image = scalImg
                    }
                    )
                
                }
                else if message?.contentType == "Document" {
                    let image = UIImage.init(named: "docFile")
                    let scalImg = image?.kf.resize(to: CGSize(width: 25, height: 25), for: .aspectFill)
                    cell.imgMessage.image = scalImg
                }
                else if  urlOriginalImage != nil{
                    cell.imgMessage!.kf.setImage(
                        with: urlOriginalImage,
                        placeholder: nil,
                        options:[
                            .cacheOriginalImage,.transition(.fade(1))
                        ],
                        progressBlock: { receivedSize, totalSize in
                    },
                        completionHandler: { result in
                            print(result)
                            let scalImg = cell.imgMessage!.image?.kf.resize(to: CGSize(width: 25, height: 25), for: .aspectFill)
                            cell.imgMessage.image = scalImg
                    }
                    )
                }
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = botChat
        var objCellData : [String : Any]!
        if isFiltering() {
            objCellData = arySearchData[indexPath.row]
        }
        else {
            objCellData = aryActivityData[indexPath.row]
        }
        
        if !isFiltering() && objCellData["type"] as? String == "adv" {
            let objAdv = objCellData["message"] as? AdvertiseData
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
            self.addChild(self.objAdvertiseVC)
            self.objAdvertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:390);
            self.view.addSubview(self.objAdvertiseVC.view)
            self.objAdvertiseVC
                .didMove(toParent: self)

        }
        else {
            let message = objCellData["message"] as? LumiMessage
            GlobalShareData.sharedGlobal.objCurrentLumiMessage = message
            GlobalShareData.sharedGlobal.objCurrentLumineer = objCellData["lumineer"] as? LumineerList
            GlobalShareData.sharedGlobal.currentScreenValue = currentScreen.messageThread.rawValue
            var chatVC: TGChatViewController?
            chatVC = TGChatViewController(chat: chat)
            //chatVC.
            if let vc = chatVC {
                navigationController?.pushViewController(vc, animated: true)
                }
        }
        searchController.isActive = false
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            var objCellData : [String : Any]!
            if isFiltering() {
                objCellData = arySearchData[indexPath.row]
            }
            else {
                objCellData = aryActivityData[indexPath.row]
            }
            let lunmineer = objCellData["lumineer"] as? LumineerList
            let objLumiMessage = LumiMessage()
            objLumiMessage.setLumineerThreadDelete(regnNumber: (lunmineer?.companyRegistrationNumber)!) { (result) in
                if result {
                    self.getLatestLumiMessages()
                }
            }
        }
    }

    
    func underlinedString(string: NSString, term: NSString) -> NSAttributedString {
        let output = NSMutableAttributedString(string: string as String)
        let underlineRange = string.range(of: term as String, options: .caseInsensitive)
        output.addAttribute(kCTUnderlineStyleAttributeName as NSAttributedString.Key, value:0, range: NSMakeRange(0, string.length))
        output.addAttribute(kCTUnderlineStyleAttributeName as NSAttributedString.Key, value: NSUnderlineStyle.single.rawValue, range: underlineRange)
        output.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lumiGreen as Any, range: underlineRange)
        return output
    }

    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumiMessages()
    }
    
   @objc func didTapGetStarted() {
        self.tabBarController?.selectedIndex = 2
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        strSearchText = searchText as NSString
        guard strSearchText.length != 0 else {
            arySearchData = aryActivityData
            self.tableView.reloadData()
            return
        }
        arySearchData = []
        let realm = try! Realm()
        let distinctTypes = Array(Set(realm.objects(LumiMessage.self).value(forKey: "messageSubjectId") as! [Int]))
        for objUniqueItem in distinctTypes {
            let result  = realm.objects(LumiCategory.self)
            for objCategory in result  {
                for objNLumineer in objCategory.lumineerList {
                    var aryLumiMessage = objNLumineer.lumiMessages.filter("messageSubjectId = %@",objUniqueItem).filter("newsFeedBody CONTAINS[c] '\(searchText)'")
                    
                    if aryLumiMessage.count > 0 {
                        aryLumiMessage = aryLumiMessage.sorted(byKeyPath: "id", ascending: false)
                        let message = aryLumiMessage[0]
                        let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",message.enterpriseID)
                        let lumineer = objsLumineer[0]
                        let section = ["title":lumineer.name as Any, "message":message as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any] as [String : Any]

                        self.arySearchData.append(section as [String : AnyObject])
                    }
                }
            }
            self.tableView.reloadData()
        }
        if self.arySearchData.count == 0 {
            self.tableView.reloadData()
        }
    }
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }

}
@available(iOS 11.0, *)
extension MyLumiFeedVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}



@available(iOS 11.0, *)
extension MyLumiFeedVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        _ = searchController.searchBar
       // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: "")
    }
}
extension NSMutableAttributedString
{
    
    
    func changeWordsColour(terms:[NSString])
    {
        let string = self.string as NSString
        self.addAttribute(kCTForegroundColorAttributeName as NSAttributedString.Key, value: UIColor.brown, range: NSMakeRange(0, self.length))
        for term in terms
        {
            let underlineRange = string.range(of: term as String)
            self.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: underlineRange)
            
        }
    }
}

