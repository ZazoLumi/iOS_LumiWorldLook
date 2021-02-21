//
//  CustomSegmentedContrl.swift
//  CustomSEgmentedControl
//
//  Created by Leela Prasad on 18/01/18.
//  Copyright © 2018 Leela Prasad. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentedContrl: UIControl {
    
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex = 0
    let scrollView = UIScrollView()

    
    
    @IBInspectable var borderWidth1: CGFloat = 0 {
        
        didSet {
            layer.borderWidth = borderWidth1
        }
    }
    
    
    @IBInspectable var cornerRadius1: CGFloat = 0 {
        
        didSet {
            layer.cornerRadius = cornerRadius1
        }
    }
    
    
    @IBInspectable var borderColor1: UIColor = .clear {
        
        didSet {
            layer.borderColor = borderColor1.cgColor
        }
    }
    
    @IBInspectable var commaSeperatedButtonTitles: String = "" {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.lumiGray! {
        
        didSet {
            updateView()
        }
    }
    
    
    @IBInspectable var selectorColor: UIColor = UIColor.lumiGreen! {
        
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var selectorTextColor: UIColor = UIColor.lumiGreen! {
        
        didSet {
            updateView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateView() {
        
        buttons.removeAll()
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        
        
        
        let buttonTitles = commaSeperatedButtonTitles.components(separatedBy: ",")
        
        for buttonTitle in buttonTitles {
            
            let button = UIButton.init(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            button.titleLabel?.font = UIFont.init(name: "HelveticaNeue", size: 10)
            buttons.append(button)
//            button.setTitleColor(button.isSelected ? UIColor.gray : selectorTextColor, for: .normal)
        }
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        
        var selectorWidth = frame.width / CGFloat(buttonTitles.count)
        selectorWidth -= 20
        let y =    (self.frame.maxY - self.frame.minY) - 3.0
        
        selector = UIView.init(frame: CGRect.init(x: 0, y: y, width: selectorWidth, height: 3.0))
        //selector.layer.cornerRadius = frame.height/2
        selector.backgroundColor = selectorColor
        addSubview(selector)
        
        // Create a StackView
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        scrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true

        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width + 450, height: self.height)
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.bouncesZoom = false
        scrollView.showsHorizontalScrollIndicator = false
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 10.0
        scrollView.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0.0).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0.0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0.0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0.0).isActive = true
        
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        // Drawing code
        
       // layer.cornerRadius = frame.height/2
        
    }
    

    @objc func buttonTapped(button: UIButton) {
        for (buttonIndex,btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == button {
                selectedSegmentIndex = buttonIndex
                let  selectorStartPosition = button.frame.origin.x
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = selectorStartPosition + 2
                    self.selector.width = button.frame.size.width
                })
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
    
    func updateSegmentedControlSegs(index: Int) {
        
        for btn in buttons {
            btn.setTitleColor(textColor, for: .normal)
        }
        
        let  selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.selector.frame.origin.x = selectorStartPosition
        })
        
        buttons[index].setTitleColor(selectorTextColor, for: .normal)
    }


    
}
extension String {
    func SizeOf(_ font: UIFont) -> CGSize {
        return self.size(withAttributes: [NSAttributedString.Key.font: font])
    }
}
