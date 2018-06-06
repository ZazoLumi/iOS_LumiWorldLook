//
//  MyLumiProfileVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import Alamofire
import  RealmSwift
class MyLumiProfileVC: UIViewController {

    @IBOutlet weak var lblFCount: UILabel!
    @IBOutlet weak var lblDCount: UILabel!
    @IBOutlet weak var lblACount: UILabel!
    @IBOutlet weak var lblCCount: UILabel!

    @IBOutlet weak var lblDisplayName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.title = GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName!.uppercased() + "'S LUMI PROFILE"
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        setupProfileData()
    }
    
    func setupProfileData() {
        GlobalShareData.sharedGlobal.objCurretnVC = self
        lblDisplayName.text = GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName
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
                let scalImg = image.af_imageScaled(to: CGSize(width:self.imgProfilePic.frame.size.width, height: self.imgProfilePic.frame.size.height))
                self.imgProfilePic.image = scalImg
            }
        }
        let realm = try! Realm()
       // let count = realm.objects(LumineerList.self).filter("status.@count > 0")
       let follows = realm.objects(LumineerList.self).filter("status == 1")
        self.lblFCount.text = "\(follows.count)"
        let conversation = realm.objects(LumiMessage.self)
        self.lblCCount.text = "\(conversation.count)"
        self.lblACount.text = "0"
        self.lblDCount.text = "0"
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
        self.imgProfilePic.addGestureRecognizer(tapGestureRecognizer)
        self.imgProfilePic.isUserInteractionEnabled = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer)
    {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let objLumiProfileDetails = storyBoard.instantiateViewController(withIdentifier: "LumiProfileDetails") as! LumiProfileDetails
        self.navigationController?.pushViewController(objLumiProfileDetails, animated: true)
    }
    @IBAction func onBtnYonOHaveTapped(_ sender: Any) {
        
    }
    @IBAction func onBtnMessageTapped(_ sender: Any) {
        
    }
    @IBAction func onBtnSuggestLumineerTapped(_ sender: Any) {
        
    }
    @IBAction func onBtnInviteFriendsTapped(_ sender: Any) {
        
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
