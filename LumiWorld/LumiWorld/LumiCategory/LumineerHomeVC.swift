//
//  VC1.swift
//  CustomSEgmentedControl
//
//  Created by Leela Prasad on 18/01/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit
class LumineerContentCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

class LumineerHomeVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var aryContentData : [LumineerContent] = []
    let reuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupCotentData()
    }
    
    func setupCotentData() {
        aryContentData = []
        aryContentData = GlobalShareData.sharedGlobal.getAllContents()
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
        let objContent = self.aryContentData[indexPath.item]
        
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
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
