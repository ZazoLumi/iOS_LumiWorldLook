//
//  SendMessage.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/04/10.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class PopupSendMessage: UIViewController,UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    var activityType : String!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var imgAttach: UIImageView!
    @IBOutlet weak var btnAttachment: UIButton!
    @IBOutlet weak var tvMessage: UITextView!
    let cellReuseIdentifier = "cell"
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: NoCopyPasteUITextField!
    @IBOutlet weak var tableView: UITableView!
    var values = ["123 Main Street", "789 King Street", "456 Queen Street", "99 Apple Street"]

    //
    // MARK: View lifcycle methods
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
        tableView.isHidden = true
        tableView.cornerRadius = 5
        // Manage tableView visibility via TouchDown in textField
        textField.addTarget(self, action: #selector(textFieldActive), for: UIControlEvents.touchDown)
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews()
    {
        // Assumption is we're supporting a small maximum number of entries
        // so will set height constraint to content size
        // Alternatively can set to another size, such as using row heights and setting frame
        heightConstraint.constant = tableView.contentSize.height
    }

    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func onBtnClosePopupTapped(_ sender: Any) {
        self.view.superview?.removeBlurEffect()
        removeAnimate()
    }
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool) in
            if(finished)
            {
                self.willMove(toParentViewController: nil)
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK: Custome methods
    //

    @IBAction func onBtnSendTapped(_ sender: Any) {
        if imgAttach.image != nil {
            
        }
        else {
            //newsFeed:{"newsFeedBody":"Test","enterpriseName":"Lumineer 14042018","enterpriseRegnNmbr":"14042018","messageCategory":"Products","messageType":"1","sentBy":"27735526844-Christian Nhlabano","imageURL":"","longitude":"","latitude":"","messageSubject":"Test123"}
            
            let name = GlobalShareData.sharedGlobal.objCurrentLumineer.name! + " \(GlobalShareData.sharedGlobal.objCurrentLumineer.surname as! String)"
            let sentBy: String = GlobalShareData.sharedGlobal.userCellNumber + "-\(name)"

            let objMessage = LumiMessage()
            objMessage.sendLumiTextMessage(param: ["newsFeedBody":tvMessage.text,"enterpriseName":GlobalShareData.sharedGlobal.objCurrentLumineer.companyRegistrationNumber!,"messageCategory":activityType,"messageType":"1","sentBy":sentBy,"imageURL":"","longitude":"","latitude":"","messageSubject":textField.text!], completionHandler: { (json) in
                
            })
        }
    }
    @IBAction func onBtnAttachmentTapped(_ sender: Any) {
        CameraHandler.shared.showActionSheet(vc: self)
        CameraHandler.shared.imagePickedBlock = { (image) in
            /* get your image here */
            self.imgAttach.image = image
        }

    }
    
    @IBAction func textFieldChanged(_ sender: AnyObject) {
        tableView.isHidden = true
    }

    //
    // MARK: TextView Delegate methods
    //

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter Message" {
            textView.text = nil
            textView.textColor = UIColor.black
            textField.endEditing(true)
            tableView.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Message"
            textView.textColor = .lumiGray
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            textView.text = "Enter Message"
            textView.textColor = .lumiGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
            
        else if textView.text == "Enter Message" && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }

    // Manage keyboard and tableView visibility
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        guard let touch:UITouch = touches.first else
        {
            return;
        }
        if touch.view != tableView
        {
            textField.endEditing(true)
            tableView.isHidden = true
        }
    }
    
    // Toggle the tableView visibility when click on textField
    @objc func textFieldActive() {
        tableView.isHidden = !tableView.isHidden
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        // TODO: Your app can do something when textField finishes editing
        print("The textField ended editing. Do something based on app requirements.")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        // Set text from the data model
        cell.textLabel?.text = values[indexPath.row]
        cell.textLabel?.font = textField.font
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selected, so set textField to relevant value, hide tableView
        // endEditing can trigger some other action according to requirements
        textField.text = values[indexPath.row]
        tableView.isHidden = true
        textField.endEditing(true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 34
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }



}
