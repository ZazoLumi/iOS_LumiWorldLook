//
//  CallLumineerVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/10/11.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import RealmSwift

class callLumineerCell: UITableViewCell {
    @IBOutlet var imgLumineerProfile: UIImageView!
    @IBOutlet var lblLumineerTitle: UILabel!
    @IBOutlet var lblMessageDetails: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        //        self.imgLumineerProfile.layer.cornerRadius = self.imgLumineerProfile.bounds.size.height/2
        //        self.imgLumineerProfile.layer.borderWidth = 0.5;
        //        self.imgLumineerProfile.layer.borderColor = UIColor.lumiGreen?.cgColor;
    }
}

class CallLumineerVC: UIViewController , UITableViewDelegate,UITableViewDataSource{
    @IBOutlet weak var tableView: UITableView!
    var aryActivityData: [LumineerList]? = []
    var arySearchData: [LumineerList]? = []
    var strSearchText : NSString!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(MyLumiFeedVC.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.lumiGreen
        
        return refreshControl
    }()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.addSettingButtonOnRight()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.titleTextAttributes = attributes

        self.tableView.addSubview(self.refreshControl)
        self.tableView!.tableFooterView = UIView()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 64
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.getLatestLumineers()
        GlobalShareData.sharedGlobal.objCurretnVC = self
        self.navigationItem.title = "MY LUMINEER CALL"
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Feed"
        self.navigationItem.searchController = searchController
        definesPresentationContext = true
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = []
        searchController.searchBar.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchController.isActive = false
        self.tabBarController?.navigationItem.searchController = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLatestLumineers() {
        aryActivityData = []
        let realm = try! Realm()
        let result = realm.objects(LumineerList.self)
        aryActivityData = result.compactMap { return $0 }
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    // MARK: - Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableView.backgroundView = nil
        if isFiltering() {
            if arySearchData?.count == 0 && !searchBarIsEmpty() {
                let imgBg = UIImageView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
                imgBg.image = UIImage.init(named: "Asset 335")
                imgBg.contentMode = .scaleAspectFit
                self.tableView.backgroundView = imgBg;
                return 0
            }
            return arySearchData!.count
        }
        strSearchText = ""
        return aryActivityData!.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callLumineerCell", for: indexPath) as! callLumineerCell
        var objCellData : LumineerList!
        
        if isFiltering() {
            objCellData = arySearchData![indexPath.row] as LumineerList
        }
        else {
            objCellData = aryActivityData![indexPath.row] as LumineerList
        }
        cell.lblLumineerTitle.text = objCellData.displayName
        cell.lblMessageDetails.text = objCellData.contactNumber

        let imgThumb = UIImage.decodeBase64(strEncodeData:objCellData.enterpriseLogo)
        let scalImg = imgThumb.af_imageScaled(to: CGSize(width: cell.imgLumineerProfile.frame.size.width-10, height: cell.imgLumineerProfile.frame.size.height-10))
        cell.imgLumineerProfile.image = scalImg
        cell.imgLumineerProfile?.layer.cornerRadius = (scalImg.size.width)/2
        cell.imgLumineerProfile?.clipsToBounds = true;
        
        return cell
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var objCellData : LumineerList!
        if isFiltering() {
            objCellData = arySearchData![indexPath.row] as LumineerList
        }
        else {
            objCellData = aryActivityData![indexPath.row] as LumineerList
        }
        
        objCellData.contactNumber?.makeAColl()
        searchController.isActive = false
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getLatestLumineers()
    }
    
    @objc func didTapGetStarted() {
        self.tabBarController?.selectedIndex = 2
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        strSearchText = searchText as NSString
        guard strSearchText.length != 0 else {
            arySearchData = aryActivityData
            self.tableView.reloadData()
            return
        }
        arySearchData = []
        let realm = try! Realm()
       let aryResultData = realm.objects(LumineerList.self).filter("name CONTAINS[cd] '\(searchText)'")
        arySearchData = aryResultData.compactMap{ return $0 }
            self.tableView.reloadData()
    }
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
}
@available(iOS 11.0, *)
extension CallLumineerVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeAColl() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}



@available(iOS 11.0, *)
extension CallLumineerVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        _ = searchController.searchBar
        // let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: "")
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

