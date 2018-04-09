//
//  LumineerProfileVC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/04/05.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class SubjectCell: UITableViewCell {
    
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgMessage: UIImageView!
    @IBOutlet weak var constImgWidth: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgMessage.layer.cornerRadius = self.imgMessage.bounds.size.height * 0.50
        self.imgMessage.layer.borderWidth = 0.5;
        self.imgMessage.layer.borderColor = UIColor.clear.cgColor;
        
    }
    
    
}

class LumineerProfileVC: UIViewController,ExpandableLabelDelegate {
    let kHeaderSectionTag: Int = 6900;
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!

    @IBOutlet weak var btnSupport: UIButton!
    @IBOutlet weak var lblLumiProfileTxt: UILabel!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var btnProduct: UIButton!
    @IBOutlet weak var tblActivityData: UITableView!
    @IBOutlet weak var ratingVC: FloatRatingView!
    @IBOutlet weak var lblExpandableDescription: ExpandableLabel!
    @IBOutlet weak var lblCompanyName: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var btnInboxCount: UIButton!
    @IBOutlet weak var lblFollowers: UILabel!
    lazy var aryActivityData: [SectionData] = {
        let section1 = SectionData(title: "PRODUCTS",text:"Test message",date:"12:00", data: [["subject":"Test subject","text":"Test message from","date":"12:00","imgName":""],["subject":"NewTest subject","text":"Test message from","date":"12:00","imgName":""]],imgName:"Artboard 91xxhdpi")
    let section2 = SectionData(title: "ACCOUNTS",text:"Test message",date:"12:00", data: [["subject":"Test subject","text":"Test message from","date":"12:00","imgName":""],["subject":"NewTest subject","text":"Test message from","date":"12:00","imgName":""],["subject":"Other subject","text":"Test message from","date":"12:00","imgName":""]],imgName:"Artboard 92xxhdpi")
        return [section1, section2]
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblExpandableDescription.delegate = self
        lblExpandableDescription.setLessLinkWith(lessLink: "Close", attributes: [.foregroundColor:UIColor.red], position: .left)
        
        lblExpandableDescription.shouldCollapse = true
        lblExpandableDescription.textReplacementType = .word
        lblExpandableDescription.numberOfLines = 2
        lblExpandableDescription.text = "On third line our text need be collapsed because we have ordinary text, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."
        btnProduct.setTitle("PRODUCTS", for: .normal)
        btnProduct.setTitle("PRODUCTS", for: .selected)
        
        btnAccount.setTitle("ACCOUNTS", for: .normal)
        btnAccount.setTitle("ACCOUNTS", for: .normal)
        
        btnSupport.setTitle("SUPPORT", for: .normal)
        btnSupport.setTitle("SUPPORT", for: .normal)
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleRatingTapFrom(recognizer:)))
        self.ratingVC.addGestureRecognizer(tapGestureRecognizer)
        self.ratingVC.isUserInteractionEnabled = true
    }
    
    @objc func handleRatingTapFrom(recognizer : UITapGestureRecognizer)
    {
        showRatingAlert { (rating) in
            let objLumiList = LumineerList()

            let param = ["rating": "","ratingDesc":"","enterpriseId":"","cellNumber":"","userName":""]
            objLumiList.setLumineerCompanyRatings(param: param, completionHandler: { (response) in
                
            })

        }
    }

    //
    // MARK: ExpandableLabel Delegate
    //
    
    func willExpandLabel(_ label: ExpandableLabel) {
    }
    
    func didExpandLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = true
    }
    
    func willCollapseLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = false
        lblExpandableDescription.numberOfLines = 2

    }
    
    func didCollapseLabel(_ label: ExpandableLabel) {
        lblExpandableDescription.shouldCollapse = true
        lblExpandableDescription.numberOfLines = 2

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBtnFacebookTapped(_ sender: Any) {
    }
    
    @IBAction func onBtnTwitterTapped(_ sender: Any) {
    }
    @IBAction func onBtnInstagramTapped(_ sender: Any) {
    }
    @IBAction func onBtnLinkedInTapped(_ sender: Any) {
    }
    @IBAction func onBtnPhoneCallTapped(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onBtnProductTapped(_ sender: Any) {
    }
    
    @IBAction func onBtnSupportTapped(_ sender: Any) {
    }
    @IBAction func onBtnAccountsTapped(_ sender: Any) {
    }
}

extension LumineerProfileVC : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame

        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height))
        headerView.backgroundColor = UIColor.clear
        headerView.cornerRadius = 5

        let innerView = UIView.init(frame: CGRect(x: 0, y: 5, width: headerView.frame.size.width, height: 40))
        innerView.backgroundColor = UIColor.init(red: 238, green: 238, blue: 238)
        innerView.cornerRadius = 5
        
        let lblTitle = UILabel(frame: CGRect(x: 10, y: 5, width: innerView.frame.size.width-70, height: 16))
        lblTitle.font  = UIFont.init(name: "Helvetica", size: 14)
        lblTitle.textColor = UIColor.black
        lblTitle.backgroundColor = UIColor.clear
        lblTitle.text = aryActivityData[section].title
        innerView.addSubview(lblTitle)
        
        let lblTime = UILabel(frame: CGRect(x: lblTitle.frame.size.width+5, y: 5, width: 60, height: 12))
        lblTime.font  = UIFont.init(name: "Helvetica", size: 10)
        lblTime.textColor = UIColor.black
        lblTime.backgroundColor = UIColor.clear
        lblTime.textAlignment = .center
        lblTime.text = aryActivityData[section].date
        innerView.addSubview(lblTime)

        
        let imgIcon = UIImageView(frame: CGRect(x: 10, y: 21, width: 16, height: 16));
        imgIcon.image = UIImage(named: aryActivityData[section].imgName)
        imgIcon.contentMode = .scaleAspectFit
        innerView.addSubview(imgIcon)
        
        let lblDesc = UILabel(frame: CGRect(x: 30, y: 21, width: innerView.frame.size.width-20, height: 16))
        lblDesc.font  = UIFont.init(name: "Helvetica", size: 12)
        lblDesc.textColor = UIColor.lumiGray
        lblDesc.backgroundColor = UIColor.clear
        lblDesc.text = aryActivityData[section].text
        innerView.addSubview(lblDesc)

        
        let theImageView = UIImageView(frame: CGRect(x: headerFrame.width - 20, y: 5, width: 14, height: 14));
        theImageView.image = UIImage(named: "Chevron-Dn-Wht")
        theImageView.contentMode = .scaleAspectFit
        theImageView.tag = kHeaderSectionTag + section
        innerView.addSubview(theImageView)
        headerView.addSubview(innerView)

        // make headers touchable
        headerView.tag = section
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(LumineerProfileVC.sectionHeaderWasTouched(_:)))
        headerView.addGestureRecognizer(headerTapGesture)
        return headerView
        
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return aryActivityData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            return self.aryActivityData[section].data.count;
        } else {
            return 0;
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubjectCell", for: indexPath) as! SubjectCell
        let objSubject = aryActivityData[indexPath.section].data[indexPath.row]
        
        cell.lblSubject.text = objSubject["subject"]
        cell.lblDate.text = objSubject["date"]

        let imgName = objSubject["imgName"] as! String
        if imgName.count == 0 {
            cell.constImgWidth.constant = 0
        }
        else {
            cell.imgMessage.image = UIImage(named:imgName)
        }
        cell.lblMessage.text = objSubject["text"]

        return cell
    }
    
    // MARK: - Expand / Collapse Methods
    
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        do {
            let headerView = sender.view
            let section    = headerView?.tag
            let eImageView = headerView?.viewWithTag(kHeaderSectionTag + section!) as? UIImageView
            
            if (self.expandedSectionHeaderNumber == -1) {
                self.expandedSectionHeaderNumber = section!
                tableViewExpandSection(section!, imageView: eImageView!)
            } else {
                let cImageView = tblActivityData.viewWithTag(kHeaderSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                if (self.expandedSectionHeaderNumber == section) {
                    tableViewCollapeSection(section!, imageView: eImageView)
                } else {
                    tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: cImageView)
                    tableViewExpandSection(section!, imageView: eImageView!)
                    
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
            
            let sectionData = self.aryActivityData[section].data
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
                self.tblActivityData!.beginUpdates()
                self.tblActivityData!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
                self.tblActivityData!.endUpdates()
                
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        do {
            let sectionData = self.aryActivityData[section].data
            
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
                self.tblActivityData!.beginUpdates()
                self.tblActivityData!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
                self.tblActivityData!.endUpdates()
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }

    
}


struct SectionData {
    let title: String
    let text: String
    let date: String
    let imgName: String
    let data : [[String:String]]
    
    init(title: String,text: String,date: String, data: [[String:String]],imgName:String) {
        self.title = title
        self.text = text
        self.date = date
        self.data  = data
        self.imgName = imgName
    }
    var numberOfItems: Int {
        return data.count
    }

    subscript(index: Int, key:String) -> String {
        guard let coordinate = data[index][key] else {
            return ""
        }
        return coordinate
    }

//    subscript(index: Int) -> [String:String]? {
//        guard let coordinate = self.data[index] as! [String: String] else {
//            return nil
//        }
//        return coordinate
//    }
    
    
}


