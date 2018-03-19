//
//  CustomTableView.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/14.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import MaterialTextField

class CustomTableView: UIView, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,ValidationDelegate {
    func validationSuccessful() {
        
    }
    
    func validationFailed(_ errors: [(Validatable, ValidationError)]) {
        
    }
    
    open let placeholders: [[String]]
    open var texts: [[String]]
    open var images: [[String]]
    open var rules: [[String: [Rule]]]

    var tableView: UITableView!
    let validator = Validator()

    public init(placeholders: [[String]], texts: [[String]], images: [[String]], frame:CGRect, rrules: [[String: [Rule]]]) {
        self.placeholders = placeholders
        self.texts = texts
        self.images = images
        self.rules = rrules

        tableView = UITableView(frame: frame)
        
        tableView.rowHeight = 64
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
                errortest = self.errordata(withLocalizedDescription: "Maximum of 6 characters allowed.")
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
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        let dicRules = self.rules[indexPath.row] as [String: [Rule]]
        let arrRules = dicRules["rule"]
        validator.registerField(textField , errorLabel: label , rules:arrRules!)

    }
    
    // MARK: - UITextFieldDelegate
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

}


