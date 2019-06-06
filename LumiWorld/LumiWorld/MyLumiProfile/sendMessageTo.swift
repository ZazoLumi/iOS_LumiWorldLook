//
//  inviteFriendVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/06/06.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MBProgressHUD
import RealmSwift

class sendMessageTo: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblData : UITableView!
    var aryLumineers : [LumineerList]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        showAnimate()
        getOptedLuminners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
       // customview.isFromProfile = false
    }
    
    func getOptedLuminners() {
        aryLumineers = []
        let realm = try! Realm()
        let realmObjects = realm.objects(LumiCategory.self)
        let result = realmObjects.filter("ANY lumineerList.status == 1")
        if result.count > 0 {
            for objCategory in result{
                for lumineer in objCategory.lumineerList.filter("status == 1") {
                    let  objLumineer = lumineer as LumineerList
                    aryLumineers.append(objLumineer)
                }
                
            }
            tblData.reloadData()
        }

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
        self.parent?.view.backgroundColor = UIColor.white
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
    
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryLumineers.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) 
        var objLumineer : LumineerList!
        objLumineer = aryLumineers[indexPath.row] as LumineerList
        cell.textLabel?.text = objLumineer.displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var objLumineer : LumineerList!
        objLumineer = aryLumineers[indexPath.row] as LumineerList
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let objLumineerProfileVC = storyBoard.instantiateViewController(withIdentifier: "LumineerProfileVC") as! LumineerProfileVC
        GlobalShareData.sharedGlobal.objCurrentLumineer = objLumineer
        self.navigationController?.pushViewController(objLumineerProfileVC, completion: {
            self.parent?.view.backgroundColor = UIColor.white
            self.view.superview?.removeBlurEffect()
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.parent?.view.backgroundColor = UIColor.white
        })
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
