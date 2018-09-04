import UIKit

open class TextFieldTableViewController: UITableViewController, UITextFieldDelegate {
    open let placeholders: [[String]]
    open var texts: [[String]]
    open var images: [[String]]

    public init(placeholders: [[String]], texts: [[String]], images: [[String]]) {
        self.placeholders = placeholders
        self.texts = texts
        self.images = images
        super.init(style: .grouped)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))

    }
    
    required public convenience init?(coder aDecoder: NSCoder) {
        print(Decoder.self)
        self.init(coder: aDecoder)
    }
    
    //    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }


    // MARK: - UIViewController

    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .none
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: String(describing: TextFieldTableViewCell.self))
    }

    // MARK: - UITableViewDataSource

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return texts.count
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts[section].count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                return false
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


