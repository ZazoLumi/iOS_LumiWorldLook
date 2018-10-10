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

class ContentGalleryCell : UITableViewCell {
    @IBOutlet weak var lblAdvTitle: UILabel!
    @IBOutlet weak var lblAdvPostedTime: UILabel!
    
    @IBOutlet weak var imgAdvType: UIImageView!
    @IBOutlet weak var lblLumineerName: UILabel!
    @IBOutlet weak var imgLumineerProfile: UIImageView!
    @IBOutlet weak var imgAdsContent: UIImageView!
    @IBOutlet weak var imgPlayIcon: UIImageView!
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnFullScreen: UIButton!



}
class LumineerContentGalleryVC: UIViewController, UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var aryContentData: [[String:AnyObject]] = []
    var objContentertiseVC : AdvertiseVC!
    weak var delegate: ScrollContentSize?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        
        aryContentData = []
        self.getLatestLumineersContents()
        self.tableView!.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        self.tableView.estimatedRowHeight = 220
//        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationItem.title = "CONTENT GALLERY"
    }
    override func viewWillDisappear(_ animated: Bool) {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContentGalleryCell", for: indexPath) as! ContentGalleryCell
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        
        cell.lblLumineerName.text = objCellData["title"] as? String
        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData["profileImg"] as? String)
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))
        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;

        let objContent = objCellData["message"] as? LumineerContent

        cell.lblAdvTitle.text = objContent?.contentTitle

        let imgMsgType : UIImage!
        var urlOriginalImage : URL? = nil
        
        if objContent?.contentType == "video" {
            cell.imgPlayIcon.isHidden = false
                if objContent?.adMediaURL != nil {
                    if(objContent?.adMediaURL?.hasUrlPrefix())!
                    {
                        urlOriginalImage = URL.init(string: (objContent?.adMediaURL!)!)
                    }
                    else {
                        var fileName = objContent?.contentFileName?.replacingOccurrences(of: " ", with: "-")
                        _ = fileName?.pathExtension
                        let pathPrefix = fileName?.deletingPathExtension
                        fileName = "\(pathPrefix!).png"
                        urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    }
                }
            imgMsgType = UIImage(named:"Asset102")
        }
        else if objContent?.contentType == "audio" {
            cell.imgPlayIcon.isHidden = false
            imgMsgType = UIImage(named:"Asset104")
        }
        else {
            cell.imgPlayIcon.isHidden = true
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
            cell.imgAdvType.image = imgMsgType
        }
        cell.imgAdsContent.contentMode = .scaleAspectFit
        cell.lblAdvPostedTime.text = Date().getFormattedDate(string: (objContent?.strContentDate!)!, formatter: "yyyy-MM-ddTHH:mm:ss")
        
        if urlOriginalImage != nil {
            Alamofire.request(urlOriginalImage!).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    let scalImg = image.af_imageScaled(to: CGSize(width: cell.imgAdsContent.size.width, height: cell.imgAdsContent.size.height))
                    cell.imgAdsContent.image = scalImg
                }
            }}
        
        return cell
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
