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

class SavedDataVC: UIViewController, UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var aryActivityData: [[String:AnyObject]] = []
    let viewWelcome :  WelcomView! = nil
    var objAdvertiseVC : AdvertiseVC!

    override func viewDidLoad() {
        self.navigationItem.addBackButtonOnLeft()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.tableView!.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = UITableView.automaticDimension
        self.getSavedAdvertises()
        GlobalShareData.sharedGlobal.objCurretnVC = self
        self.navigationItem.title = "MY SAVED ADS"
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
    }


    @objc func getSavedAdvertises() {
            self.aryActivityData = []
            let realm = try! Realm()
            let result  = realm.objects(AdvertiseData.self).filter("isAdsSaved == %d",1)
            if result.count > 0 {
                for objAdv in result {
                    let creteatedData = objAdv.strAdvertiseDate
                    let cDate = Date().getCurrentUpdtedDateFromString(string: creteatedData!, formatter: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                        let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objAdv.lumineerId.int)
                        if objsLumineer.count > 0 {
                            let lumineer = objsLumineer[0]
                            let section = ["title":lumineer.name as Any,"createdTime":objAdv.updatedDate as Any, "message":objAdv as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any,"type":"adv"] as [String : Any]
                            self.aryActivityData.append(section as [String : AnyObject])
                        }
                }
            }

                if self.aryActivityData.count > 0 {
                    self.tableView.backgroundView = nil
                    let sorted = self.aryActivityData.sorted { left, right -> Bool in
                        guard let rightKey = right["message"]?.updatedDate else { return true }
                        guard let leftKey = left["message"]?.updatedDate else { return true }
                        return leftKey > rightKey
                    }
                    self.aryActivityData.removeAll()
                    self.aryActivityData.append(contentsOf: sorted)
                }
                self.tableView.reloadData()
            }
        
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.backgroundView = nil
            if self.aryActivityData.count == 0 {
                let imgBg = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
                imgBg.image = UIImage.init(named: "Asset 335")
                imgBg.contentMode = .scaleAspectFit
                self.tableView.backgroundView = imgBg;
            }
            else { self.tableView.backgroundView = nil}
        return aryActivityData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lumiFeedCell", for: indexPath) as! lumiFeedCell
        var objCellData : [String : Any]!
        objCellData = aryActivityData[indexPath.row]

        cell.lblLumineerTitle.text = objCellData["title"] as? String
        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData["profileImg"] as? String)
        let scalImg = imgThumb.af_imageAspectScaled(toFill: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))
        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;
        cell.imgRedDot.isHidden = true
            let objAdv = objCellData["message"] as? AdvertiseData
            cell.lblMessageDetails.text = objAdv?.contentTitle
            var msgCatDate = "ADS"
            msgCatDate.append(" | \(Date().getFormattedDate(string: (objAdv?.strAdvertiseDate!)!, formatter: "yyyy-MM-dd HH:mm"))")
            cell.lblMessageTime.text = msgCatDate
            let strMsgType : String!
            if objAdv?.contentType == "Video" {
                strMsgType = "Asset102"
            }
            else if objAdv?.contentType == "Audio" {
                strMsgType = "Asset104"
            }
            else {
                strMsgType = "Asset106"
            }
            cell.imgMessage.image = UIImage(named:strMsgType)
        
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        GlobalShareData.sharedGlobal.isVideoPlaying = false
        var objCellData : [String : Any]!
            objCellData = aryActivityData[indexPath.row]
        
            let objAdv = objCellData["message"] as? AdvertiseData

            GlobalShareData.sharedGlobal.objCurrentAdv = objAdv
            let realm = try! Realm()
            let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objAdv?.lumineerId.int ?? Int.self)
            if objsLumineer.count > 0 {
                let lumineer = objsLumineer[0]
                GlobalShareData.sharedGlobal.objCurrentLumineer = lumineer
            }
            self.view.addBlurEffect()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objAdvertiseVC = (storyBoard.instantiateViewController(withIdentifier: "AdvertiseVC") as! AdvertiseVC)
        self.addChild(self.objAdvertiseVC)
            self.objAdvertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:390);
            self.view.addSubview(self.objAdvertiseVC.view)
            self.objAdvertiseVC
                .didMove(toParent: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            var objCellData : [String : Any]!
                objCellData = aryActivityData[indexPath.row]
            _ = objCellData["lumineer"] as? LumineerList
            
        }
    }

}

