//
//  CustomTableView.swift
//  testSVG
//
//  Created by Ashish Patel on 2018/03/14.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit

class NewCustomTableView: UIView, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate {
    open let placeholders: [[String]]
    open var texts: [[String]]
    open var images: [[String]]
    var tableView: UITableView!

    public init(placeholders: [[String]], texts: [[String]], images: [[String]], frame:CGRect) {
        self.placeholders = placeholders
        self.texts = texts
        self.images = images
        tableView = UITableView(frame: frame)
        

        // passing a function to the delegate object
       // tableViewDelegate?.didSelectRow = didSelectRow
        
        // setting the delegate object to tableView
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: String(describing: TextFieldTableViewCell.self))

        super.init(frame: frame)
        tableView.delegate = self
        tableView.dataSource = self
        self.addSubview(tableView)

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
    
    open func configureTextField(_ textField: UITextField, forRowAt indexPath: IndexPath) {
        textField.setImageName = images[indexPath.section][indexPath.row]
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.returnKeyType = !isLastIndexPath(indexPath) ? .next : .done
        textField.placeholder = placeholders[indexPath.section][indexPath.row]
        textField.text = texts[indexPath.section][indexPath.row]
    }
    
    // MARK: - UITextFieldDelegate
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        do{
            let indexPath = try tableView.indexPath(for: textField)!
            texts[indexPath.section][indexPath.row] = textField.text!
        }catch MyError.runtimeError(let errorMessage){
            print(errorMessage)
        }catch{
            print("some error")
        }
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        do{
            let indexPath = try tableView.indexPath(for: textField)!
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
        }catch MyError.runtimeError(let errorMessage){
            print(errorMessage)
        }catch{
            print("some error")
        }
        return false
    }
    
    // MARK: - Actions
    
    @objc open func doneAction() {
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


