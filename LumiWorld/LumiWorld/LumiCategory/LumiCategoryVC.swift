//
//  LumiCategoryVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import AlamofireImage
import Alamofire

class LumineerCompanyCell: UITableViewCell {
    
    @IBOutlet weak var btnFollowUnfollow: UIButton!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var imgCompanyLogo: UIImageView!
}

class LumiCategoryVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    let kHeaderSectionTag: Int = 6900;
    let kHeaderDataTag: Int = 100;

    @IBOutlet weak var tableView: UITableView!
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionItems: Array<Any> = []
    var aryCategory: [LumiCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.addSettingButtonOnRight()

        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.yellow]
        self.tabBarController?.navigationController?.navigationBar.titleTextAttributes = attributes


        sectionItems = [ ["iPhone 5", "iPhone 5s", "iPhone 6", "iPhone 6 Plus", "iPhone 7", "iPhone 7 Plus"],
                         ["iPad Mini", "iPad Air 2", "iPad Pro", "iPad Pro 9.7"],
                         ["Apple Watch", "Apple Watch 2", "Apple Watch 2 (Nike)"]
        ];
        self.tableView!.tableFooterView = UIView()
        let objLumiCate = LumiCategory()
        objLumiCate.getLumiCategory(viewCtrl: self) { (aryCategory) in
               self.aryCategory = aryCategory
               self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "LUMINEER CATEGORIES"

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if aryCategory.count > 0 {
            tableView.backgroundView = nil
            return aryCategory.count
        } else {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            messageLabel.text = "Retrieving data.\nPlease wait."
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "HelveticaNeue", size: 20.0)!
            messageLabel.sizeToFit()
            self.tableView.backgroundView = messageLabel;
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.sectionItems[section] as! NSArray
            return arrayOfItems.count;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 0;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        header.backgroundColor = UIColor.init(hexString: "FFFFFE")
//        header.textLabel?.textColor = UIColor.init(red: 109, green: 107, blue: 105)
//        header.textLabel?.font = UIFont(name: "HelveticaNeue", size: 18)
        if let viewWithTag = self.view.viewWithTag(kHeaderSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        let headerFrame = self.view.frame.size
        var btnHeaderView = self.view.viewWithTag(kHeaderDataTag + section) as? UIButton
        if (btnHeaderView == nil){
            
            btnHeaderView = UIButton(type: .custom)
            btnHeaderView?.setImage(UIImage(named: "Artboard 97xxhdpi"), for: .selected)
            btnHeaderView?.setTitle(self.aryCategory[section].name, for: .normal)
            btnHeaderView?.setTitle(self.aryCategory[section].name, for: .selected)
            btnHeaderView?.frame = CGRect(x: 10, y: 5, width: headerFrame.width - 40, height: 20)
            btnHeaderView?.contentHorizontalAlignment = .left
            btnHeaderView?.setTitleColor(UIColor.init(hexString: "757576"), for: .normal)
            btnHeaderView?.setTitleColor(UIColor.init(hexString: "ff0000"), for: .selected)
            btnHeaderView?.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            btnHeaderView?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            btnHeaderView?.isUserInteractionEnabled = false
            btnHeaderView?.tag = kHeaderDataTag + section
            btnHeaderView?.imageView?.contentMode = .scaleAspectFit
            //displaying image
            let urlOriginalImage = URL.init(string: self.aryCategory[section].originalImage!)
            Alamofire.request(urlOriginalImage!).responseImage { response in
                debugPrint(response)
                
                if let image = response.result.value {
                   let scalImg = image.af_imageScaled(to: CGSize(width: 20, height: 20))
                    btnHeaderView?.setImage(scalImg, for: .normal)
                }
            }
            let urlSelectedImage = URL.init(string: self.aryCategory[section].visitedImage!)
            Alamofire.request(urlSelectedImage!).responseImage { response in
                debugPrint(response)
                
                if let image = response.result.value {
                    let scalImg = image.af_imageScaled(to: CGSize(width: 20, height: 20))
                    btnHeaderView?.setImage(scalImg, for: .selected)
                }
            }


            header.addSubview(btnHeaderView!)
        }
        
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 32, y: 13, width: 14, height: 14));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.contentMode = .scaleAspectFit
        theImageView.tag = kHeaderSectionTag + section
        header.addSubview(theImageView)
        
        // make headers touchable
        header.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(LumiCategoryVC.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        return header

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LumineerCompanyCell", for: indexPath) as! LumineerCompanyCell
        
        let section = self.sectionItems[indexPath.section] as! NSArray
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.text = section[indexPath.row] as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        let headerView = sender.view 
        let section    = headerView?.tag
        let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
        let eBtnView = headerView?.viewWithTag(kHeaderDataTag + section!) as? UIButton

        
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section!
            tableViewExpandSection(section!, imageView: eImageView!)
            eBtnView?.isSelected = true
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section!, imageView: eImageView!)
                eBtnView?.isSelected = false
            } else {
                let cImageView = self.view.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                let cBtnView = self.view.viewWithTag(kHeaderDataTag + self.expandedSectionHeaderNumber) as? UIButton

                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView!)
                tableViewExpandSection(section!, imageView: eImageView!)
                cBtnView?.isSelected = false
                eBtnView?.isSelected = true
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        self.expandedSectionHeaderNumber = -1;
        if (sectionData.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tableView!.beginUpdates()
            self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.sectionItems[section] as! NSArray
        
        if (sectionData.count == 0) {
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionData.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tableView!.beginUpdates()
            self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
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
extension UINavigationItem {
    func addSettingButtonOnRight(){
        let btn1 = UIButton(type: .custom)
        let img = UIImage(named: "Artboard 131xxhdpi")
        btn1.setImage(img, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(gotSettingPage), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: btn1)
        self.rightBarButtonItem = barButton
    }
    
    @objc func gotSettingPage(){
        
    }
}
