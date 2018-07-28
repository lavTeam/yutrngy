//
//  VideoEditorViewController.swift
//  CustomCamera
//
//  Created by KingpiN on 12/04/17.
//  Copyright © 2017 KingpiN. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Photos
import MapKit
//import FirebaseUI

class VideoEditorViewController: UIViewController {
    deinit {
        print("deinit VideoEditorViewController")
    }
    @IBOutlet weak var colorPicker: ColorPicker!
    
    
    var lastPoint = CGPoint.zero
    var swiped = false
    var brushWidth: CGFloat = 10.0
    var color: UIColor = UIColor.red
    let tempImageView = UIImageView()
    
    @IBOutlet weak var nextStepBtn: UIButton!
    var pressDownloadVideo: Bool?
    let identificatorToProperty = "toPropertiesPost"
    var initialCenter = CGPoint()
    var outputURL: URL? = nil
    var frametextView: CGRect!
    var array = [UIView]()
    //    var videoPostProperties : Dictionary<String, Any>?
    var thumbnailStringUrl: String?
    @IBOutlet weak var createTextView: UIButton!
    @IBAction func dismissCurrentView(_ sender: UIButton) {
        closeCurrentController()
    }
    
    @IBAction func downloadVideo(_ sender: UIButton) {
        pressDownloadVideo = true
        createVideoURL()
        
    }
    @IBAction func uploadAndGoToPropetry(_ sender: UIButton) {
        showActivityIndicator(text: nil)
        guard let url = outputURL else { createVideoURL(); return }
        DispatchQueue.main.async {
            self.stopPlayer()
            FirebaseService.instance.uploadVideo(videoURL: url)
            self.hideActivityIndicator()
            self.performSegue(withIdentifier: self.identificatorToProperty, sender: nil)
        }
    }
    
    
    func closeCurrentController() {
        DispatchQueue.main.async {
            self.player?.pause()
            self.player = nil
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBOutlet weak var videoPlayingView: UIView!
    var assetsURL: URL!
    var player: AVPlayer?
    //    var playerLayer = AVPlayerLayer()
    var geopoint: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.delegate = self
        self.nextStepBtn.isEnabled = false
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem, queue: .main) { _ in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(dismissEditing))
        view.addGestureRecognizer(tapView)
        
        createTextView.addTarget(self, action: #selector(createNewTextView), for: UIControlEvents.touchUpInside)
        
    }
    @objc func drawOnScreen(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        switch sender.state {
        case .began:
            swiped = false
            lastPoint = sender.location(in: view)
            sender.setTranslation(CGPoint.zero, in: self.view)

        case .changed:
            let currentPoint = sender.location(in: view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        case .ended:
break
        default:
            break
        }
        
    }
    
    
    
    @objc func dismissEditing() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo(withUrl: assetsURL!)
    }
    
    func playVideo(withUrl: URL) {
        let playerItem = AVPlayerItem(url: withUrl)
        
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.backgroundColor = UIColor.brown.cgColor
        playerLayer.frame = videoPlayingView.bounds
        videoPlayingView.layer.addSublayer(playerLayer)
        //playerItem.videoComposition = createVideoComposition(for: playerItem)
        player?.play()
        //videoPlayingView.layoutIfNeeded()
        if videoPreviewUIImage(moviePath: withUrl) == nil {
            print("eroroorororororororororo")
            showAlertController(title: "Что-то пошло не так", message: "Снимите видео заново")
            return
        }
        FirebaseService.instance.uploadImage(image: videoPreviewUIImage(moviePath: withUrl)!, typeImage: TypeImage.VideoPreview) { (storageRef, url) in
            self.thumbnailStringUrl = url?.absoluteString
            self.nextStepBtn.isEnabled = true
        }
    }
    
    // Создаем placeholder (картинка для видео)
    func videoPreviewUIImage(moviePath: URL) -> UIImage? {
        let asset = AVURLAsset(url: moviePath)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let timestamp = CMTime(seconds: 0, preferredTimescale: 60)
        if let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) {
            if let imageData = UIImage(cgImage: imageRef).jpeg(.lowest) {
                return UIImage(data: imageData)
            } else {
                return UIImage(cgImage: imageRef)
            }
        } else {
            return nil
        }
        
    }
    
    func createVideoComposition(for playerItem: AVPlayerItem) -> AVVideoComposition {
        let composition = AVVideoComposition(asset: playerItem.asset, applyingCIFiltersWithHandler: { request in
            // Here we can use any CIFilter
            guard let filter = CIFilter(name: "CIColorPosterize") else {
                return request.finish(with: NSError())
            }
            filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
            return request.finish(with: filter.outputImage!, context: nil)
        })
        return composition
    }
    
    
    
