//
//  SendAttachmentVC.swift
//  
//
//  Created by Zazo on 2018/04/28.
//

import UIKit
import Realm
import MBProgressHUD

class SendAttachmentVC: UIViewController {
    var activityType : String!
    @IBOutlet weak var imgAttach: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnClose: UIButton!
     @IBOutlet weak var btnRefresh : UIBarButtonItem!
    var fileUrl : String?
    var fileImage : UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
       // showAnimate()
        if activityType == "Image" {
            imgAttach.image = fileImage
        }
        else if activityType == "Video" {
            let image = GlobalShareData.sharedGlobal.createThumbnailOfVideoFromFileURL(videoURL:URL.init(string: fileUrl!)!)
            imgAttach.image = image
        }

        self.view.backgroundColor = UIColor.lumiGray
        btnSend.isExclusiveTouch = true
        btnSend.tintColor = UIColor.lumiGreen

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = .clear
            
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
            blurEffectView.contentView.addSubview(imgAttach)
            blurEffectView.contentView.addSubview(btnSend)
            blurEffectView.contentView.addSubview(textField)
            blurEffectView.contentView.addSubview(btnClose)
            btnClose.tintColor = UIColor.lumiGreen

        } else {
            view.backgroundColor = .black
        }

        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        removeAnimate()
       // self.navigationController?.popViewController(animated: true)
    }
   
    @IBAction func onBtnSendMessageTapped(_ sender: Any) {
        removeAnimate()
    }
    
    func removeAnimate()
    {
        self.view.superview?.removeBlurEffect()
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
    }
    
    @IBAction func onBtnSendTapped(_ sender: Any) {
        let firstName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName
        let lastName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName
        
        var nSubjectID : Double? = nil
            nSubjectID = GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubjectId

        let name = firstName! + " \(lastName as! String)"
        let sentBy: String = GlobalShareData.sharedGlobal.userCellNumber + "-\(name)"
        
        let objMessage = LumiMessage()
        
        if imgAttach.image != nil {
            if let data = UIImageJPEGRepresentation(imgAttach.image!, 0.8) {
                var strFilePath : String!
                if activityType == "Video" {
                    do {
                        let weatherData = try NSData(contentsOf:URL.init(string: fileUrl!
                            )! , options: NSData.ReadingOptions())
                        strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: weatherData as NSData, fileName: (URL.init(string: fileUrl!)?.lastPathComponent)!)
                        print(weatherData.length)
                    } catch {
                        print(error)
                    }
                }
                else {
                    strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName: (URL.init(string: fileUrl!)?.lastPathComponent)!)
                }
                
                defer {
                    let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                    hud.label.text = NSLocalizedString("Uploading...", comment: "HUD loading title")
                    objMessage.sendLumiAttachmentMessage(param: ["newsFeedBody":textField.text as AnyObject,"enterpriseName":GlobalShareData.sharedGlobal.objCurrentLumineer.name! as AnyObject,"enterpriseRegnNmbr":GlobalShareData.sharedGlobal.objCurrentLumineer.companyRegistrationNumber! as AnyObject,"messageCategory":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageCategory as AnyObject,"messageType":"1" as AnyObject,"sentBy":sentBy as AnyObject,"imageURL":"" as AnyObject,"longitude":"" as AnyObject,"latitude":"" as AnyObject,"messageSubject":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubject! as AnyObject,"messageSubjectId":nSubjectID as AnyObject],filePath:strFilePath, completionHandler: {(error) in
                        DispatchQueue.main.async {
                            hud.hide(animated: true)}
                        if error != nil  {
                            self.showCustomAlert(strTitle: "", strDetails: (error?.localizedDescription)!, completion: { (str) in
                            })
                        }
                        DispatchQueue.main.async {
                            GlobalShareData.sharedGlobal.removeFilefromDocumentDirectory(fileName: strFilePath)
                            //self.navigationController?.popViewController(animated: false)
                            NotificationCenter.default.post(name: Notification.Name("attachmentPopupRemoved"), object: nil)
                            self.removeAnimate()
                        }
                    })
                }

            }
            
        }
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
