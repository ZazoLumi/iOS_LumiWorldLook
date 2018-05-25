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
    @IBOutlet var lblSupportTitle: UILabel!

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


class LumiSupportVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tblData : UITableView!
    var arySupportData: [LumiSupport] = []
    var objPopupSendMessage : PopupSendMessage! = nil

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
        self.arySupportData = []
        self.navigationItem.addSettingButtonOnRight()
        self.tblData.addSubview(self.refreshControl)
        self.tblData.tableFooterView = UIView()
        self.navigationItem.title = "SUPPORT"
        self.tblData.delegate = self
        self.tblData.dataSource = self
        self.navigationItem.addBackButtonOnLeft()
        NotificationCenter.default.addObserver(self, selector: #selector(getLatestLumiSupportMessages), name: Notification.Name("popupRemoved"), object: nil)
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
        var originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.supportTimeStamp)
        if originalString.count > 0 {originalString += ":00" }
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        objLumiSupport.getLumiSupportMessages(cellNumber: GlobalShareData.sharedGlobal.userCellNumber, lastViewDate: escapedString!, completionHandler: { (arySuport) in
            let realm = try! Realm()
            let distinctTypes = Array(Set(realm.objects(LumiSupport.self).value(forKey: "supportId") as! [Int]))
            self.arySupportData = []
            for objUniqueItem in distinctTypes {
                let result  = realm.objects(LumiSupport.self).filter("supportId == %d",objUniqueItem)
                if result.count > 0 {
                    let objSupport = result[0] as LumiSupport
//                    let section = ["title":objSupport.supportMessageSubject as Any, "supportId":objSupport.supportId as Any,"spport":objSupport as Any] as [String : Any]
                    self.arySupportData.append(objSupport)
                }
            }
            self.tblData.reloadData()
            defer {
                self.tblData.reloadData()
            }
        })
        
        
    }
    
    @IBAction func onBtnNewQueryTapped(_ sender: Any) {
        self.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objPopupSendMessage = storyBoard.instantiateViewController(withIdentifier: "PopupSendMessage") as! PopupSendMessage
        GlobalShareData.sharedGlobal.currentScreenValue = currentScreen.messageThread.rawValue
        self.objPopupSendMessage.view.cornerRadius = 10
        self.addChildViewController(self.objPopupSendMessage)
        self.objPopupSendMessage.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-340)/2, width:self.view.frame.size.width , height:340);
        self.view.addSubview(self.objPopupSendMessage.view)
        self.objPopupSendMessage.didMove(toParentViewController: self)
    }
    
    func removeMessgePopup() {
        objPopupSendMessage.view.removeFromSuperview()
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
        var objLumiSupport : LumiSupport!
        objLumiSupport = arySupportData[indexPath.row] as LumiSupport
        cell.lblSupportTitle?.text = objLumiSupport.supportMessageSubject
        return cell
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = botChat
        var objLumiSupport : LumiSupport!
        objLumiSupport = arySupportData[indexPath.row] as LumiSupport

        GlobalShareData.sharedGlobal.objCurrentSupport = objLumiSupport

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
        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumiSupportMessages()
    }

}