    func videoOrientation(_ asset: AVAsset?) -> AVCaptureVideoOrientation {
        var result = AVCaptureVideoOrientation(rawValue: 0)
        let tracks = asset?.tracks(withMediaType: .video)
        if (tracks?.count ?? 0) > 0 {
            let videoTrack: AVAssetTrack? = tracks?[0]
            let t: CGAffineTransform? = videoTrack?.preferredTransform
            //            print(t)
            // Portrait
            if t?.a == 0 && t?.b == 1.0 && t?.c == -1.0 && t?.d == 0 {
                result = .portrait
            }
            // PortraitUpsideDown
            if t?.a == 0 && t?.b == -1.0 && t?.c == 1.0 && t?.d == 0 {
                result = .portraitUpsideDown
            }
            // LandscapeRight
            if t?.a == 1.0 && t?.b == 0 && t?.c == 0 && t?.d == 1.0 {
                result = .landscapeRight
            }
            // LandscapeLeft
            if t?.a == -1.0 && t?.b == 0 && t?.c == 0 && t?.d == -1.0 {
                result = .landscapeLeft
            }
        }
        return result!
    }
    
    func createVideoURL() {
        
        let currentAsset = AVAsset(url: assetsURL!)
        let composition = AVMutableComposition.init()
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderScale  = 1.0
        
        let compositionAudioTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionVideoTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let clipVideoTrack:AVAssetTrack = currentAsset.tracks(withMediaType: AVMediaType.video)[0]
        let audioTrack: AVAssetTrack? = currentAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        try? compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, currentAsset.duration), of: audioTrack!, at: kCMTimeZero)
        try? compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, currentAsset.duration), of: clipVideoTrack, at: kCMTimeZero)
        
        let orientation = videoOrientation(currentAsset)
        var isPortrait = false
        
        switch orientation {
        case .landscapeRight:
            isPortrait = false
        case .landscapeLeft:
            isPortrait = false
        case .portrait:
            isPortrait = true
        case .portraitUpsideDown:
            isPortrait = true
        }
        var naturalSize = clipVideoTrack.naturalSize
        
        if isPortrait {
            naturalSize = CGSize.init(width: naturalSize.height, height: naturalSize.width)
        }
        
        videoComposition.renderSize = naturalSize
        
        let scale = CGFloat(1.0)
        
        var transform = CGAffineTransform.init(scaleX: CGFloat(scale), y: CGFloat(scale))
        switch orientation {
        case .landscapeRight:
            break
        // isPortrait = false
        case .landscapeLeft:
            transform = transform.translatedBy(x: naturalSize.width, y: naturalSize.height)
            transform = transform.rotated(by: .pi)
        case .portrait:
            transform = transform.translatedBy(x: naturalSize.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .portraitUpsideDown:
            break
        }
        
        let frontLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
        frontLayerInstruction.setTransform(transform, at: kCMTimeZero)
        let MainInstruction = AVMutableVideoCompositionInstruction()
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        MainInstruction.layerInstructions = [frontLayerInstruction]
        videoComposition.instructions = [MainInstruction]
        
        
        applyVideoEffects(to: videoComposition, size: naturalSize)
        
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let videoPath = documentsPath+"/cropEditVideo.mov"
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: videoPath) {
            try! fileManager.removeItem(atPath: videoPath)
        }
        var exportSession = AVAssetExportSession.init(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.videoComposition = videoComposition
        exportSession?.outputFileType = AVFileType.mov
        exportSession?.outputURL = URL.init(fileURLWithPath: videoPath)
        
        exportSession?.exportAsynchronously(completionHandler: {
            guard let url = self.exportDidFinish(session: exportSession!) else {return}
            self.outputURL = url
            if let isDownloading = self.pressDownloadVideo, isDownloading == true {
                guard let url = self.outputURL else { return }
                DispatchQueue.main.async {
                    self.saveVideoToLibrary(from: url.relativePath)
                }
            } else {
                DispatchQueue.main.async {
                    self.stopPlayer()
                    FirebaseService.instance.uploadVideo(videoURL: self.outputURL!)
                    
                    self.performSegue(withIdentifier: self.identificatorToProperty, sender: nil)
                }
            }
            exportSession = nil
        })
    }
    
    func applyVideoEffects(to composition: AVMutableVideoComposition, size: CGSize) {
        guard !self.array.isEmpty else {return}
        let image  = self.textViewImage(textView: (self.array[0] as? UITextView)!, scale: ((self.array[0] as? UITextView)?.transform.d)!)
        
        let parentLayer = CALayer.init()
        parentLayer.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        
        let videoLayer = CALayer.init()
        videoLayer.frame = parentLayer.frame
        
        guard array.count != 0 else { return }
        
        let uiTextViewFrame = (videoPlayingView.convert((array[0] as! UITextView).frame, to: videoPlayingView))
        let indexX: CGFloat = size.width / videoPlayingView.frame.width
        let indexY: CGFloat = size.height / (videoPlayingView.frame.height) * 0.98
        
        
        let layer = CATextLayer()
        layer.frame = CGRect(x: (array[0] as! UITextView).frame.origin.x * (indexX),
                             y: ((self.view.frame.height - (array[0] as! UITextView).frame.origin.y - (array[0] as! UITextView).frame.height) * (indexY)),
                             width: (array[0] as! UITextView).frame.width * indexX*1.2,
                             height: (array[0] as! UITextView).frame.height * indexY)
        print("слой с текстом:   ",layer.frame)
        print("ibhbyf textview ", (array[0] as! UITextView).frame.width)
        layer.transform = (array[0] as! UITextView).layer.transform
        layer.foregroundColor = (array[0] as! UITextView).textColor?.cgColor // as! CGColor // UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        // Create an attribute from the shadow
        let myAttribute1 = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.strokeWidth : -2.0,
            NSAttributedStringKey.foregroundColor : (array[0] as! UITextView).textColor!,
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: ((array[0] as! UITextView).font?.pointSize)! * indexY)
            ] as [NSAttributedStringKey : Any]
        
        // Add the attribute to the string
        let myAttrString = NSAttributedString(string: (array[0] as! UITextView).text, attributes: myAttribute1)
        layer.string = myAttrString
        
        
        let overlayLayer = CALayer()
        let overlayImage: UIImage? = image
        //ttttteeee.image = image
        overlayLayer.frame = CGRect(x: fix(uiTextViewFrame, in: videoPlayingView.frame).origin.x * indexX,
                                    y: fix(uiTextViewFrame, in: videoPlayingView.frame).origin.y * indexY,
                                    width: (array[0] as! UITextView).frame.width * indexX,
                                    height: (array[0] as! UITextView).frame.height * indexY)
        overlayLayer.contents = overlayImage?.cgImage
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(layer)
        
        // 3 - apply magic
        composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        
    }
    
    
    func exportDidFinish(session: AVAssetExportSession) -> (URL?) {
        switch session.status {
        case .completed:
            return session.outputURL
        case .failed:
            print("Failed \(session.error!)")
            return nil
            
        case .unknown:
            return nil
        case .waiting:
            print("!!!!!!!!!!!!   exportDidFinish: .waiting")
            return nil
            
        case .exporting:
            print("!!!!!!!!!!!!   exportDidFinish: .exporting")
            return nil
            
        case .cancelled:
            print("!!!!!!!!!!!!   exportDidFinish: .cancelled")
            return nil
            
        }
        
    }
    func stopPlayer() {
        if let play = player {
            print("stopped")
            play.pause()
            player = nil
            print("player deallocated")
        } else {
            print("player was already deallocated")
        }
    }
    
    
    private func saveVideoToLibrary(from path: String) {
        // проверка, есть ли разрешение на фото
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: path))
        }) { saved, error in
            if let error = error {
                print("saveVideoToLibrary: ", error)
            }
            if saved == true {
                print("save in library")
            }
        }
    }
    
    
    // MARK:  UINavigation (segue)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == identificatorToProperty {
            let secondVC = segue.destination as! PropertiesVideoPostViewController
            secondVC.geopoint = self.geopoint!
            //            print("ГеоПоинт Виде эдитор", self.geopoint)
            secondVC.thumbnailStringUrl = thumbnailStringUrl
            self.hideActivityIndicator()
            
            //            self.closeCurrentController()
            
        }
    }
}
// MARK: - UITextViewDelegate

