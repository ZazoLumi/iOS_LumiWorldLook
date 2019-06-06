import UIKit
import MaterialTextField
enum MyError: Error {
    case runtimeError(String)
}

open class TextFieldTableViewCell: UITableViewCell {
    open var textFieldLeftLayoutConstraint: NSLayoutConstraint!
    public let textField = PaddedTextField(frame: .zero)

    // MARK: - UITableViewCell
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        if #available(iOS 10, *) { textField.adjustsFontForContentSizeCategory = true }
        textField.font = .preferredFont(forTextStyle: .body)
        contentView.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textFieldLeftLayoutConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            textFieldLeftLayoutConstraint,
            NSLayoutConstraint(item: textField, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        ])
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") } // NSCoding
}

extension UITableView {
    public func indexPath(for textField: UITextField) throws -> IndexPath? {
            guard let indexP = self.indexPath(for: textField.superview!.superview! as! UITableViewCell) else {
                throw MyError.runtimeError("Fail")
            }
            return indexP
    }

    public func textFieldForRow(at indexPath: IndexPath) -> UITextField? {
        return (cellForRow(at: indexPath) as! TextFieldTableViewCell?)?.textField
    }
}

open class PaddedTextField: MFTextField {
    open override var intrinsicContentSize: CGSize {
        var returnValue = super.intrinsicContentSize
        returnValue.height *= 2
        return returnValue
    }
}

@IBDesignable extension UITextField{
    
    @IBInspectable var setImageName: String {
        get{
            return ""
        }
        set{
            let image = UIImage(named:newValue)
            
            if !(self.leftView != nil) && image != nil {
                let viewPadding = UIView(frame: CGRect(x: 0, y: 0, width: 40 , height: 32))
                let imageView = UIImageView (frame:CGRect(x: 0, y: 5, width: (image?.size.width)! , height: (image?.size.height)!))
                imageView.tag = 100
                imageView.image = image!
                imageView.contentMode = .scaleAspectFit
                viewPadding .addSubview(imageView)
                self.leftView = viewPadding
                self.leftViewMode = .always
            }
            else {
//                let viewPadding = self.leftView as UIView!
//                let imgView = viewPadding?.viewWithTag(100) as! UIImageView!
//                if self.frame.size.height>60 {
//                    imgView?.frame = CGRect(x: 0, y: 0, width: (image?.size.width)! , height: (image?.size.height)!)
//                }
//                else {
//                    imgView?.frame = CGRect(x: 0, y: 5, width: (image?.size.width)! , height: (image?.size.height)!)
//                }
            }
            print(self)
        }
    }
}

