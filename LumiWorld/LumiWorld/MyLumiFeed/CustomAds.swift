//
//  CustomAds.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/08/17.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class CustomAds: UIView {
    @IBOutlet weak var lblAdvTitle: UILabel!
    @IBOutlet weak var lblAdvPostedTime: UILabel!
    @IBOutlet weak var btnSaveAds: UIButton!
    @IBOutlet weak var btnSared: UIButton!
    @IBOutlet weak var btnCopy: UIButton!

    @IBOutlet weak var imgAdvType: UIImageView!
    @IBOutlet weak var lblLumineerName: UILabel!
    @IBOutlet weak var imgLumineerProfile: UIImageView!
    @IBOutlet weak var imgAdsContent: UIImageView!
    @IBOutlet weak var imgPlayIcon: UIImageView!

    let nibName = "CustomAds"
    var contentView:UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }

}
