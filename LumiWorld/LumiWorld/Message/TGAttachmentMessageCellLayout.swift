//
//  TGTextMessageCellLayout.swift
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

class TGAttachmentMessageCellLayout: TGBaseMessageCellLayout {
    
    var attributedTime: NSAttributedString?
    var hasTail = false
    var bubbleImage: UIImage?
    var highlightBubbleImage: UIImage?
    var attachURL: String?
    var attachType: String?
    var attachTag: Int?
    var locations : [Double] = []

    var bubbleImageViewFrame = CGRect.zero
    var attachImageViewFrame = CGRect.zero
    var textLableFrame = CGRect.zero
    var textLayout: YYTextLayout?
    var timeLabelFrame = CGRect.zero
    var deliveryStatusViewFrame = CGRect.zero
    
    private var attributedText: NSMutableAttributedString?
    
    required init(chatItem: NOCChatItem, cellWidth width: CGFloat) {
        super.init(chatItem: chatItem, cellWidth: width)
        reuseIdentifier = "TGAttachmentMessageCell"
        setupAttachmentData()
        setupAttributedText()
        setupAttributedTime()
        setupHasTail()
        setupBubbleImage()
        calculate()
    }
    
    private func setupAttributedText() {
        let text = message.text
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedStringKey.font: Style.textFont, NSAttributedStringKey.foregroundColor: Style.textColor])
        
        if text == "/start" {
            attributedText.yy_setColor(Style.linkColor, range: attributedText.yy_rangeOfAll())
            
            let highlightBorder = YYTextBorder()
            highlightBorder.insets = UIEdgeInsets(top: -2, left: 0, bottom: -2, right: 0)
            highlightBorder.cornerRadius = 2
            highlightBorder.fillColor = Style.linkBackgroundColor
            
            let highlight = YYTextHighlight()
            highlight.setBackgroundBorder(highlightBorder)
            highlight.userInfo = ["command": text]
            
            attributedText.yy_setTextHighlight(highlight, range: attributedText.yy_rangeOfAll())
        }
        
        self.attributedText = attributedText
    }
    
    private func setupAttributedTime() {
        let timeString = Style.timeFormatter.string(from: message.date)
        let timeColor = isOutgoing ? Style.outgoingTimeColor : Style.incomingTimeColor
        attributedTime = NSAttributedString(string: timeString, attributes: [NSAttributedStringKey.font: Style.timeFont, NSAttributedStringKey.foregroundColor: timeColor])
    }
    
    private func setupAttachmentData() {
        if let strUrl = message.attachmentURL {
            attachURL = strUrl
            let fileName = strUrl.lastPathComponent
            let url = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName)
            GlobalShareData.sharedGlobal.aryAttachUrls.append(url)
        }
        attachType = message.msgType
        attachTag = message.messageId
        if attachType == "Location" {
            locations.append(message.latitude)
            locations.append(message.longitude)
        }
    }

    
    private func setupHasTail() {
        hasTail = true
    }
    
    private func setupBubbleImage() {
        bubbleImage = isOutgoing ? (hasTail ? Style.fullOutgoingBubbleImage : Style.partialOutgoingBubbleImage) : (hasTail ? Style.fullIncomingBubbleImage : Style.partialIncomingBubbleImage)
        
        highlightBubbleImage = isOutgoing ? (hasTail ? Style.highlightFullOutgoingBubbleImage : Style.highlightPartialOutgoingBubbleImage) : (hasTail ? Style.highlightFullIncomingBubbleImage : Style.highlightPartialIncomingBubbleImage)
    }
    
    override func calculate() {
        height = 0
        bubbleViewFrame = CGRect.zero
        bubbleImageViewFrame = CGRect.zero
        textLableFrame = CGRect.zero
        textLayout = nil
        timeLabelFrame = CGRect.zero
        deliveryStatusViewFrame = CGRect.zero
        
        guard let time = attributedTime else {
            return
        }

        let preferredMaxBubbleWidth = ceil(width * 0.75)
        var bubbleViewWidth = preferredMaxBubbleWidth
        
        // prelayout
        let unlimitSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let timeLabelSize = time.noc_sizeThatFits(size: unlimitSize)
        let timeLabelWidth = timeLabelSize.width
        let timeLabelHeight = CGFloat(15)
        let attachmentMargin = isOutgoing ? UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 12) : UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        
        let attachmentWidth = bubbleViewWidth - attachmentMargin.left - attachmentMargin.right
        let deliveryStatusWidth: CGFloat = (isOutgoing && message.deliveryStatus != .Failure) ? 15 : 0
        let deliveryStatusHeight = deliveryStatusWidth
        
        let hPadding = CGFloat(8)
        let vPadding = CGFloat(4)
        var bubbleViewHeight = CGFloat(0)


        if let text = attributedText, text.length > 0  {
            // dynamic font support
            let dynamicFont = Style.textFont
            text.yy_setAttribute(NSAttributedStringKey.font.rawValue, value: dynamicFont)
            
            let textMargin = isOutgoing ? UIEdgeInsets(top: 2, left: 10, bottom: 8, right: 15) : UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 10)
            var textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right - hPadding - timeLabelWidth - hPadding/2 - deliveryStatusWidth
            
            let modifier = TGTextLinePositionModifier()
            modifier.font = dynamicFont
            modifier.paddingTop = 2
            modifier.paddingBottom = 2
            
            let container = YYTextContainer()
            container.size = CGSize(width: textLabelWidth, height: CGFloat.greatestFiniteMagnitude)
            container.linePositionModifier = modifier
            
            guard let textLayout = YYTextLayout(container: container, text: text) else {
                return
            }
            self.textLayout = textLayout
            if textLayout.rowCount > 1 { // relayout
                textLabelWidth = bubbleViewWidth - textMargin.left - textMargin.right
                container.size = CGSize(width: textLabelWidth, height: CGFloat.greatestFiniteMagnitude)
                
                guard let newTextLayout = YYTextLayout(container: container, text: text) else {
                    return
                }
                self.textLayout = newTextLayout
                
                // layout content in bubble
                
                
                textLabelWidth = ceil(newTextLayout.textBoundingSize.width)
                let textLabelHeight = ceil(modifier.height(forLineCount: newTextLayout.rowCount))
                
                bubbleViewWidth = attachmentMargin.left + attachmentWidth + attachmentMargin.right
                bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom+attachmentMargin.top + 110 + attachmentMargin.bottom
                attachImageViewFrame = CGRect(x: attachmentMargin.left, y: attachmentMargin.top, width: attachmentWidth, height: 110)
                
                textLableFrame = CGRect(x: textMargin.left, y: attachmentMargin.top + 110 + attachmentMargin.bottom+textMargin.top, width: textLabelWidth, height: textLabelHeight)
                
                let tryPoint = CGPoint(x: textLabelWidth - deliveryStatusWidth - hPadding/2 - timeLabelWidth - hPadding, y: textLabelHeight - timeLabelHeight/2)
                
                let needNewLine = newTextLayout.textRange(at: tryPoint) != nil
                if needNewLine {
                    var x = bubbleViewWidth - textMargin.left - deliveryStatusWidth - hPadding/2 - timeLabelWidth
                    var y = textMargin.top + textLabelHeight + attachmentMargin.top + 110 + attachmentMargin.bottom
                    
                    y += vPadding
                    timeLabelFrame = CGRect(x: x, y: y, width: timeLabelWidth, height: timeLabelHeight)
                    
                    x += timeLabelWidth + hPadding/2
                    deliveryStatusViewFrame = CGRect(x: x, y: y, width: deliveryStatusWidth, height: deliveryStatusHeight)
                    
                    bubbleViewHeight = textMargin.top + textLabelHeight + vPadding + timeLabelHeight + textMargin.bottom + attachmentMargin.top + 110 + attachmentMargin.bottom
                    bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
                    
                    bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
                    
                } else {
                    bubbleViewHeight = textMargin.top + textLabelHeight + timeLabelHeight + textMargin.bottom + attachmentMargin.top + 110 + attachmentMargin.bottom
                    
                    bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
                    
                    bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
                    
                    var x = bubbleViewWidth - textMargin.right - deliveryStatusWidth - hPadding/2 - timeLabelWidth
                    let y = bubbleViewHeight - textMargin.bottom - timeLabelHeight
                    timeLabelFrame = CGRect(x: x, y: y, width: timeLabelWidth, height: timeLabelHeight)
                    
                    x += timeLabelWidth + hPadding/2
                    deliveryStatusViewFrame = CGRect(x: x, y: y, width: deliveryStatusWidth, height: deliveryStatusHeight)
                    
                }
                
            } else {
                textLabelWidth = ceil(textLayout.textBoundingSize.width)
                let textLabelHeight = ceil(modifier.height(forLineCount: textLayout.rowCount))
                
                bubbleViewWidth = attachmentMargin.left + attachmentWidth + attachmentMargin.right
                bubbleViewHeight = textLabelHeight + textMargin.top + textMargin.bottom+attachmentMargin.top + 110 + attachmentMargin.bottom
                bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
                
                attachImageViewFrame = CGRect(x: attachmentMargin.left, y: attachmentMargin.top, width: attachmentWidth, height: 110)
                
                bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
                
                var x = bubbleViewWidth - textLabelWidth - attachmentMargin.right - deliveryStatusWidth - hPadding/2 - timeLabelWidth - 10

                var y = textMargin.top + attachImageViewFrame.size.height+attachmentMargin.top+attachmentMargin.bottom
                textLableFrame = CGRect(x: x, y: y, width: textLabelWidth, height: textLabelHeight)
                
                x += textLabelWidth + hPadding
                y = bubbleViewHeight - textMargin.bottom - timeLabelHeight
                timeLabelFrame = CGRect(x: x, y: y, width: timeLabelWidth, height: timeLabelHeight)
                
                x += timeLabelWidth + hPadding/2
                deliveryStatusViewFrame = CGRect(x: x, y: y, width: deliveryStatusWidth, height: deliveryStatusHeight)
            }
            
            height = bubbleViewHeight + bubbleViewMargin.top + bubbleViewMargin.bottom
        }
        else {
            bubbleViewWidth = attachmentMargin.left + attachmentWidth + attachmentMargin.right
            bubbleViewHeight = attachmentMargin.top + 110 + attachmentMargin.bottom + 20
            bubbleViewFrame = isOutgoing ? CGRect(x: width - bubbleViewMargin.right - bubbleViewWidth, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight) : CGRect(x: bubbleViewMargin.left, y: bubbleViewMargin.top, width: bubbleViewWidth, height: bubbleViewHeight)
            
            attachImageViewFrame = CGRect(x: attachmentMargin.left, y: attachmentMargin.top, width: attachmentWidth, height: 110)
            
            bubbleImageViewFrame = CGRect(x: 0, y: 0, width: bubbleViewWidth, height: bubbleViewHeight)
            
            var x = bubbleViewWidth - attachmentMargin.right - deliveryStatusWidth - hPadding/2 - timeLabelWidth
            
            let y =  bubbleViewHeight - attachmentMargin.bottom - 15
            
            timeLabelFrame = CGRect(x: x, y: y, width: timeLabelWidth, height: timeLabelHeight)
            
            x += timeLabelWidth + hPadding/2
            deliveryStatusViewFrame = CGRect(x: x, y: y, width: deliveryStatusWidth, height: deliveryStatusHeight)

            height = bubbleViewHeight + bubbleViewMargin.top + bubbleViewMargin.bottom

        }
        
    }
    
    
    struct Style {
        static let fullOutgoingBubbleImage = UIImage(named: "TGBubbleOutgoingFull")?.resizableImage(withCapInsets: UIEdgeInsetsMake(12, 20, 22, 12))
        static let highlightFullOutgoingBubbleImage = UIImage(named: "TGBubbleOutgoingFullHL")!
        static let partialOutgoingBubbleImage = UIImage(named: "TGBubbleOutgoingPartial")!
        static let highlightPartialOutgoingBubbleImage = UIImage(named: "TGBubbleOutgoingPartialHL")!
        static let fullIncomingBubbleImage = UIImage(named: "TGBubbleIncomingFull")!
        static let highlightFullIncomingBubbleImage = UIImage(named: "TGBubbleIncomingFullHL")!
        static let partialIncomingBubbleImage = UIImage(named: "TGBubbleIncomingPartial")!
        static let highlightPartialIncomingBubbleImage = UIImage(named: "TGBubbleIncomingPartialHL")!

        static var textFont: UIFont {
            return UIFont.preferredFont(forTextStyle: .body)
        }
        static let textColor = UIColor.black
        
        static let linkColor = UIColor(red: Int(0/255.0), green: Int(75/255.0), blue: Int(173/255.0))
        static let linkBackgroundColor = UIColor(red: Int(191/255.0), green: Int(223/255.0), blue: Int(254/255.0))
        
        static let timeFont = UIFont.systemFont(ofSize: 12)
        static let outgoingTimeColor = UIColor(red: Int(59/255.0), green: Int(171/255.0), blue: Int(61/255.0))
        static let incomingTimeColor = UIColor.gray
        static let timeFormatter: DateFormatter = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US")
            df.dateFormat = "h:mm a"
            return df
        }()
    }
    
}

