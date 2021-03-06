//
//  SendMessage.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/04/10.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import MBProgressHUD
import AVKit
import Kingfisher
class PopupSendMessage: UIViewController,UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var activityType : String!
    var strFileUrl : String!
    var isVideoPickup = false
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var imgAttach: UIImageView!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var tvMessage: UITextView!
    let cellReuseIdentifier = "cell"
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: NoCopyPasteUITextField!
    @IBOutlet weak var tableView: UITableView!
    var selectedLat : Double!
    var selectedLong : Double!

    var currentSubject : [String]!
    var strImgName : String!
    var isSubjectPicked = false
    //
    // MARK: View lifcycle methods
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        let arrow = UIImageView(image: UIImage(named: "Asset 3352"))
        if let size = arrow.image?.size {
            arrow.frame = CGRect(x: 0.0, y: 0.0, width: size.width + 10.0, height: size.height)
        }
        arrow.contentMode = UIView.ContentMode.center
        self.textField.leftView = arrow
        self.textField.leftViewMode = UITextField.ViewMode.always

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        tableView.isHidden = true
        tableView.cornerRadius = 5
        // Manage tableView visibility via TouchDown in textField
        textField.addTarget(self, action: #selector(textFieldActive), for: UIControl.Event.touchDown)
        let realm = try! Realm()
        if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
            currentSubject = Array(Set(realm.objects(LumiMessage.self).filter("enterpriseID = %@",GlobalShareData.sharedGlobal.objCurrentLumineer.id).filter("messageCategory = %@",activityType).value(forKey: "messageSubject") as! [String]))
        }
        else if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.supportThread.rawValue{
            currentSubject = Array(Set(realm.objects(LumiSupport.self).filter("isRespReqdFromLumi = %@",NSNumber(value: true)).value(forKey: "supportMessageSubject") as! [String]))
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews()
    {
        // Assumption is we're supporting a small maximum number of entries
        // so will set height constraint to content size
        // Alternatively can set to another size, such as using row heights and setting frame
        var height = CGFloat((currentSubject.count * 34) + 10)
        if height > self.view.frame.size.height-120 {
            height = self.view.frame.size.height-120
        }
        heightConstraint.constant = height
    }

    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func onBtnClosePopupTapped(_ sender: Any) {
        self.view.superview?.removeBlurEffect()
        removeAnimate()
    }
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParent: nil)
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.parent?.view.backgroundColor = UIColor.white
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK: Custome methods
    //

    @IBAction func onBtnSendTapped(_ sender: Any) {
        if tvMessage.text == "Type Message" {
            tvMessage.text = ""
        }
        let firstName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName  //Static "Christian"
        let lastName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName  //Static "Nhlabano"
        var subjectID : [Double] = []
        if isSubjectPicked == true {
            let realm = try! Realm()
            if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
                subjectID = realm.objects(LumiMessage.self).filter("messageCategory = %@",activityType).filter("messageSubject = %@",textField.text!).value(forKey: "messageSubjectId") as! [Double]
            }
            else if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.supportThread.rawValue{
                subjectID = realm.objects(LumiSupport.self).filter("supportMessageSubject = %@",textField.text!).value(forKey: "supportSubjectId") as! [Double]
            }
        }
        var nSubjectID : Double? = nil
        
        if subjectID.count > 0 {
            nSubjectID = subjectID[0]
        }
        let name = firstName! + " \(lastName as! String)"
        let sentBy: String = GlobalShareData.sharedGlobal.userCellNumber + "-\(name)"
        
        let objMessage = LumiMessage()

        if imgAttach.image != nil || self.isVideoPickup {
                var strFilePath : String!
                if self.isVideoPickup {
                    do {
                        let weatherData = try NSData(contentsOf:URL.init(string: strFileUrl!
                            )! , options: NSData.ReadingOptions())
                        strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: weatherData as NSData, fileName: (URL.init(string: strFileUrl!)?.lastPathComponent)!)
                        print(weatherData.length)
                    } catch {
                        print(error)
                    }
                }
                else {
                    if let imageData = imgAttach.image?.jpegData(compressionQuality: 0.8) {
                        strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: imageData as NSData, fileName: strImgName)
                    }
                }
                
                defer {
                    let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                    hud.label.text = NSLocalizedString("Uploading...", comment: "HUD loading title")
                    if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
                    objMessage.sendLumiAttachmentMessage(param: ["newsFeedBody":tvMessage.text as AnyObject,"enterpriseName":GlobalShareData.sharedGlobal.objCurrentLumineer.name! as AnyObject,"enterpriseRegnNmbr":GlobalShareData.sharedGlobal.objCurrentLumineer.companyRegistrationNumber! as AnyObject,"messageCategory":activityType as AnyObject,"messageType":"1" as AnyObject,"sentBy":sentBy as AnyObject,"imageURL":"" as AnyObject,"longitude":selectedLong as AnyObject,"latitude":selectedLat as AnyObject,"messageSubject":textField.text! as AnyObject,"messageSubjectId":nSubjectID as AnyObject],filePath:strFilePath, completionHandler: {(error) in
                        DispatchQueue.main.async {
                            hud.hide(animated: true)}
                        if error != nil  {
                            self.showCustomAlert(strTitle: "", strDetails: (error?.localizedDescription)!, completion: { (str) in
                            })
                        }

                        DispatchQueue.main.async {
                            self.view.superview?.removeBlurEffect()
                            NotificationCenter.default.post(name: Notification.Name("popupRemoved"), object: nil)
                            self.removeAnimate()
                        }
                    })}
                    else if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.supportThread.rawValue{
                        
                        let objSupport = LumiSupport()
                        var urlString = ""
                        
                        if nSubjectID != nil {
                            urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIReplyToLumiWorldWithMediaByLumi)"
                        }
                        else {
                            urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISendSupportQueryWithMediaByLumi)"
                        }
                        
                        objSupport.sendSupportAttachmentMessage(urlString: urlString, param: ["supportMessageBody":tvMessage.text as AnyObject,"supportSubjectId":nSubjectID as AnyObject,"sentBy":GlobalShareData.sharedGlobal.userCellNumber! as AnyObject,"supportMessageSubject":textField.text! as AnyObject], filePath: strFilePath) {(error) in
                            DispatchQueue.main.async {
                                hud.hide(animated: true)}
                            if error != nil  {
                                self.showCustomAlert(strTitle: "", strDetails: (error?.localizedDescription)!, completion: { (str) in
                                })
                            }
                            DispatchQueue.main.async {
                                hud.hide(animated: true)
                                self.view.superview?.removeBlurEffect()
                                NotificationCenter.default.post(name: Notification.Name("popupRemoved"), object: nil)
                                self.removeAnimate()
                            }
                            
                        }
                    }
                }
        }
        else {
            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
            hud.label.text = NSLocalizedString("Sending...", comment: "HUD loading title")
            
            if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
            objMessage.sendLumiTextMessage(param: ["newsFeedBody":tvMessage.text as AnyObject,"enterpriseName":GlobalShareData.sharedGlobal.objCurrentLumineer.name! as AnyObject,"enterpriseRegnNmbr":GlobalShareData.sharedGlobal.objCurrentLumineer.companyRegistrationNumber! as AnyObject,"messageCategory":activityType as AnyObject,"messageType":"1" as AnyObject,"sentBy":sentBy as AnyObject,"imageURL":"" as AnyObject,"longitude":"" as AnyObject,"latitude":"" as AnyObject,"messageSubject":textField.text! as AnyObject,"messageSubjectId":nSubjectID as AnyObject], completionHandler: { () in
                DispatchQueue.main.async {
                    hud.hide(animated: true)
                    self.view.superview?.removeBlurEffect()
                    NotificationCenter.default.post(name: Notification.Name("popupRemoved"), object: nil)
                    self.removeAnimate()
                }
            })}
            else if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.supportThread.rawValue{
                let objSupport = LumiSupport()
                var urlString = ""

                if nSubjectID != nil {
                    urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIReplyToLumiWorldByLumin)"
                }
                else {
                    urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISendSupportQueryToLumiAdmin)"
                }
                
                objSupport.sendSupportTextMessage(urlString: urlString, param: ["supportMessageBody":tvMessage.text as AnyObject,"supportSubjectId":nSubjectID as AnyObject,"sentBy":GlobalShareData.sharedGlobal.userCellNumber! as AnyObject,"supportMessageSubject":textField.text! as AnyObject]) {
                    DispatchQueue.main.async {
                        hud.hide(animated: true)
                        self.view.superview?.removeBlurEffect()
                        NotificationCenter.default.post(name: Notification.Name("popupRemoved"), object: nil)
                        self.removeAnimate()
                    }

                }
            }
        }
    }

    @IBAction func onBtnAttachmentTapped(_ sender: Any) {
        CameraHandler.shared.isFromchat = false
        let alertController = UIAlertController.init()
        
        CameraHandler.shared.isFromchat = true
        let actionCamera = UIAlertAction.init(title: "  Camera", style: .default, image: (UIImage(named: "Asset 1635")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)))!) { (action) in
            CameraHandler.shared.isVideoCapturing = false
            CameraHandler.shared.showCamera(vc:self)
            CameraHandler.shared.didFinishCapturingImage = { (image, imgUrl) in
                /* get your image here */
                var imgName : String?
                if imgUrl != nil
                { imgName = imgUrl?.lastPathComponent}
                else {
                    imgName = "test.png"
                }
                self.isVideoPickup = false
                self.imgAttach.image = image
                self.strImgName = imgName
            }
            CameraHandler.shared.didFinishCapturingVideo = { (url,thumbImg) in
                var _ : String? = url.lastPathComponent
                self.strFileUrl = url.absoluteString
                self.isVideoPickup = true
                DispatchQueue.main.async {
                    let scalImg = thumbImg.kf.resize(to: CGSize(width: self.imgAttach.size.width, height: self.imgAttach.size.height), for: .aspectFill)
                    self.imgAttach.image = scalImg
                }
                /* get your image here */
                } as ((URL,UIImage) -> Void)
        }
        let actionPhotoVideo = UIAlertAction.init(title: "   Photo & Video Library", style: .default, image:(UIImage(named: "Asset 1636")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)))!) { (action) in
            CameraHandler.shared.isVideoCapturing = true
            CameraHandler.shared.showPhotoLibrary(vc:self)
            CameraHandler.shared.didFinishCapturingImage = { (image, imgUrl) in
                /* get your image here */
                var imgName : String?
                if imgUrl != nil
                { imgName = imgUrl?.lastPathComponent}
                else {
                    imgName = "test.png"
                }
                self.isVideoPickup = false
                self.imgAttach.image = image
                self.strImgName = imgName
            }
            CameraHandler.shared.didFinishCapturingVideo = { (url,thumbImg) in
                /* get your image here */
                var _ : String? = url.lastPathComponent
                self.strFileUrl = url.absoluteString
                self.isVideoPickup = true
                DispatchQueue.main.async {
                    let scalImg = thumbImg.kf.resize(to: CGSize(width: self.imgAttach.size.width, height: self.imgAttach.size.height), for: .aspectFill)

                    self.imgAttach.image = scalImg
                }
                } as ((URL,UIImage) -> Void)
            
        }
        
        let actionDocument = UIAlertAction.init(title: "  Document", style: .default, image: (UIImage(named: "Asset 1637")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 0)))!) { (action) in
            if #available(iOS 11.0, *) {
                let objDocumentVC = DocumentBrowserViewController()
                objDocumentVC.isFromChat = false
                self.navigationController?.pushViewController(objDocumentVC, animated: false)
                objDocumentVC.didFinishCapturingDocument = { (image, strFilePath,destinationFilename) in
                    let scalImg = image.kf.resize(to: CGSize(width: self.imgAttach.size.width, height: self.imgAttach.size.height), for: .aspectFill)

                    self.imgAttach.image = scalImg
                    self.strFileUrl = strFilePath
                    self.isVideoPickup = true
                    self.tvMessage.textColor = UIColor.black
                    self.tvMessage.text = destinationFilename
                }
            } else {
                // Earlier version of iOS
            }
            
            
        }
        let actionLocation = UIAlertAction.init(title: "   Location", style: .default, image:(UIImage(named: "Asset 1638")?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)))!) { (action) in
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let objMapViewController = storyBoard.instantiateViewController(withIdentifier: "mapViewController") as! mapViewController
            objMapViewController.isFromChat = false;
            self.navigationController?.pushViewController(objMapViewController, animated: false)
            
            objMapViewController.didFinishCapturingLocations = { (image,lat,long,strFilePath,strLocationAddress) in
                let scalImg = image.kf.resize(to: CGSize(width: self.imgAttach.size.width, height: self.imgAttach.size.height), for: .aspectFill)
                self.imgAttach.image = scalImg
                self.isVideoPickup = true
                self.selectedLat = lat
                self.selectedLong = long
                self.strFileUrl = strFilePath
                self.tvMessage.textColor = UIColor.black
                self.tvMessage.text =  strLocationAddress
            }
        }
        
        let cancelAction = UIAlertAction(title:"Cancel", style:.cancel)
        actionCamera.setValue(UIColor.lumiGray, forKey: "titleTextColor")
        actionPhotoVideo.setValue(UIColor.lumiGray, forKey: "titleTextColor")
        actionDocument.setValue(UIColor.lumiGray, forKey: "titleTextColor")
        actionLocation.setValue(UIColor.lumiGray, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        
        actionCamera.setValue(0, forKey: "titleTextAlignment")
        actionPhotoVideo.setValue(0, forKey: "titleTextAlignment")
        actionDocument.setValue(0, forKey: "titleTextAlignment")
        actionLocation.setValue(0, forKey: "titleTextAlignment")
        
        
        alertController.addAction(actionCamera)
        alertController.addAction(actionPhotoVideo)
        alertController.addAction(actionDocument)
        if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
            alertController.addAction(actionLocation) }
        alertController.addAction(cancelAction)
        alertController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.navigationController?.present(alertController, animated: true, completion: nil)

    }
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        tableView.isHidden = true
    }

    //
    // MARK: TextView Delegate methods
    //

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type Message" {
            textView.text = nil
            textView.textColor = UIColor.black
            textField.endEditing(true)
            tableView.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type Message"
            textView.textColor = .lumiGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            isSubjectPicked = true
            textView.text = "Type Message"
            textView.textColor = .lumiGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
            
        else if textView.text == "Type Message" && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }

    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view != tableView
        {
            textField.endEditing(true)
            tableView.isHidden = true
        }
    }
    
    // Toggle the tableView visibility when click on textField
    @objc func textFieldActive() {
        tableView.isHidden = !tableView.isHidden
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Your app can do something when textField finishes editing
        print("The textField ended editing. Do something based on app requirements.")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentSubject.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!
        // Set text from the data model
        cell.textLabel?.text = currentSubject[indexPath.row]
        cell.textLabel?.font = textField.font
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        textField.text = currentSubject[indexPath.row]
        isSubjectPicked = true
        tableView.isHidden = true
        textField.endEditing(true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}
