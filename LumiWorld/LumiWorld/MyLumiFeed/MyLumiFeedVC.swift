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

class lumiFeedCell: UITableViewCell {
    @IBOutlet var imgAerro: UIImageView!
    @IBOutlet var imgLumineerProfile: UIImageView!
    @IBOutlet var imgRedDot: UIImageView!
    @IBOutlet var lblLumineerTitle: UILabel!
    @IBOutlet var lblMessageDetails: UILabel!
    @IBOutlet var lblMessageTime: UILabel!
    
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

    override func viewDidLoad() {
        self.tabBarController?.title = "Feed"
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getLatestLumiMessages()
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = UITableViewAutomaticDimension

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
                            
                            let section = ["title":lumineer.name as Any, "text":message.messageSubject as Any,"date":Date().getFormattedDate(string: message.newsfeedPostedTime!, formatter: ""),"profileImg":lumineer.enterpriseLogo as Any] as [String : Any]
                            self.aryActivityData.append(section as [String : AnyObject])
                        }
                    }
                }
                self.tableView.reloadData()
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
        cell.lblLumineerTitle.text = objCellData["title"] as? String
        cell.lblMessageDetails.text = objCellData["text"] as? String
        cell.lblMessageTime.text = objCellData["date"] as? String
        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData["profileImg"] as? String)
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))
        cell.imgLumineerProfile.image = scalImg
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
}