fileprivate
class TGTextLinePositionModifier: NSObject, YYTextLinePositionModifier {
    
    var font = UIFont.systemFont(ofSize: 16)
    var paddingTop = CGFloat(0)
    var paddingBottom = CGFloat(0)
    var lineHeightMultiple = CGFloat(0)
    
    override init() {
        super.init()
        
        if #available(iOS 9.0, *) {
            lineHeightMultiple = 1.34 // for PingFang SC
        } else {
            lineHeightMultiple = 1.3125 // for Heiti SC
        }
    }
    
    fileprivate func modifyLines(_ lines: [YYTextLine], fromText text: NSAttributedString, in container: YYTextContainer) {
        let ascent = font.pointSize * 0.86
        
        let lineHeight = font.pointSize * lineHeightMultiple
        for line in lines {
            var position = line.position
            position.y = paddingTop + ascent + CGFloat(line.row) * lineHeight
            line.position = position
        }
    }
    
    fileprivate func copy(with zone: NSZone? = nil) -> Any {
        let one = TGTextLinePositionModifier()
        one.font = font
        one.paddingTop = paddingTop
        one.paddingBottom = paddingBottom
        one.lineHeightMultiple = lineHeightMultiple
        return one
    }

    fileprivate func height(forLineCount lineCount: UInt) -> CGFloat {
        if lineCount == 0 {
            return 0
        }
        let ascent = font.pointSize * 0.86
        let descent = font.pointSize * 0.14
        let lineHeight = font.pointSize * lineHeightMultiple
        return paddingTop + paddingBottom + ascent + descent + CGFloat(lineCount - 1) * lineHeight
    }
}
