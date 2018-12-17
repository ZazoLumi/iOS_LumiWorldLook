//
//  viewProfileImgVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/06/04.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import Alamofire

class viewProfileImgVC: UIViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addBackButtonOnLeft()
        self.navigationItem.title = "PROFILE PHOTO"
        // Do any additional setup after loading the view.
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.done, target: self, action: #selector(viewProfileImgVC.editButtonClicked(_:)))
        self.navigationController?.navigationBar.tintColor = .lumiGray

        self.navigationItem.rightBarButtonItem = rightButton
        guard GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic != nil else {
            return
        }
//no due + authorization + passport +27825529622

        let urlOriginalImage : URL!
        if(GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic?.hasUrlPrefix())!
        {
            urlOriginalImage = URL.init(string: GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic!)
        }
        else {
            let fileName = GlobalShareData.sharedGlobal.objCurrentUserDetails.profilePic?.lastPathComponent
            urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
        }

        Alamofire.request(urlOriginalImage!).responseImage { response in
            debugPrint(response)
            if let image = response.result.value {
                let scalImg = image.af_imageAspectScaled(toFill: CGSize(width:self.imgProfile.frame.size.width, height: self.imgProfile.frame.size.height))
                self.imgProfile.image = scalImg
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func editButtonClicked(_ button:UIBarButtonItem!){
        print("Done clicked")
        CameraHandler.shared.showProfileActionSheet(vc: self,withDeletePhoto:true)
        CameraHandler.shared.isFromProfile = true
        CameraHandler.shared.didFinishCapturingImage = { (image, imgUrl) in
            GlobalShareData.sharedGlobal.strImagePath = (imgUrl?.absoluteString)!
            self.imgProfile.image = image
            self.navigationController?.popViewController()
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
