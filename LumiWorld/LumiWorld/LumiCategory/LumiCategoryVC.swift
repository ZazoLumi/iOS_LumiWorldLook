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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgCompanyLogo.layer.cornerRadius = self.imgCompanyLogo.bounds.size.height * 0.50
        self.imgCompanyLogo.layer.borderWidth = 0.5;
        self.imgCompanyLogo.layer.borderColor = UIColor.black.cgColor;

    }


}

class LumiCategoryVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    let kHeaderSectionTag: Int = 6900;
    let kHeaderDataTag: Int = 100;
    let kFollowDataTag: Int = 20000;
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var tableView: UITableView!
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var aryCategory: [LumiCategory] = []
    var dataMsgLabel : UILabel!
    var imgBg : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.addSettingButtonOnRight()

        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.yellow]
        self.tabBarController?.navigationController?.navigationBar.titleTextAttributes = attributes


        self.tableView!.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Lumineer"
        self.tabBarController?.navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = []
        searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.title = "LUMINEER CATEGORIES"
        self.tableView.backgroundView = self.dataMsgLabel;
        let objLumiCate = LumiCategory()
        DispatchQueue.global(qos: .userInitiated).async {
        objLumiCate.getLumiCategory(viewCtrl: self) { (aryCategory) in
            self.aryCategory = aryCategory
            guard self.aryCategory.count != 0 else {
                self.tableView.backgroundView = self.imgBg;
                return
            }
                let objLumineerList = LumineerList()
                objLumineerList.getLumineerCompany(completionHandler: { (List) in
                    self.aryCategory = [LumiCategory]()
                    for element in List {
                        if let category = element as? LumiCategory {
                            self.aryCategory.append(category)
                        }
                    }
                    DispatchQueue.main.async {
                        if self.aryCategory.count > 0 {
                            self.tableView.reloadData()
                        }
                        else {
                            self.tableView.backgroundView = self.imgBg;
                        }
                    }
                })
            }
            
        }

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
            let viewBg = UIView .init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            viewBg.backgroundColor = UIColor.clear
            dataMsgLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            dataMsgLabel.text = "Retrieving data.\nPlease wait.."
            dataMsgLabel.numberOfLines = 0;
            dataMsgLabel.textAlignment = .center;
            dataMsgLabel.textColor = UIColor.init(hexString: "757576")
            dataMsgLabel.font = UIFont(name: "HelveticaNeue", size: 20)
            dataMsgLabel.sizeToFit()
            viewBg.addSubview(dataMsgLabel)
            imgBg = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
            imgBg.image = UIImage.init(named: "Asset 335")
            imgBg.contentMode = .scaleAspectFit
            self.tableView.backgroundView = dataMsgLabel;
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let arrayOfItems = self.aryCategory[section].lumineerList
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
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
        let arrayOfItems = self.aryCategory[indexPath.section].lumineerList
        
        let objLumineer = arrayOfItems[indexPath.row] as LumineerList
        if objLumineer.status==1 {
            cell.btnFollowUnfollow.isSelected = true
        }
        else {
            cell.btnFollowUnfollow.isSelected = false
        }
        cell.btnFollowUnfollow.addTarget(self, action: #selector(onBtnFollowUnfollowTapped(_:)), for: .touchUpInside)
        cell.btnFollowUnfollow.tag = kFollowDataTag + indexPath.row
        cell.lblCompanyName.text = objLumineer.name
        let imgThumb = UIImage.decodeBase64(strEncodeData:objLumineer.enterpriseLogo)
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: cell.imgCompanyLogo.frame.size.width, height: cell.imgCompanyLogo.frame.size.height))

        cell.imgCompanyLogo.image = scalImg
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func onBtnFollowUnfollowTapped(_ sender: UIButton) {
        let objLumiList = LumineerList()
        DispatchQueue.global(qos: .userInitiated).async {
            objLumiList.setLumineerCompanyFollowUnFollowData(uniqueID: "", status: "", completionHandler: { (List) in
                    self.aryCategory = [LumiCategory]()
                    for element in List {
                        if let category = element as? LumiCategory {
                            self.aryCategory.append(category)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }

    }
    
    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String) {
//        filteredCandies = candies.filter({( candy : Candy) -> Bool in
//
//            if searchBarIsEmpty() {
//                return doesCategoryMatch
//            } else {
//                return candy.name.lowercased().contains(searchText.lowercased())
//            }
//        })
        tableView.reloadData()
    }

    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
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
            let sectionData = self.aryCategory[section!].lumineerList
            if sectionData.count>0{
                eBtnView?.isSelected = true
            }
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
                let sectionData = self.aryCategory[section!].lumineerList
                if sectionData.count>0{
                    eBtnView?.isSelected = true
                }
            }
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        let sectionData = self.aryCategory[section].lumineerList

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
        let sectionData = self.aryCategory[section].lumineerList

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
        btn1.addTarget(self, action:#selector(gotoSettingPage(_:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: btn1)
        self.rightBarButtonItem = barButton
    }

        @objc func gotoSettingPage(_ sender: UIButton){
            let actionSheet = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
            let firstSubview = actionSheet.view.subviews.first
            let alertContentView: UIView? = firstSubview?.subviews.first

            let view = UIView(frame: CGRect(x: 5, y: 2, width: actionSheet.view.bounds.size.width - 7 * 4.5, height:125))
            view.backgroundColor = UIColor.init(red: 240, green: 240, blue: 237)
            actionSheet.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            actionSheet.view.addSubview(view)
            
            let imgProfile =  UIImageView.init(frame: CGRect.init(x: 10, y: 25, width: 80, height:80))
            imgProfile.image = UIImage(named: "Asset 2187")
            imgProfile.backgroundColor = UIColor.clear
            imgProfile.layer.cornerRadius = imgProfile.bounds.size.height * 0.50
            imgProfile.contentMode = .scaleAspectFit
            imgProfile.layer.borderWidth = 0.5;
            imgProfile.layer.borderColor = UIColor.black.cgColor;

            view.addSubview(imgProfile)

            
            let btnProfile = UIButton.init(type: .custom)
            btnProfile.frame = CGRect.init(x: 10, y: 10, width: Int(view.frame.size.width), height:115)
            btnProfile.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18)
            btnProfile.setTitle("Test User Data for multiple line support with some other stuff", for: .normal)
            btnProfile.backgroundColor = UIColor.clear
            btnProfile.contentHorizontalAlignment = .left
            btnProfile.titleLabel?.lineBreakMode = .byWordWrapping
            btnProfile.titleLabel?.numberOfLines = 0
            btnProfile.setTitleColor(UIColor.init(hexString: "757576"), for: .normal)
            btnProfile.titleEdgeInsets = UIEdgeInsets(top: 0, left: 90, bottom: 0, right: 0)
            btnProfile.addTarget(self, action:#selector(actionProfileTapped(_:)), for: .touchUpInside)
            view.addSubview(btnProfile)
            
            
            let view1 = UIView(frame: CGRect(x: 5, y: 130, width: actionSheet.view.bounds.size.width - 7 * 4.5, height: 330))
            view1.backgroundColor = UIColor.clear
            actionSheet.view.addSubview(view1)
            
            var yPos = 0
            let arrSheetData  = [["title":"Support","img":"Asset 2186"],["title":"Terms & Conditions","img":"Asset 2185"],["title":"Lumi World Messages","img":"Asset 2181"],["title":"About","img":"Asset 2184"],["title":"How To Use","img":"Asset 2182"],["title":"Logout","img":"Asset 2183"]]
            for  i in 0...5 {
                let btnAction = UIButton.init(type: .custom)
                btnAction.frame = CGRect.init(x: 0, y: yPos, width: Int(view1.frame.size.width), height:55)
                btnAction.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 18)
                btnAction.tag = 200+i
                btnAction.setTitle(arrSheetData[i]["title"], for: .normal)
                let btnImg = UIImage(named: arrSheetData[i]["img"]!)
                btnAction.setImage(btnImg, for: .normal)
                btnAction.backgroundColor = UIColor.clear
                btnAction.contentHorizontalAlignment = .left
                btnAction.setTitleColor(.lumiGreen, for: .normal)
                btnAction.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
                btnAction.addTarget(self, action:#selector(actionItemTapped(_:)), for: .touchUpInside)
                btnAction.imageEdgeInsets = UIEdgeInsets(top: 0, left: CGFloat(Int(view1.frame.size.width) - Int((btnImg?.size.width)!) - 30), bottom: 0, right:0)
                btnAction.semanticContentAttribute = .forceRightToLeft
        
                view1.addSubview(btnAction)
                yPos+=57
                if i == 3 {
                   yPos -= 3
                }
            }
            
            actionSheet.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            actionSheet.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            let cancelAction = UIAlertAction(title:"Cancel", style:.destructive)
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            actionSheet.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            sender.superview?.parentViewController?.present(actionSheet, animated: true, completion: nil)
            for subSubView: UIView in (alertContentView?.subviews)! {
                //This is main catch
                subSubView.backgroundColor = UIColor.init(red: 240, green: 240, blue: 237)
                //Here you change background
            }

        }
    @objc func actionItemTapped(_ sender: UIButton) {
        let btnAction :UIButton = sender
        print(btnAction.tag)
    }
    @objc func actionProfileTapped(_ sender: UIButton) {
        let _ :UIButton = sender
    }
    }
    
extension UIImage {
    
    /*
     @brief decode image base64
     */
    static func decodeBase64(strEncodeData: String!) -> UIImage {
      var newEncodeData = strEncodeData.replacingOccurrences(of: "data:image/png;base64,", with: "")
        if let decData = Data(base64Encoded: newEncodeData, options: .ignoreUnknownCharacters), newEncodeData.characters.count > 0 {
            return UIImage(data: decData)!
        }
        return UIImage()
    }
}
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
extension LumiCategoryVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension LumiCategoryVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

func appDelInstance() -> AppDelegate{
    return UIApplication.shared.delegate as! AppDelegate
}
extension UIColor {
    static let lumiGreen = UIColor(red: 110, green: 187, blue: 171)
}

