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
            bubbleImageView.image = isHighlight ? cellLayout.highlightBubbleImage : cellLayout.bubbleImage
            
            attachImageView.frame = cellLayout.attachImageViewFrame
            textLabel.frame = cellLayout.textLableFrame
            textLabel.textLayout = cellLayout.textLayout
            self.attachImageView.cornerRadius = 5
            self.attachImageView.contentMode = .scaleAspectFit
            let urlOriginalImage : URL!
            if(cellLayout.attachURL?.hasUrlPrefix())!
            {
                urlOriginalImage = URL.init(string: cellLayout.attachURL!)
            }
            else {
                let fileName = cellLayout.attachURL?.lastPathComponent
                urlOriginalImage = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName!)
            }
            imgPlay.isHidden = true

            if cellLayout.attachType == "Image" || cellLayout.attachType == "Location" {
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
            }
            else if cellLayout.attachType == "Video" {
                imgPlay.isHidden = false
                let img = UIImage(named: "play")
                imgPlay.image = img
                imgPlay.frame = CGRect(x: ((attachImageView.frame.size.width+8)-(img?.size.width)!)/2, y: ((attachImageView.frame.size.height+6)-(img?.size.height)!)/2, width: (img?.size.width)!, height: (img?.size.height)!)
                
                DispatchQueue.main.async {
                    do {
                        let asset = AVAsset(url: urlOriginalImage!)
                        let imageGenerator = AVAssetImageGenerator(asset: asset)
                        let time = CMTimeMake(1, 20)
                        let imageRef = try! imageGenerator.copyCGImage(at: time, actualTime: nil)
                        let thumbnail1 = UIImage(cgImage:imageRef)
                        let scalImg = thumbnail1.af_imageScaled(to: CGSize(width:ceil(self.width * 0.75)-20 , height: 110))
                        self.attachImageView.image = scalImg
                    } catch {
                        print(error)
                    }
                }
            }
            else if cellLayout.attachType == "Document" {
                imgPlay.isHidden = true
            }

            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapFrom(recognizer:)))
            self.bubbleImageView.tag = cellLayout.attachTag!
            self.bubbleImageView.addGestureRecognizer(tapGestureRecognizer)
            self.bubbleImageView.isUserInteractionEnabled = true

            timeLabel.frame = cellLayout.timeLabelFrame
            timeLabel.attributedText = cellLayout.attributedTime
            deliveryStatusView.frame = cellLayout.deliveryStatusViewFrame
            deliveryStatusView.deliveryStatus = cellLayout.message.deliveryStatus
        }
    }
    
    func loadThumbNail(_ urlVideo: URL?) -> UIImage? {
        var asset: AVURLAsset? = nil
        if let aVideo = urlVideo {
            asset = AVURLAsset(url: aVideo, options: nil)
        }
        var generate: AVAssetImageGenerator? = nil
        if let anAsset = asset {
            generate = AVAssetImageGenerator(asset: anAsset)
        }
        generate?.appliesPreferredTrackTransform = true
        let err: Error? = nil
        let time: CMTime = CMTimeMake(1, 60)
        let imgRef = try? generate?.copyCGImage(at: time, actualTime: nil)
        if let anErr = err, let aRef = imgRef {
           // print("err==\(anErr), imageRef==\(aRef)")
        }
        if let aRef = imgRef {
            return UIImage(cgImage: aRef!)
        }
        return nil
    }

    
}


protocol TGAttachmentMessageCellDelegate: NOCChatItemCellDelegate {
    func didTapLink(cell: TGAttachmentMessageCell, linkInfo: [AnyHashable: Any])
}

extension String{
    
    func hasUrlPrefix()->Bool{
        
        if(self.hasPrefix("http") || self.hasPrefix("https")){
            return true
        }
        return false
    }
}

