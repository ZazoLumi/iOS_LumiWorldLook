//
//  CustomTableView.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/14.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MaterialTextField

protocol FormDataDelegate {
    func processedFormData(formData: Dictionary<String, String>)
}

class CustomTableView: UIView, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,ValidationDelegate, EPPickerDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    var formDelegate: FormDataDelegate?
    var isTopTitle = false
    var pickOption = ["Email Address", "Facebook", "Instagram", "LinkedIn", "Twiteer"]
    var isItemPicked = false

    func validationSuccessful() {
        var dict =  Dictionary<String, String>()
        for (index, element) in texts[0].enumerated() {
            print("Item \(index): \(element)")
            dict.updateValue("\(element)", forKey: "\(index)")
        }
        formDelegate?.processedFormData(formData: dict)
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        
    }
    
    open var placeholders: [[String]]
    open var texts: [[String]]
    open var images: [[String]]
    open var rules: [[String: [Rule]]]
    open var fieldType: [[NSNumber]]
    var pickerTextField = UITextField()
    var tableView: UITableView!
    var compareField : UITextField!
    let validator = Validator()
    var isFromProfile = false
    public init(placeholders: [[String]], texts: [[String]], images: [[String]], frame:CGRect, rrules: [[String: [Rule]]], fieldType:[[NSNumber]]) {
        self.placeholders = placeholders
        self.texts = texts
        self.images = images
        self.rules = rrules
        self.fieldType = fieldType
        
        tableView = UITableView(frame: frame)
        tableView.separatorStyle = .none
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: String(describing: TextFieldTableViewCell.self))

        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)
        validator.styleTransformers(success:{ (validationRule) -> Void in
            print("here")
            // clear error label
            if let textField = validationRule.field as? MFTextField {
                textField.layer.borderColor = UIColor.black.cgColor
                textField.setError(nil, animated: true)
                self.tableView.reloadData()
            }

        }, error:{ (validationError) -> Void in
            print("error")
            if let textField = validationError.field as? MFTextField {
                var errortest: Error? = nil
                errortest = self.errordata(withLocalizedDescription: validationError.errorMessage)
                textField.setError(errortest, animated: true)
                textField.layer.borderColor = UIColor.red.cgColor
                self.tableView.reloadData()
            }
        })

    }
    //  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
    let MFDemoErrorDomain = "MFDemoErrorDomain"
    let MFDemoErrorCode: Int = 100
    
    func errordata(withLocalizedDescription localizedDescription: String?) -> Error? {
        let userInfo = [NSLocalizedDescriptionKey: localizedDescription]
        return NSError(domain: MFDemoErrorDomain, code: MFDemoErrorCode, userInfo: userInfo)
    }

    required public convenience init?(coder aDecoder: NSCoder) {
        print(Decoder.self)
        self.init(coder: aDecoder)
    }

    
    // data source
    
    // a function that will be called by the delegate object
    // when a row is selected
    func didSelectRow(dataItem: Int, cell: UITableViewCell) {
//        let alert = UIAlertController(title: "Info", message: "\(dataItem) was selected.", preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//        presentViewController(alert, animated: true, completion: nil)
    }
    open func numberOfSections(in tableView: UITableView) -> Int {
        return texts.count
    }
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isFromProfile{
            return 48
        }
        else {
            return 68 }
        return 68
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts[section].count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TextFieldTableViewCell.self), for: indexPath) as! TextFieldTableViewCell
        configure(cell: cell, forRowAt: indexPath)
        let textField = cell.textField
        configureTextField(textField, forRowAt: indexPath)
        return cell
    }
    
    open func configure(cell: TextFieldTableViewCell, forRowAt indexPath: IndexPath) {
        // Subclasses override this method
    }
    
    open func configureTextField(_ textField: MFTextField, forRowAt indexPath: IndexPath) {
        textField.setImageName = images[indexPath.section][indexPath.row]
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.returnKeyType = !isLastIndexPath(indexPath) ? .next : .done
        textField.text = texts[indexPath.section][indexPath.row]
        if ((textField.text!.count) > 0 ) {
            textField.placeholder = ""
        }
        else {
            textField.placeholder = self.placeholders[indexPath.section][indexPath.row]
        }
        if isTopTitle { textField.animatesPlaceholder = true}
        
        if isFromProfile {
            let imgView = textField.leftView?.viewWithTag(100) as! UIImageView
            imgView.frame = CGRect(x: (imgView.frame.origin.x), y: 15, width: (imgView.frame.size.width), height: (imgView.frame.size.height))
            if !(textField.rightView != nil) && (fieldType[indexPath.section][indexPath.row] == 1 || placeholders[indexPath.section][indexPath.row] == "Reach out via") {
                var image = UIImage.init(named: "Asset 2477")
                let viewPadding = UIView(frame: CGRect(x: 0, y: 0, width: 40 , height: 32))
                let button = UIButton.init(type: .custom)
                button.frame = CGRect(x: 0, y: 20, width: (image?.size.width)! , height: (image?.size.height)!)
                button.backgroundColor = UIColor.clear
                button.setTitle("", for: .normal)
                button.tag = 200
                if placeholders[indexPath.section][indexPath.row] == "Reach out via" {
                    image = UIImage.init(named: "Chevron-Dn-Wht")
                    button.contentHorizontalAlignment = .right
                    var pickerView = UIPickerView()
                    
                    pickerView.delegate = self
                    pickerTextField = textField
                    pickerTextField.inputView = pickerView

                }
                else {
                    button.addTarget(self, action: #selector(onBtnContactListTapped), for: .touchUpInside) }
                button.setImage(image, for: .normal)
                viewPadding .addSubview(button)
                textField.rightView = viewPadding
                textField.rightViewMode = .always
            }
        }
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let dicRules = self.rules[indexPath.row] as [String: [Rule]]
        var arrRules = dicRules["rule"]
        if fieldType[indexPath.section][indexPath.row] == 1 {
            textField.keyboardType = UIKeyboardType.phonePad
        }
        else if fieldType[indexPath.section][indexPath.row] == 8 {
            textField.keyboardType = UIKeyboardType.emailAddress
        }
        else if fieldType[indexPath.section][indexPath.row] == 2 {
            textField.isSecureTextEntry = true
            compareField = textField
        }
        else if fieldType[indexPath.section][indexPath.row] == 3 {
            textField.isSecureTextEntry = true
            arrRules?.remove(at: 1)
            arrRules?.append(ConfirmationRule(confirmField: compareField as! ValidatableField) as Rule)
        }
        
        if fieldType[indexPath.section][indexPath.row] == 1 && isTopTitle {
            textField.isUserInteractionEnabled = false
        }


        validator.registerField(textField , errorLabel: label , rules:arrRules!)

    }
    @objc func onBtnContactListTapped(sender: UIButton!) {
        let contactPickerScene = EPContactsPicker(delegate: self, multiSelection:false, subtitleCellType: SubtitleCellValue.email)
        let navigationController = UINavigationController(rootViewController: contactPickerScene)
        GlobalShareData.sharedGlobal.isContactPicked = true
        self.parentViewController?.present(navigationController, animated: true, completion: nil)

        print("Button tapped")
    }
    //MARK: EPContactsPicker delegates
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error : NSError)
    {
        print("Failed with error \(error.description)")
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectContact contact : EPContact)
    {
        print("Contact \(contact.displayName()) has been selected")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            for (index, element) in self.fieldType[0].enumerated() {
                if index == 0 {
                    self.texts[0][index] = contact.firstName
                }
                else if index == 1 {
                    self.texts[0][index] = contact.lastName}
                else if index == 2 {
                    var phoneNumber = contact.phoneNumbers[0].phoneNumber
                    phoneNumber = phoneNumber.replacingOccurrences(of: "-", with:"")
                    self.texts[0][index] = phoneNumber}
                
                print("Item \(index): \(element)")
                // dict.updateValue("\(element)", forKey: "\(index)")
            }
            self.tableView.reloadData()
        }
    }
    
    func epContactPicker(_: EPContactsPicker, didCancel error : NSError)
    {
        print("User canceled the selection");
    }
    
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) {
        print("The following contacts are selected")
        for contact in contacts {
            print("\(contact.displayName())")
        }
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let indexPath = tableView.indexPath(for: textField)!
        if placeholders[indexPath.section][indexPath.row] == "Reach out via" {
            
        }
        return true
    }
   @objc func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            if ((updatedText.count) > 0 ) {
                textField.placeholder = ""
            }
        }
        return true
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        let indexPath = tableView.indexPath(for: textField)!
        texts[indexPath.section][indexPath.row] = textField.text!
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let indexPath = tableView.indexPath(for: textField)!
        var nextIndexPath: IndexPath
        
        if !isLastRow(indexPath.row, inSection: indexPath.section) {
            nextIndexPath = IndexPath(row: indexPath.row+1, section: indexPath.section)
        } else if !isLastSection(indexPath.section) {
            nextIndexPath = IndexPath(row: 0, section: indexPath.section+1)
        } else {
            doneAction()
            textField.resignFirstResponder()
            return true
        }
        tableView.textFieldForRow(at: nextIndexPath)!.becomeFirstResponder()
        return false
    }
    
    // MARK: - Actions
    
    @objc open func doneAction() {
        validator.validate(self)
        // Subclasses override this method
    }
    
    // MARK: - Helpers
    
    private func isLastRow(_ row: Int, inSection section: Int) -> Bool {
        return row == texts[section].count-1
    }
    
    private func isLastSection(_ section: Int) -> Bool {
        return section == texts.count-1
    }
    
    private func isLastIndexPath(_ indexPath: IndexPath) -> Bool {
        return isLastSection(indexPath.section) && isLastRow(indexPath.row, inSection: indexPath.section)
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickOption[row]
        self.texts[0][2] = pickerTextField.text!
        if !isItemPicked {
            isItemPicked = true
        self.texts[0].insert("", at: 3)
        self.placeholders[0].insert("Enter contact details here", at: 3)
        self.images[0].insert("", at: 3)
        let dict1: [Rule] = [RequiredRule(), MinLengthRule()]
      //  self.rules[0].in(["rule":dict1], at: 3)
        self.rules.append(["rule":dict1])
        self.fieldType[0].insert(4, at: 3)
            tableView.reloadData() }
    }
    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
    
    

}


