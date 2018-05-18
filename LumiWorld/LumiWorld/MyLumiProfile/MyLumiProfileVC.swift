//
//  MyLumiProfileVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class MyLumiProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        NotificationCenter.default.addObserver(self, selector: #selector(openAboutPlusTCVC), name: Notification.Name("openAboutPlusTC"), object: nil)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.title = "Profile"

    }
    @objc func openAboutPlusTCVC(notification: NSNotification) {
        if let strUrl = notification.userInfo?["url"] as? String, self.tabBarController?.selectedIndex == 2  {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let objAboutPlusTC = storyBoard.instantiateViewController(withIdentifier: "AboutPlusTC") as! AboutPlusTC
            objAboutPlusTC.urlToDisplay = URL.init(string: strUrl)
            objAboutPlusTC.strTitle = notification.userInfo?["title"] as? String
            self.navigationController?.pushViewController(objAboutPlusTC, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