extension VideoEditorViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = UIScreen.main.bounds.width * 0.8
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        //        print(textView.frame)
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame.size = newFrame.size
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        
        return newText.count <= 50
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.sizeToFit()
    }
    
    
    func textViewImage(textView: UITextView, scale: CGFloat) -> UIImage {
        var image: UIImage? = nil
        textView.contentSize = CGSize(width: 1000, height: 1000)
        textView.adjustsFontForContentSizeCategory = true
        
        UIGraphicsBeginImageContextWithOptions(textView.frame.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { exit(0) }
        textView.layer.render(in: context)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        return image!
    }
    
    
}

// MARK: - Create New Elements
extension VideoEditorViewController {
    @objc func createNewTextView() {
        
        let new = UITextViewFixed()
        
        new.frame.origin = CGPoint(x: 0, y: 100)
        new.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 100)
        new.isScrollEnabled = false
        new.isUserInteractionEnabled = true
        new.becomeFirstResponder()
        new.delegate = self
        new.backgroundColor = UIColor.clear
        new.textAlignment = .left
        // Create an attribute from the shadow
        let myAttribute = [
            NSAttributedStringKey.strokeColor : UIColor.black,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : -2.0,
            ] as [NSAttributedStringKey : Any]
        // Add the attribute to the string
        let myAttrString = NSAttributedString(string: "SwiftBook\nSwiftBook", attributes: myAttribute)
        new.attributedText = myAttrString
        new.font = UIFont.systemFont(ofSize: 30)
        new.textColor = UIColor.red
        let movingTextView = UIPanGestureRecognizer(target: self, action: #selector(movingObject3(sender:)))
        movingTextView.delegate = self
        new.addGestureRecognizer(movingTextView)
        let scaleTextView = UIPinchGestureRecognizer(target: self, action: #selector(scaleObject(sender:)))
        scaleTextView.delegate = self
        new.addGestureRecognizer(scaleTextView)
        self.videoPlayingView.addSubview(new)
//        self.view.addSubview(new)
        array.append(new)
    }
}


// MARK: gesture
extension VideoEditorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    @objc func movingObject3(sender: UIPanGestureRecognizer) {
        
