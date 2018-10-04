//
//  LumineerMessagesVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/10/01.
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

class LumineerMessagesVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let kHeaderSectionTag: Int = 6900;
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var currentTotalHeights: Int = 0
    @IBOutlet weak var btnSupport: UIButton!
    @IBOutlet weak var lblLumiProfileTxt: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var tblActivityData: UITableView!
    var aryActivityData: [[String:AnyObject]]!
    @IBOutlet weak var lblActivity: UIView!
    @IBOutlet weak var viewActivityHeights: NSLayoutConstraint!
    @IBOutlet weak var btnFollowLumineer: UIButton!
    weak var delegate: ScrollContentSize?

    var objPopupSendMessage : PopupSendMessage! = nil
    
    private var pageController: UIPageViewController!
    private var arrPageTexts:[UIViewController] = []
    private var currentPage: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(getLatestLumiMessages), name: Notification.Name("popupRemoved"), object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getLatestLumiMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.viewActivityHeights.constant = CGFloat(self.aryActivityData.count * 46) + 30

        }
    }

    
    //
    // MARK: Custom methods
    //
    
    func addMessgePopup(activityType:String) {
        GlobalShareData.sharedGlobal.objCurretnVC.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objPopupSendMessage = storyBoard.instantiateViewController(withIdentifier: "PopupSendMessage") as! PopupSendMessage
        GlobalShareData.sharedGlobal.currentScreenValue = currentScreen.messageThread.rawValue
        objPopupSendMessage.activityType = activityType
        self.objPopupSendMessage.view.cornerRadius = 10
        GlobalShareData.sharedGlobal.objCurretnVC.addChildViewController(self.objPopupSendMessage)
        self.objPopupSendMessage.view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height-340)/2, width:self.view.frame.size.width , height:340);
        GlobalShareData.sharedGlobal.objCurretnVC.view.addSubview(self.objPopupSendMessage.view)
        self.objPopupSendMessage.didMove(toParentViewController: self)
        GlobalShareData.sharedGlobal.objCurretnVC.view.backgroundColor = .white

    }
    
    func removeMessgePopup() {
        objPopupSendMessage.view.removeFromSuperview()
        GlobalShareData.sharedGlobal.objCurretnVC.view.backgroundColor = .white
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
    func calculateCurrentHeight() {
        var tableHeight = 0
        if self.aryActivityData != nil, self.expandedSectionHeaderNumber == -1 ,(self.aryActivityData.count)>0{
            tableHeight = self.aryActivityData.count * 46
        }
        else if self.aryActivityData != nil, (self.aryActivityData.count)>0 {
            tableHeight = (self.aryActivityData.count * 46) + 64
        }
        delegate?.changeScrollContentSize(Int(btnSupport.frame.origin.y+btnSupport.frame.size.height+100))
        //        mainViewHeights.constant
        //            =  (appDelegate.window?.bounds.size.height)! + lblExpandableDescription.frame.size.height + CGFloat(tableHeight)
        //    }
        
    }
}
    

extension LumineerMessagesVC : UITableViewDelegate,UITableViewDataSource {
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
        headerTapGesture.addTarget(self, action: #selector(LumineerMessagesVC.sectionHeaderWasTouched(_:)))
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
