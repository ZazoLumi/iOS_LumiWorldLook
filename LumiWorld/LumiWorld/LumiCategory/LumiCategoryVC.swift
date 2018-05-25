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
import Realm
import RealmSwift

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

@available(iOS 11.0, *)
class LumiCategoryVC: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    let kHeaderSectionTag: Int = 6900;
    let kHeaderDataTag: Int = 100;
    let kFollowDataTag: Int = 20000;
    let searchController = UISearchController(searchResultsController: nil)
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(LumiCategoryVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lumiGreen
        
        return refreshControl
    }()

    @IBOutlet weak var tableView: UITableView!
    
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var aryCategory: [LumiCategory] = []
    var arySearchLumineer: [LumineerList] = []

    var dataMsgLabel : UILabel!
    var imgBg : UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationItem.addSettingButtonOnRight()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        //Static
        self.tableView.addSubview(self.refreshControl)
        self.tableView!.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationItem.title = "LUMINEER CATEGORIES"
        self.tableView.backgroundView = self.dataMsgLabel;
        GlobalShareData.sharedGlobal.objCurretnVC = self
        self.getLatestLumiCategories()
        searchController.searchResultsUpdater = self
       // searchController.obscuresBackgroundDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Lumineer"
        self.navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "My"]
        searchController.searchBar.delegate = self
       // self.tableView.tableHeaderView = self.searchController.searchBar;


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.isActive = false
        self.tabBarController?.navigationItem.searchController = nil
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumiCategories()
    }
    
    func getLatestLumiCategories() {
        let objLumiCate = LumiCategory()
        DispatchQueue.global(qos: .userInitiated).async {
            objLumiCate.getLumiCategory(viewCtrl: self) { (aryCategory) in
                self.aryCategory = aryCategory
                guard self.aryCategory.count != 0 else {
                    self.tableView.backgroundView = self.imgBg;
                    return
                }
                let objLumineerList = LumineerList()
                let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.lumineerTimeStamp)
                let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                objLumineerList.getLumineerCompany(lastViewDate:escapedString!,completionHandler: { (List) in
                    self.aryCategory = [LumiCategory]()
                    for element in List {
                        if let category = element as? LumiCategory {
                            self.aryCategory.append(category)
                        }
                    }
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
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

    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        }
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
        if isFiltering() {
            return arySearchLumineer.count
        }

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
        if isFiltering(), self.aryCategory.count == 0 {
            return nil
        }

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
            btnHeaderView?.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 16)
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
        var objLumineer : LumineerList!
        if isFiltering() {
            objLumineer = arySearchLumineer[indexPath.row] as LumineerList
        }
        else {
            objLumineer = arrayOfItems[indexPath.row] as LumineerList
        }

        if objLumineer.status==1 {
            cell.btnFollowUnfollow.isSelected = true
        }
        else {
            cell.btnFollowUnfollow.isSelected = false
        }
        cell.btnFollowUnfollow.addTarget(self, action: #selector(onBtnFollowUnfollowTapped(_:)), for: .touchUpInside)
        cell.btnFollowUnfollow.tag = kFollowDataTag + indexPath.row
        cell.lblCompanyName.text = objLumineer.displayName
        let imgThumb = UIImage.decodeBase64(strEncodeData:objLumineer.enterpriseLogo)
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: cell.imgCompanyLogo.frame.size.width, height: cell.imgCompanyLogo.frame.size.height))
        cell.imgCompanyLogo.contentMode = .scaleAspectFit
        cell.imgCompanyLogo.image = scalImg
        cell.imgCompanyLogo?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgCompanyLogo?.clipsToBounds = true;

        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var objLumineer : LumineerList!
        let arrayOfItems = self.aryCategory[(indexPath.section)].lumineerList
        var delaytime : Double = 0
        if self.isFiltering() {
            objLumineer = self.arySearchLumineer[(indexPath.row)] as LumineerList
            delaytime = 0.5
        }
        else {
            objLumineer = arrayOfItems[(indexPath.row)] as LumineerList
            let sectionHeaderView = tableView.headerView(forSection: indexPath.section)
            let eImageView = sectionHeaderView?.viewWithTag(self.kHeaderSectionTag + indexPath.section) as? UIImageView
            let cImageView = tableView.viewWithTag(self.kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
            if (self.expandedSectionHeaderNumber == indexPath.section) {
                self.tableViewCollapeSection(indexPath.section, imageView: eImageView)
            } else {
                self.tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView)
                self.tableViewExpandSection(indexPath.section, imageView: eImageView!)
            }

        }
        searchController.isActive = false

        DispatchQueue.main.asyncAfter(deadline: .now() + delaytime) {
            // your code here
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let objLumineerProfileVC = storyBoard.instantiateViewController(withIdentifier: "LumineerProfileVC") as! LumineerProfileVC
            GlobalShareData.sharedGlobal.objCurrentLumineer = objLumineer
            self.navigationController?.pushViewController(objLumineerProfileVC, animated: false)
        }
        defer {             }
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let indexPath = tableView.indexPathForSelectedRow{
//            if segue.identifier == "LumineerProfileSelected" {
//                searchController.isActive = false
//                let objLumineerProfileVC = segue.destination as! LumineerProfileVC
//                let arrayOfItems = self.aryCategory[(indexPath.section)].lumineerList
//
//                var objLumineer : LumineerList!
//                if isFiltering() {
//                    objLumineer = arySearchLumineer[(indexPath.row)] as LumineerList
//                }
//                else {
//                    objLumineer = arrayOfItems[(indexPath.row)] as LumineerList
//                    let sectionHeaderView = tableView.headerView(forSection: indexPath.section)
//                    let eImageView = sectionHeaderView?.viewWithTag(kHeaderSectionTag + indexPath.section) as? UIImageView
//                    let cImageView = tableView.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
//                    if (self.expandedSectionHeaderNumber == indexPath.section) {
//                        tableViewCollapeSection(indexPath.section, imageView: eImageView)
//                    } else {
//                        tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView)
//                        tableViewExpandSection(indexPath.section, imageView: eImageView!)
//                    }
//
//                }
//
//                GlobalShareData.sharedGlobal.objCurrentLumineer = objLumineer
//            }
//        }
//    }
    
    @objc func onBtnFollowUnfollowTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if let cell = sender.superview?.superview as? LumineerCompanyCell {
            let indexPath = tableView.indexPath(for: cell)
            let arrayOfItems = self.aryCategory[(indexPath?.section)!].lumineerList
            
            var objLumineer : LumineerList!
            if isFiltering() {
                objLumineer = arySearchLumineer[(indexPath?.row)!] as LumineerList
            }
            else {
                objLumineer = arrayOfItems[(indexPath?.row)!] as LumineerList
            }


            let companyRegistrationNumber = objLumineer.companyRegistrationNumber!
            var strUniqueID: String = GlobalShareData.sharedGlobal.userCellNumber!
            strUniqueID += "_"
            strUniqueID += companyRegistrationNumber
            let strStatus : String = sender.isSelected ? "1":"0"
            let objLumiList = LumineerList()
            DispatchQueue.global(qos: .userInitiated).async {
                objLumiList.setLumineerCompanyFollowUnFollowData(id:GlobalShareData.sharedGlobal.userCellNumber,companyregistrationnumber:companyRegistrationNumber,uniqueID: strUniqueID, status:strStatus , completionHandler: { (List) in
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
    }
    
    // MARK: - Private instance methods
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        arySearchLumineer = []
        if searchBarIsEmpty() && scope == "All" {
            tableView.reloadData()
            return
        }
        else if searchBarIsEmpty() && scope == "My" {
            let realm = try! Realm()
            let realmObjects = realm.objects(LumiCategory.self)
            let result = realmObjects.filter("ANY lumineerList.status == 1")
            if result.count > 0 {
                for objCategory in result{
                for lumineer in objCategory.lumineerList.filter("status == 1") {
                        let  objLumineer = lumineer as LumineerList
                        arySearchLumineer.append(objLumineer)
                    // do something with your vegan meal
                    }
                    
                }
            }
        }
        else {
            let realm = try! Realm()
            let realmObjects = realm.objects(LumiCategory.self)
            let result = realmObjects.filter("ANY lumineerList.name CONTAINS[cd] '\(searchText)'")
            if result.count > 0 {
                let objCategory = result[0] as LumiCategory
                for lumineer in objCategory.lumineerList.filter("name CONTAINS[cd] '\(searchText)'") {
                        let  objLumineer = lumineer as LumineerList
                        arySearchLumineer.append(objLumineer)
                }
            }
        }
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
        do {
            guard !isFiltering() else {
                return
            }

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
                    tableViewCollapeSection(section!, imageView: eImageView)
                    eBtnView?.isSelected = false
                } else {
                    let cImageView = self.tableView.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                    let cBtnView = self.tableView.viewWithTag(kHeaderDataTag + self.expandedSectionHeaderNumber) as? UIButton
                    tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView)
                    tableViewExpandSection(section!, imageView: eImageView!)
                    cBtnView?.isSelected = false
                    let sectionData = self.aryCategory[section!].lumineerList
                    if sectionData.count>0{
                        eBtnView?.isSelected = true
                    }
                    
                }
            }
        } catch {
            print(error.localizedDescription)
        }

    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView?) {
        do {
            guard section != -1 else {
                return
            }

            let sectionData = self.aryCategory[section].lumineerList
            self.expandedSectionHeaderNumber = -1;
            if (sectionData.count == 0) {
                return;
            } else {
                if imageView != nil {
                UIView.animate(withDuration: 0.4, animations: {
                    imageView?.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
                })
                }
                var indexesPath = [IndexPath]()
                for i in 0 ..< sectionData.count {
                    let index = IndexPath(row: i, section: section)
                    indexesPath.append(index)
                }
                self.tableView!.beginUpdates()
                self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
                self.tableView!.endUpdates()
                
            }
        } catch {
            print(error.localizedDescription)
        }

    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        do {
            guard self.aryCategory.count != 0 else {
                return
            }
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
        } catch {
            print(error.localizedDescription)
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

extension UINavigationBar {
//    override open func layoutSubviews() {
//        super.layoutSubviews();
//        if #available(iOS 11, *){
//            self.layoutMargins = UIEdgeInsets()
//            for subview in self.subviews {
//                if String(describing: subview.classForCoder).contains("ContentView") {
//                    let oldEdges = subview.layoutMargins
//                    subview.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
//                }
//            }
//        }
//    }

}
extension UINavigationItem {
    func addSettingButtonOnRight(){
        let btn1 = UIButton(type: .custom)
        let img = UIImage(named: "Artboard 131xxhdpi")
        btn1.setImage(img, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.contentMode = .right
        btn1.addTarget(self, action:#selector(gotoSettingPage(_:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: btn1)
        self.rightBarButtonItems = [barButton]
    }
    func addBackButtonOnLeft(){
        let btn1 = UIButton(type: .custom)
        let img = UIImage(named: "Artboard 142xxxhdpi")
        btn1.setImage(img, for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action:#selector(gotoBackPage(_:)), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: btn1)
        self.leftBarButtonItem = barButton
    }

    @objc func gotoBackPage(_ sender: UIButton){
        if let topController = UIApplication.topViewController() {
            topController.navigationController?.popViewController(animated: true)
        }
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
            let cancelAction = UIAlertAction(title:"Cancel", style:.cancel)
            cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
            actionSheet.addAction(cancelAction)
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
        sender.superview?.parentViewController?.dismiss(animated: true, completion: {
            if btnAction.tag == 203 || btnAction.tag == 201 {
                var strUrl : String!
                var strTitle : String!

                if btnAction.tag == 203 {
                    strUrl = "http://196.223.97.152/portal/About-Lumi-World_191217.html"
                    strTitle = "About"
                }
                else {
                    strUrl = "http://196.223.97.152/portal/mobiletncs.html"
                    strTitle = "Terms & Conditions"
                }
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let objAboutPlusTC = storyBoard.instantiateViewController(withIdentifier: "AboutPlusTC") as! AboutPlusTC
                objAboutPlusTC.urlToDisplay = URL.init(string: strUrl)
                objAboutPlusTC.strTitle = strTitle
                GlobalShareData.sharedGlobal.objCurretnVC.navigationController?.pushViewController(objAboutPlusTC, animated: true)
            }
            else if btnAction.tag == 204 {
                
            }
            else if btnAction.tag == 200 {
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let objLumiSupportVC = storyBoard.instantiateViewController(withIdentifier: "LumiSupportVC") as! LumiSupportVC
                GlobalShareData.sharedGlobal.currentScreenValue = currentScreen.supportThread.rawValue
 GlobalShareData.sharedGlobal.objCurretnVC.navigationController?.pushViewController(objLumiSupportVC, animated: true)

            }
            else if btnAction.tag == 205 {
                GlobalShareData.sharedGlobal.realmManager.deleteDatabase()
                defer {
                    GlobalShareData.sharedGlobal.clearDiskCache()
                    DownloadManager.shared().cancelAllPendingDownloadTask()
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.messageTimeStamp.rawValue)
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.lumineerTimeStamp.rawValue)
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.supportTimeStamp.rawValue)
                    UserDefaults.standard.setBoolValue(value: false, key: UserDefaultsKeys.isAlreadyLogin)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let objLogInVC = storyBoard.instantiateInitialViewController()
                    UIApplication.shared.keyWindow?.rootViewController = objLogInVC }
            }
        })
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
        newEncodeData = strEncodeData.replacingOccurrences(of: "data:image/jpeg;base64,", with: "")
        if let decData = Data(base64Encoded: newEncodeData, options: .ignoreUnknownCharacters), newEncodeData.characters.count > 0 {
            return UIImage(data: decData)!
        }
        return UIImage()
    }
}
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
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
@available(iOS 11.0, *)
extension LumiCategoryVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

@available(iOS 11.0, *)
extension LumiCategoryVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

func appDelInstance() -> AppDelegate{
    return UIApplication.shared.delegate as! AppDelegate
}
extension UIColor {
    static let lumiGreen = UIColor(red: 110, green: 187, blue: 171)
    static let lumiGray = UIColor.init(hexString: "757576")

}

