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
        self.tableView.addSubview(self.refreshControl)

    }
    override func viewWillAppear(_ animated: Bool) {
        self.getLatestLumiMessages()
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = UITableViewAutomaticDimension
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes

        self.navigationItem.title = "Feed"

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
                            let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",message.enterpriseID)
                            let lumineer = objsLumineer[0]
                            
                          //  let section = ["title":lumineer.name as Any, "text":message.newsFeedBody as Any,"date":Date().getFormattedDate(string: message.newsfeedPostedTime!, formatter: ""),"profileImg":lumineer.enterpriseLogo as Any] as [String : Any]
                            let section = ["title":lumineer.name as Any, "message":message as Any,"profileImg":lumineer.enterpriseLogo as Any] as [String : Any]

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
        return aryActivityData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lumiFeedCell", for: indexPath) as! lumiFeedCell
        let objCellData = aryActivityData[indexPath.row]
        //  let section = ["title":lumineer.name as Any, "text":message.newsFeedBody as Any,"date":Date().getFormattedDate(string: message.newsfeedPostedTime!, formatter: ""),"profileImg":lumineer.enterpriseLogo as Any] as [String : Any]
        
        let message = objCellData["message"] as? LumiMessage

        cell.lblLumineerTitle.text = objCellData["title"] as? String
        cell.lblMessageDetails.text = message?.newsFeedBody
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
        }
        else {
            strImageName = "Artboard 91xxhdpi"
        }
        cell.imgRedDot?.image = UIImage(named:strImageName)

        if message?.fileName == nil {
            cell.constImgWidth.constant = 0
        }
        else {
            cell.constImgWidth.constant = 25
            let urlOriginalImage : URL!
            if(message?.fileName?.hasUrlPrefix())!
            {
                urlOriginalImage = URL.init(string: (message?.fileName!)!)
            }
            else {
                let fileName = message?.fileName?.lastPathComponent
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
            }
            
            if message?.contentType == "Video" {
                DispatchQueue.main.async {
                    let asset = AVAsset(url: urlOriginalImage!)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    let time = CMTimeMake(1, 20)
                    let imageRef = try! imageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail1 = UIImage(cgImage:imageRef)
                    let scalImg = thumbnail1.af_imageScaled(to: CGSize(width: 25, height: 25))
                    cell.imgMessage.image = scalImg
                }
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
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumiMessages()
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
       /* arySearchLumineer = []
            let realm = try! Realm()
            let realmObjects = realm.objects(LumiCategory.self)
            let result = realmObjects.filter("ANY lumineerList.status == 1")
            if result.count > 0 {
                for objCategory in result{
                    for lumineer in objCategory.lumineerList.filter("status == 1") {
                        let  objLumineer = lumineer as LumineerList
                        arySearchLumineer.append(objLumineer)
                        // do something with your vegan meal
                    }
                    
                }
            }
        }
        else {
            let realm = try! Realm()
            let realmObjects = realm.objects(LumiCategory.self)
            let result = realmObjects.filter("ANY lumineerList.name CONTAINS[cd] '\(searchText)'")
            if result.count > 0 {
                let objCategory = result[0] as LumiCategory
                for lumineer in objCategory.lumineerList.filter("name CONTAINS[cd] '\(searchText)'") {
                    let  objLumineer = lumineer as LumineerList
                    arySearchLumineer.append(objLumineer)
                }
            }
        tableView.reloadData()*/
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
