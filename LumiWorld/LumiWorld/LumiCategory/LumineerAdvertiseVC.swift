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

class AdevertiseCell : UITableViewCell {
    @IBOutlet weak var lblAdvTitle: UILabel!
    @IBOutlet weak var lblAdvPostedTime: UILabel!
    
    @IBOutlet weak var imgAdvType: UIImageView!
    @IBOutlet weak var lblLumineerName: UILabel!
    @IBOutlet weak var imgLumineerProfile: UIImageView!
    @IBOutlet weak var imgAdsContent: UIImageView!
    @IBOutlet weak var imgPlayIcon: UIImageView!

}
class LumineerAdvertiseVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var aryAdvertiseData: [[String:AnyObject]] = []
    var objAdvertiseVC : AdvertiseVC!
    weak var delegate: ScrollContentSize?

    override func viewDidLoad() {
        super.viewDidLoad()
        aryAdvertiseData = []
        self.getLatestLumineersAds()
        self.tableView!.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.isScrollEnabled = false
        delegate?.changeScrollContentSize((self.aryAdvertiseData.count*161)+50)
    }
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.resetScrollContentOffset()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func getLatestLumineersAds() {
        aryAdvertiseData = GlobalShareData.sharedGlobal.geCurrentLumineersAdvertise()
        let sorted = aryAdvertiseData.sorted { left, right -> Bool in
            guard let rightKey = right["message"]?.updatedDate else { return true }
            guard let leftKey = left["message"]?.updatedDate else { return true }
            return leftKey > rightKey
        }
        self.aryAdvertiseData.removeAll()
        self.aryAdvertiseData.append(contentsOf: sorted)
        self.tableView.reloadData()
        delegate?.changeScrollContentSize((self.aryAdvertiseData.count*161)+50)

    }
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryAdvertiseData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AdevertiseCell", for: indexPath) as! AdevertiseCell
        var objCellData : [String : Any]!
        
            objCellData = aryAdvertiseData[indexPath.row]
        cell.lblLumineerName.text = objCellData["title"] as? String
        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData["profileImg"] as? String)
        let scalImg = imgThumb.af_imageAspectScaled(toFill: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))

        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;

        let objAdv = objCellData["message"] as? AdvertiseData
//        if let strAdDate = objAdv?.strAdvertiseDate {
//            cell.lblAdvPostedTime.text = Date().getFormattedDate(string: strAdDate, formatter: "") }
        cell.lblAdvTitle.text = objAdv?.contentTitle

        let imgMsgType : UIImage!
        var urlOriginalImage : URL? = nil
        
        if objAdv?.contentType == "Video" {
            cell.imgPlayIcon.isHidden = false
            if objAdv?.adFilePath != nil {
                if(objAdv?.adFilePath?.hasUrlPrefix())!
                {
                    urlOriginalImage = URL.init(string: (objAdv?.adFilePath!)!)
                }
                else {
                    var fileName = objAdv?.adFileName?.replacingOccurrences(of: " ", with: "-")
                    _ = fileName?.pathExtension
                    let pathPrefix = fileName?.deletingPathExtension
                    fileName = "\(pathPrefix!).png"
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
            }
            imgMsgType = UIImage(named:"Asset102")
        }
        else if objAdv?.contentType == "Audio" {
            cell.imgPlayIcon.isHidden = false
            imgMsgType = UIImage(named:"Asset104")
        }
        else {
            cell.imgPlayIcon.isHidden = true
            if objAdv?.adFilePath != nil {
                if(objAdv?.adFilePath?.hasUrlPrefix())!
                {
                    urlOriginalImage = URL.init(string: (objAdv?.adFilePath!)!)
                }
                else {
                    let fileName = objAdv?.adFileName?.replacingOccurrences(of: " ", with: "-")
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
            }
            imgMsgType = UIImage(named:"Asset106")
            cell.imgAdvType.image = imgMsgType
        }
        cell.imgAdsContent.contentMode = .scaleAspectFit
        cell.lblAdvPostedTime.text = Date().getFormattedDate(string: (objAdv?.strAdvertiseDate!)!, formatter: "yyyy-MM-dd HH:mm")
        
        if urlOriginalImage != nil {
            Alamofire.request(urlOriginalImage!).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    let scalImg = image.af_imageAspectScaled(toFill: CGSize(width: cell.imgAdsContent.size.width, height: cell.imgAdsContent.size.height))
                    UIView.animate(withDuration: 1.0, animations: {
                        cell.imgAdsContent.image = scalImg
                    })

                }
            }}
        
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var objCellData : [String : Any]!
            objCellData = aryAdvertiseData[indexPath.row]
        
            let objAdv = objCellData["message"] as? AdvertiseData
            GlobalShareData.sharedGlobal.isVideoPlaying = false
            GlobalShareData.sharedGlobal.objCurrentAdv = objAdv
            let realm = try! Realm()
            let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objAdv?.lumineerId.int ?? Int.self)
            if objsLumineer.count > 0 {
                let lumineer = objsLumineer[0]
                GlobalShareData.sharedGlobal.objCurrentLumineer = lumineer
            }
            GlobalShareData.sharedGlobal.objCurretnVC.view.addBlurEffect()
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            objAdvertiseVC = storyBoard.instantiateViewController(withIdentifier: "AdvertiseVC") as! AdvertiseVC
        GlobalShareData.sharedGlobal.objCurretnVC.addChild(self.objAdvertiseVC)
            self.objAdvertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:390);
            GlobalShareData.sharedGlobal.objCurretnVC.view.addSubview(self.objAdvertiseVC.view)
            self.objAdvertiseVC
                .didMove(toParent: self)
            
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
