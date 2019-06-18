//
//  VC1.swift
//  CustomSEgmentedControl
//
//  Created by Leela Prasad on 18/01/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import Kingfisher

class LumineerContentCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imgPlay: UIImageView!
}

class LumineerHomeVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    var aryContentData : [[String:AnyObject]] = []
    let reuseIdentifier = "cell"
    weak var delegate: ScrollContentSize?
    var objAdvertiseVC : AdvertiseVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Define Layout here
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        //Get device width
        let width = UIScreen.main.bounds.width
        //set section inset as per your requirement.
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        //set cell item size here
        layout.itemSize = CGSize(width: width / 3.1, height: width / 3.1)
        //set Minimum spacing between 2 items
        layout.minimumInteritemSpacing = 0
        //set minimum vertical line spacing here between two lines in collectionview
        layout.minimumLineSpacing = 2
        //apply defined layout to collectionview
        collectionView!.collectionViewLayout = layout
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupCotentData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.resetScrollContentOffset()
    }

    func setupCotentData() {
        aryContentData = []
        aryContentData = GlobalShareData.sharedGlobal.getAllContents(isCurrentLumineer: true)
        delegate?.changeScrollContentSize((aryContentData.count*110/3)+250)
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource protocol
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.aryContentData.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! LumineerContentCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerContent

        var urlOriginalImage : URL? = nil
        
        if objContent?.contentType == "video" {
            cell.imgPlay.isHidden = false
            if objContent?.adMediaURL != nil {
                if(objContent?.adMediaURL?.hasUrlPrefix())!
                {
                    urlOriginalImage = URL.init(string: (objContent?.adMediaURL!)!)
                }
                else {
                    var fileName = objContent?.contentFileName?.replacingOccurrences(of: " ", with: "-")
                    _ = fileName?.pathExtension
                    let pathPrefix = fileName?.deletingPathExtension
                    fileName = "\(pathPrefix!).png"
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
            }
        }
        else if objContent?.contentType == "audio" {
            cell.imgPlay.isHidden = false
        }
        else {
            cell.imgPlay.isHidden = true
            if objContent?.adMediaURL != nil {
                if(objContent?.adMediaURL?.hasUrlPrefix())!
                {
                    urlOriginalImage = URL.init(string: (objContent?.adMediaURL!)!)
                }
                else {
                    let fileName = objContent?.contentFileName?.replacingOccurrences(of: " ", with: "-")
                    urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
                }
            }
        }
        cell.imageView.contentMode = .scaleAspectFit
        if urlOriginalImage != nil {
            Alamofire.request(urlOriginalImage!).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    let scalImg = image.af_imageAspectScaled(toFill: CGSize(width: cell.imageView.size.width, height: cell.imageView.size.height))
                    UIView.animate(withDuration: 1.0, animations: {
                        cell.imageView.image = scalImg
                    })

                }
            }}
        cell.imageView.contentMode = .scaleAspectFit

        cell.backgroundColor = UIColor.clear // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        /*var objCellData : [String : Any]!
        objCellData = aryContentData[indexPath.row]
        let objContent = objCellData["message"] as? LumineerContent

        
        GlobalShareData.sharedGlobal.isVideoPlaying = false
        GlobalShareData.sharedGlobal.objCurrentContent = objContent
        let realm = try! Realm()
        let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objContent?.lumineerId.int ?? Int.self)
        if objsLumineer.count > 0 {
            let lumineer = objsLumineer[0]
            GlobalShareData.sharedGlobal.objCurrentLumineer = lumineer
        }
        GlobalShareData.sharedGlobal.objCurretnVC.view.addBlurEffect()
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        objAdvertiseVC = storyBoard.instantiateViewController(withIdentifier: "AdvertiseVC") as! AdvertiseVC
       self.objAdvertiseVC.screenType = .Content
        GlobalShareData.sharedGlobal.objCurretnVC.addChild(self.objAdvertiseVC)
        self.objAdvertiseVC.view.frame = CGRect(x: 0, y: (self.view.frame.size.height-380)/2, width:self.view.frame.size.width, height:390);
        GlobalShareData.sharedGlobal.objCurretnVC.view.addSubview(self.objAdvertiseVC.view)
        self.objAdvertiseVC
            .didMove(toParent: self)*/
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