        guard let textView = sender.view else { return }
        if sender.state == .began {
            initialCenter = textView.center
        }
        if sender.state != .cancelled {
            let translation = sender.translation(in: view)
            textView.center = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
        }
        
    }
    @objc func scaleObject(sender: UIPinchGestureRecognizer) {
        //        print()
        guard let textView = sender.view else { return }
        if textView.frame.width >= UIScreen.main.bounds.width - 20 && sender.scale >= 1 {
            return
        } else {
            textView.frame.size = CGSize(width: textView.frame.width * sender.scale, height: textView.frame.height * sender.scale) //transform.scaledBy(x: sender.scale, y: sender.scale)
            updateTextFont(textView: textView as! UITextView)
            sender.scale = 1.0
        }
        
    }
    
    @objc func rotationObject(sender: UIRotationGestureRecognizer) {
        guard let textView = sender.view else { return }
        textView.transform = textView.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    
    func fix(_ rect: CGRect, in container: CGRect) -> CGRect {
        var frame: CGRect = rect
        frame.origin.y = container.size.height - frame.origin.y - frame.size.height
        return frame
    }
    
    func updateTextFont(textView : UITextView) {
        if (textView.text.isEmpty || textView.bounds.size.equalTo(CGSize.zero)) {
            return;
        }
        let textViewSize = textView.frame.size;
        let fixedWidth = textViewSize.width;
        
        let expectSize = textView.sizeThatFits(CGSize(width : fixedWidth, height : CGFloat(MAXFLOAT)));
        
        var expectFont = textView.font;
        if (expectSize.height > textViewSize.height) {
            while (textView.sizeThatFits(CGSize(width : fixedWidth, height : CGFloat(MAXFLOAT))).height > textViewSize.height) {
                expectFont = textView.font!.withSize(textView.font!.pointSize - 1)
                textView.font = expectFont
            }
        }
        else {
            while (textView.sizeThatFits(CGSize(width : fixedWidth,height : CGFloat(MAXFLOAT))).height < textViewSize.height) {
                expectFont = textView.font;
                textView.font = textView.font!.withSize(textView.font!.pointSize + 1)
            }
            textView.font = expectFont;
        }
    }
}

extension VideoEditorViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        self.view.bringSubview(toFront: colorPicker)
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
            let currentPoint = touch.location(in: view)
            drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)

            lastPoint = currentPoint
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        tempImageView.frame = UIScreen.main.bounds
        videoPlayingView.addSubview(tempImageView)
        
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))


        context?.move(to: fromPoint)
        context?.addLine(to: toPoint)

        // Draw a transparent green Circle
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(brushWidth)
        context?.setShadow(offset: CGSize(width: 0, height: 0), blur: brushWidth + 1, color: UIColor.white.cgColor)
        context?.setFillColor(color.cgColor)

        context?.setStrokeColor(color.cgColor)
        context?.setBlendMode(CGBlendMode.normal)
        context?.strokePath()
        context?.drawPath(using: .fillStroke)

        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = color.cgColor.alpha
        UIGraphicsEndImageContext()
    }
    
    
}

extension VideoEditorViewController: colorDelegate {
    func pickedColor(newColor: UIColor) {
        self.color = newColor
    }
}


@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}

