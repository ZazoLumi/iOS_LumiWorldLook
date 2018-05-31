//
//  WelcomView.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/30.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
@IBDesignable
class WelcomView: UIView {

    @IBOutlet weak var btnGetStarted: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIButton
        
        return view
    }

}
