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
import AVKit
import MediaPlayer
import Kingfisher
class TGAttachmentMessageCell: TGBaseMessageCell, UIDocumentInteractionControllerDelegate {
    
    var bubbleImageView = UIImageView()
    var attachImageView = UIImageView()
    var imgPlay = UIImageView()
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
            
        }
        bubbleView.addSubview(attachImageView)
        bubbleView.addSubview(imgPlay)
        imgPlay.isHidden = true
        bubbleView.addSubview(textLabel)
        
        bubbleImageView.addSubview(timeLabel)
        
        bubbleImageView.addSubview(deliveryStatusView)
        

    }
    @objc func handleTapFrom(recognizer : UITapGestureRecognizer)
    {
        guard let cellLayout = layout as? TGAttachmentMessageCellLayout else {
            fatalError("invalid layout type")
        }
        if cellLayout.attachType == "Location" as String {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let objMapViewController = storyBoard.instantiateViewController(withIdentifier: "mapViewController") as! mapViewController
           objMapViewController.currentLat = cellLayout.locations[1]
            objMapViewController.currentLong = cellLayout.locations[0];
            objMapViewController.strLocationAddress = cellLayout.attributedText?.string
            objMapViewController.isFromChat = false;

            self.parentViewController?.navigationController?.pushViewController(objMapViewController, animated: false)

        }
        else {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("openPreviewData"), object: nil, userInfo: ["url":cellLayout.attachURL!])
            }
        }
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
            
            let image = isHighlight ? cellLayout.highlightBubbleImage : cellLayout.bubbleImage
            
            
            bubbleImageView.image = image?.resizableImage(withCapInsets:
                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                                                          resizingMode: .stretch)
                .withRenderingMode(.alwaysTemplate)
            bubbleImageView.tintColor = !cellLayout.isOutgoing ? UIColor.init(red: 221, green: 222, blue: 228) : UIColor.init(hexString: "6EBAAA")

            
            attachImageView.frame = cellLayout.attachImageViewFrame
            textLabel.frame = cellLayout.textLableFrame
            textLabel.textLayout = cellLayout.textLayout
            self.attachImageView.cornerRadius = 12
            self.attachImageView.contentMode = .scaleAspectFit
            let urlOriginalImage : URL!
            if(cellLayout.attachURL?.hasUrlPrefix())!
            {
                let urlString = cellLayout.attachURL!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                urlOriginalImage = URL.init(string: urlString!)
            }
            else {
                let fileName = cellLayout.attachURL?.lastPathComponent
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
//                let filePath = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!).absoluteString.removingPercentEncoding
//
//                urlOriginalImage = URL(string: filePath!)
            }
            imgPlay.isHidden = true
            if (cellLayout.attachType == "Image" || cellLayout.attachType == "Location") && urlOriginalImage != nil{
                self.attachImageView.kf.setImage(
                    with: urlOriginalImage,
                    placeholder: nil,
                    options:[
                       
                        .cacheOriginalImage,.transition(.fade(1))
                    ],
                    progressBlock: { receivedSize, totalSize in
                },
                    completionHandler: { result in
                        print(result)
                        let scalImg = self.attachImageView.image?.kf.resize(to: self.attachImageView.size, for: .aspectFill)
                        self.attachImageView.image = scalImg
                }
                )
    
            }
            else if cellLayout.attachType == "Video" {
                imgPlay.isHidden = false
                let img = UIImage(named: "play")
                imgPlay.image = img
                imgPlay.frame = CGRect(x: ((attachImageView.frame.size.width+8)-(img?.size.width)!)/2, y: ((attachImageView.frame.size.height+6)-(img?.size.height)!)/2, width: (img?.size.width)!, height: (img?.size.height)!)
                
                    do {
                        if let fileName = cellLayout.attachThumbName {
                            let  fileUrl = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName)
                            self.attachImageView.kf.setImage(
                                with: fileUrl,
                                placeholder: nil,
                                options:[
                                    
                                    .cacheOriginalImage,.transition(.fade(1))
                                ],
                                progressBlock: { receivedSize, totalSize in
                            },
                                completionHandler: { result in
                                    print(result)
                                    let scalImg = self.attachImageView.image?.kf.resize(to: self.attachImageView.size, for: .aspectFill)
                                    self.attachImageView.image = scalImg
                            }
                            )
                    
                        }
                    } catch {
                        print(error)
                    }
            }
            else if cellLayout.attachType == "Document" {
                imgPlay.isHidden = true
                self.attachImageView.image = UIImage.init(named: "docFile")
            }
            self.attachImageView.contentMode = .scaleAspectFill

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
            self.bubbleImageView.tag = cellLayout.attachTag!
            self.bubbleImageView.addGestureRecognizer(tapGestureRecognizer)
            self.bubbleImageView.isUserInteractionEnabled = true

            timeLabel.frame = cellLayout.timeLabelFrame
            timeLabel.attributedText = cellLayout.attributedTime
            
            let longTapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleMessageOperationTapFrom(recognizer:)))
            longTapGestureRecognizer.minimumPressDuration = 0.5
            longTapGestureRecognizer.delaysTouchesBegan = true
            self.bubbleImageView.tag = cellLayout.attachTag!
            self.bubbleImageView.addGestureRecognizer(longTapGestureRecognizer)
            self.bubbleImageView.isUserInteractionEnabled = true


            if cellLayout.deliveryStatusViewFrame != CGRect.zero {
                deliveryStatusView.checkmark1ImageView.isHidden = false
                deliveryStatusView.checkmark2ImageView.isHidden = false
                deliveryStatusView.frame = cellLayout.deliveryStatusViewFrame
                deliveryStatusView.deliveryStatus = cellLayout.message.deliveryStatus
                
            }
            else {
                deliveryStatusView.checkmark1ImageView.isHidden = true
                deliveryStatusView.checkmark2ImageView.isHidden = true
                deliveryStatusView.deliveryStatus = .Idle
            }
        }
    }
    
    @objc func handleMessageOperationTapFrom(recognizer : UITapGestureRecognizer)
    {
        guard let cellLayout = layout as? TGAttachmentMessageCellLayout else {
            fatalError("invalid layout type")
        }
        GlobalShareData.sharedGlobal.handleChatActionsheet(lumiMessageID:cellLayout.attachTag!)
    }
}


protocol TGAttachmentMessageCellDelegate: NOCChatItemCellDelegate {
    func didTapLink(cell: TGAttachmentMessageCell, linkInfo: [AnyHashable: Any])
}

extension String {
    
    func hasUrlPrefix()->Bool{
        guard self != nil, self.count != 0 else {
            return false
        }
        if(self.hasPrefix("http") || self.hasPrefix("https")){
            return true
        }
        return false
    }
}

