//
//  coomingsoon.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/10/08.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class coomingsoon: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.view.frame = CGRect(x: 0, y: 0, width:Int(self.view.frame.size.width), height:GlobalShareData.sharedGlobal.sagmentViewHeight)

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
