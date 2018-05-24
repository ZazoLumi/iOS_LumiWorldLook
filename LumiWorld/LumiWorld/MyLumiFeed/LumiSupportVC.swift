//
//  LumiSupportVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/24.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import RealmSwift

class supportCell: UITableViewCell {
    @IBOutlet var lblLumineerTitle: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


class LumiSupportVC: UIViewController {
    @IBOutlet weak var tblData : UITableView!
    var arySupportData: [[String:AnyObject]] = []
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(LumiSupportVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lumiGreen
        
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        self.tblData.addSubview(self.refreshControl)
        self.tblData.tableFooterView = UIView()
        self.navigationItem.title = "SUPPORT"
        self.arySupportData = []

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
         getLatestLumiSupportMessages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func getLatestLumiSupportMessages() {
        let objLumiSupport = LumiSupport()
       // let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.messageTimeStamp)
        //let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        objLumiSupport.getLumiSupportMessages(cellNumber: GlobalShareData.sharedGlobal.userCellNumber, completionHandler: { (arySuport) in
            let realm = try! Realm()
            let distinctTypes = Array(Set(realm.objects(LumiSupport.self).value(forKey: "supportID") as! [Int]))
            self.arySupportData = []
            for objUniqueItem in distinctTypes {
                let result  = realm.objects(LumiSupport.self).filter("supportID == %d",objUniqueItem)
                if result.count > 0 {
                    let objSupport = result[0] as LumiSupport
                    let section = ["title":objSupport.supportMessageSubject as Any, "supportID":objSupport.supportId as Any,"spport":objSupport as Any] as [String : Any]
                    self.arySupportData.append(section as [String : AnyObject])
                }

            }
            defer {
                self.tblData.reloadData()
            }
        })
        
        
        self.tblData.reloadData()
    }
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arySupportData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "supportCell", for: indexPath) as! supportCell
        var objCellData : [String : Any]!
        objCellData = arySupportData[indexPath.row]
        cell.lblLumineerTitle.text = objCellData["title"] as? String
        return cell
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = botChat
        var objCellData : [String : Any]!
            objCellData = arySupportData[indexPath.row]
        
        let support = objCellData["support"] as? LumiSupport
        GlobalShareData.sharedGlobal.objCurrentSupport = support

        var chatVC: TGChatViewController?
        chatVC = TGChatViewController(chat: chat)
        //chatVC.
        if let vc = chatVC {
            navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            
            //            self.catNames.remove(at: indexPath.row)
            //            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumiSupportMessages()
    }

}
