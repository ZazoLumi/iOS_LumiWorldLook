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
        self.imgLumineerProfile.layer.cornerRadius = self.imgLumineerProfile.bounds.size.height/2
        self.imgLumineerProfile.layer.borderWidth = 0.5;
        self.imgLumineerProfile.layer.borderColor = UIColor.clear.cgColor;
    }

}

class MyLumiFeedVC: UIViewController, UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var aryActivityData: [[String:AnyObject]] = []
    var arySearchData: [[String:AnyObject]] = []
    var strSearchText : NSString!
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(MyLumiFeedVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lumiGreen
        
        return refreshControl
    }()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        self.navigationItem.addSettingButtonOnRight()
        self.tableView.addSubview(self.refreshControl)

    }
    override func viewWillAppear(_ animated: Bool) {
        self.getLatestLumiMessages()
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = UITableViewAutomaticDimension
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        GlobalShareData.sharedGlobal.objCurretnVC = self
        self.navigationItem.title = "MY LUMI FEED"

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
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
            let distinctTypes = Array(Set(realm.objects(LumiMessage.self).value(forKey: "enterpriseID") as! [Int]))
            self.aryActivityData = []
            for objUniqueItem in distinctTypes {
               let result  = realm.objects(LumiCategory.self)
                for objCategory in result  {
                    for objNLumineer in objCategory.lumineerList {
                        var aryLumiMessage = objNLumineer.lumiMessages.filter("enterpriseID = %@",objUniqueItem)
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
                            let section = ["title":lumineer.name as Any, "message":message as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any] as [String : Any]
                            self.aryActivityData.append(section as [String : AnyObject])
                        }
                    }
                }
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
            self.tableView.reloadData()
        }
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return arySearchData.count
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
        
        let message = objCellData["message"] as? LumiMessage



        cell.lblLumineerTitle.text = objCellData["title"] as? String

        let myStr = underlinedString(string: (message?.newsFeedBody)! as NSString, term: strSearchText)
        cell.lblMessageDetails.attributedText = myStr
        var msgCatDate = message?.messageCategory
        msgCatDate?.append(" | \(Date().getFormattedDate(string: (message?.newsfeedPostedTime!)!, formatter: ""))")
        cell.lblMessageTime.text = msgCatDate
        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData["profileImg"] as? String)
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))
        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;
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
                urlOriginalImage = URL.init(string: (message?.fileName!)!)
            }
            else {
                let fileName = message?.fileName?.lastPathComponent
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
            }
            
            if message?.contentType == "Video" && message?.imageURL != nil{
                let fileName = message?.imageURL
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                Alamofire.request(urlOriginalImage!).responseImage { response in
                    debugPrint(response)
                    
                    if let image = response.result.value {
                        let scalImg = image.af_imageScaled(to: CGSize(width: 25, height: 25))
                        cell.imgMessage.image = scalImg
                    }
                }
            }
            else if message?.contentType == "Document" {
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
//            self.catNames.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    
    func underlinedString(string: NSString, term: NSString) -> NSAttributedString {
        let output = NSMutableAttributedString(string: string as String)
        let underlineRange = string.range(of: term as String, options: .caseInsensitive)
        output.addAttribute(kCTUnderlineStyleAttributeName as NSAttributedStringKey, value: NSUnderlineStyle.styleNone.rawValue, range: NSMakeRange(0, string.length))
        output.addAttribute(kCTUnderlineStyleAttributeName as NSAttributedStringKey, value: NSUnderlineStyle.styleSingle.rawValue, range: underlineRange)
        output.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lumiGreen as Any, range: underlineRange)
        return output
    }

    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumiMessages()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        strSearchText = searchText as NSString
        arySearchData = []
        let realm = try! Realm()
        let distinctTypes = Array(Set(realm.objects(LumiMessage.self).value(forKey: "enterpriseID") as! [Int]))
        for objUniqueItem in distinctTypes {
            let result  = realm.objects(LumiCategory.self)
            for objCategory in result  {
                for objNLumineer in objCategory.lumineerList {
                    var aryLumiMessage = objNLumineer.lumiMessages.filter("enterpriseID = %@",objUniqueItem).filter("newsFeedBody CONTAINS[c] '\(searchText)'")
                    
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
        let searchBar = searchController.searchBar
       // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: "")
    }
}
extension NSMutableAttributedString
{
    
    
    func changeWordsColour(terms:[NSString])
    {
        let string = self.string as NSString
        self.addAttribute(kCTForegroundColorAttributeName as NSAttributedStringKey, value: UIColor.brown, range: NSMakeRange(0, self.length))
        for term in terms
        {
            let underlineRange = string.range(of: term as String)
            self.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: underlineRange)
            
        }
    }
}

