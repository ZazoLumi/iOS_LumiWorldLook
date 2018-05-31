//
//  FaqVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/29.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import RealmSwift
class FAQTableViewCellContent {
    var title: String?
    var subtitle: String?
    var expanded: Bool
    
    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
        self.expanded = false
    }
}

class FAQTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    @IBOutlet weak var imgDownArrow: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func set(content: FAQTableViewCellContent) {
        self.titleLabel.text = content.title
        self.subtitleLabel.text = content.expanded ? content.subtitle : ""
    }
}

class FaqVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var aryFAQData = [FAQTableViewCellContent]()
    @IBOutlet weak var tblData: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.aryFAQData = []
        self.navigationItem.addSettingButtonOnRight()
        self.tblData.tableFooterView = UIView()
        self.navigationItem.title = "FAQ"
        self.navigationItem.addBackButtonOnLeft()
        tblData.tableFooterView = UIView() // Removes empty cell separators
        tblData.estimatedRowHeight = 40
        tblData.rowHeight = UITableViewAutomaticDimension

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        getLatestLumiFAQMessages()
    }
    @objc func getLatestLumiFAQMessages() {
        self.view.backgroundColor = UIColor.white
        let objLumiFAQ = LumiFAQ()
        objLumiFAQ.getLumiFAQMessages(completionHandler: { (tempArray) in
            for index in 0...tempArray.count-1 {
                let aObject = tempArray[index] as LumiFAQ
                let titleData = "\(index+1). " + "\(aObject.faq!)"
                let obj =  FAQTableViewCellContent(title: titleData,
                                                   subtitle: aObject.faqAnswer!)
                self.aryFAQData.append(obj)
            }
            defer {
                self.tblData.reloadData()
            }
        })
    }
    
    // MARK: - Tableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryFAQData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: String(describing: FAQTableViewCell.self), for: indexPath) as! FAQTableViewCell
        cell.set(content: aryFAQData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let content = aryFAQData[indexPath.row]
        content.expanded = !content.expanded
        let cell = tblData.cellForRow(at: indexPath) as! FAQTableViewCell

        if content.expanded {
            UIView.animate(withDuration: 0.4, animations: {
                cell.imgDownArrow?.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
        }
        else {
            UIView.animate(withDuration: 0.4, animations: {
                cell.imgDownArrow?.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })

        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
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
