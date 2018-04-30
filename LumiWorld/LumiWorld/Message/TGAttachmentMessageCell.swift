//
//  TGAttachmentMessageCell.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import NoChat
import YYText
import Alamofire

class TGAttachmentMessageCell: TGBaseMessageCell {
    
    var bubbleImageView = UIImageView()
    var attachImageView = UIImageView()
    var textLabel = YYLabel()
    var timeLabel = UILabel()
    var deliveryStatusView = TGDeliveryStatusView()
    
    override class func reuseIdentifier() -> String {
        return "TGAttachmentMessageCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bubbleView.addSubview(bubbleImageView)
        
        textLabel.textVerticalAlignment = .top
        textLabel.displaysAsynchronously = true
        textLabel.ignoreCommonProperties = true
        textLabel.fadeOnAsynchronouslyDisplay = false
        textLabel.fadeOnHighlight = false
        textLabel.highlightTapAction = { [weak self] (containerView, text, range, rect) -> Void in
            if range.location >= text.length { return }
            let highlight = text.yy_attribute(YYTextHighlightAttributeName, at: UInt(range.location)) as! YYTextHighlight
            guard let info = highlight.userInfo, info.count > 0 else { return }
            
            guard let strongSelf = self else { return }
            if let d = strongSelf.delegate as? TGAttachmentMessageCellDelegate {
                d.didTapLink(cell: strongSelf, linkInfo: info)
            }
        }
        bubbleView.addSubview(attachImageView)

        bubbleView.addSubview(textLabel)
        
        bubbleImageView.addSubview(timeLabel)
        
        bubbleImageView.addSubview(deliveryStatusView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var layout: NOCChatItemCellLayout? {
        didSet {
            guard let cellLayout = layout as? TGAttachmentMessageCellLayout else {
                fatalError("invalid layout type")
            }
            
            bubbleImageView.frame = cellLayout.bubbleImageViewFrame
            bubbleImageView.image = isHighlight ? cellLayout.highlightBubbleImage : cellLayout.bubbleImage
            
            attachImageView.frame = cellLayout.attachImageViewFrame
            textLabel.frame = cellLayout.textLableFrame
            textLabel.textLayout = cellLayout.textLayout
            self.attachImageView.cornerRadius = 5
            self.attachImageView.contentMode = .scaleAspectFit
            let urlOriginalImage = URL.init(string: cellLayout.attachURL!)
            Alamofire.request(urlOriginalImage!).responseImage { response in
                debugPrint(response)
                if let image = response.result.value {
                    if cellLayout.attachImageViewFrame.size.width > 0, cellLayout.attachImageViewFrame.size.height > 0 {
                     let scalImg = image.af_imageScaled(to: CGSize(width:cellLayout.attachImageViewFrame.size.width , height: cellLayout.attachImageViewFrame.size.height))
                        self.attachImageView.image = scalImg
                    }
                    else {
                        let scalImg = image.af_imageScaled(to: CGSize(width:ceil(self.width * 0.75)-20 , height: 110))
                        self.attachImageView.image = scalImg }
                }
            }

            timeLabel.frame = cellLayout.timeLabelFrame
            timeLabel.attributedText = cellLayout.attributedTime
            
            deliveryStatusView.frame = cellLayout.deliveryStatusViewFrame
            deliveryStatusView.deliveryStatus = cellLayout.message.deliveryStatus
        }
    }
    
}

protocol TGAttachmentMessageCellDelegate: NOCChatItemCellDelegate {
    func didTapLink(cell: TGAttachmentMessageCell, linkInfo: [AnyHashable: Any])
}
