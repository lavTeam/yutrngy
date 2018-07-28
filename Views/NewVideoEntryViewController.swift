//
//  NewVideoEntryViewController.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 25.06.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class NewVideoEntryViewController: UIViewController {
    deinit {
        print("deinit NewVideoEntryViewController")
    }
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var flashButtonOutlet: UIButton!
    @IBOutlet weak var flipButtonOutlet: UIButton!
    @IBOutlet weak var recordButtonOutlet: UIButton!
    
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var audioInput: AVCaptureDevice?
    var videoOutput: AVCaptureMovieFileOutput?
    
    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    var videoStartImage: UIImage?
    var videoStopImage: UIImage?
    var isRecording = false
    weak var geopoint: CLLocation?
    
    var transform = CGAffineTransform(a: -0.598460069057858, b: -0.801152635733831, c: 0.801152635733831, d: -0.598460069057858, tx: 0.0, ty: 0.0)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSession()
//        print(geopoint)
    }
    
    func createSession() {
        session = AVCaptureSession()
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        do {
            if let session = session {
                videoInput = try AVCaptureDeviceInput(device: device!)
                
                session.addInput(videoInput!)
                audioInput = AVCaptureDevice.default(for: AVMediaType.audio)
                try session.addInput(AVCaptureDeviceInput(device: audioInput!))
                // Allow use of microphone
                session.usesApplicationAudioSession = true
                videoOutput = AVCaptureMovieFileOutput()
                if session.canSetSessionPreset(.iFrame960x540) {
                    session.sessionPreset = .iFrame960x540
                }
                let totalSeconds = 15.0     //Total Seconds of capture time
                let timeScale: Int32 = 15 //FPS
                let maxDuration = CMTimeMakeWithSeconds(totalSeconds, timeScale)
                
                videoOutput?.maxRecordedDuration = maxDuration
                videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024 //SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
                
                if session.canAddOutput(videoOutput!) {
                    session.addOutput(videoOutput!)
                }
                
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer.frame = self.cameraView.bounds
                //                videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoLayer.connection?.videoOrientation = .portrait
                self.cameraView.layer.addSublayer(videoLayer)
                session.startRunning()
            }
            cameraView.bringSubview(toFront: flashButtonOutlet)
            cameraView.bringSubview(toFront: flipButtonOutlet)
            
            videoStartImage = UIImage(named: "video_button")
            videoStopImage = UIImage(named: "video_button_rec")
        } catch {
            print ("error occured kutreya")
        }
        self.startCamera()
    }
    
    func startCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == AVAuthorizationStatus.authorized {
            session?.startRunning()
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            session?.stopRunning()
        }
    }
    
    func stopCamera() {
        if self.isRecording {
            self.toggleRecording()
        }
        session?.stopRunning()
    }
    
    func toggleRecording() {
        guard let videoOutput = videoOutput else { return }
        
        self.isRecording = !self.isRecording
        let shotImage: UIImage?
        if self.isRecording {
            shotImage = videoStopImage
        } else {
            shotImage = videoStartImage
        }
        recordButtonOutlet.setImage(shotImage, for: UIControlState())
        
        if self.isRecording {
            recordButtonOutlet.layer.addSublayer(addAnimated(duration: 15, color: .red, viewer: recordButtonOutlet))
            
            let outputPath = "\(NSTemporaryDirectory())originalVideo.mov"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: outputPath) {
                do {
                    try fileManager.removeItem(atPath: outputPath)
                } catch {
                    print("error removing item at path: \(outputPath)")
                    self.isRecording = false
                    return
                }
            }
            flipButtonOutlet.isEnabled = false
            flashButtonOutlet.isEnabled = false
            recordButtonOutlet.isEnabled = false

            delay(3) {
                self.recordButtonOutlet.isEnabled = true
            }
            videoOutput.startRecording(to: outputURL, recordingDelegate: self)
        } else {
            self.recordButtonOutlet.layer.sublayers?.removeLast()
            videoOutput.stopRecording()
            flipButtonOutlet.isEnabled = true
            flashButtonOutlet.isEnabled = true
        }
        return
    }
    
    @IBAction func dismissCurrentView(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func flashButtonAction(_ sender: UIButton) {
        
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureDevice.TorchMode.on) {
                    device?.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    do {
                        try device?.setTorchModeOn(level: 1.0)
                    } catch {
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func flipButtonAction(_ sender: Any) {
        let button = sender as! UIButton
//        print(button.transform)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            
            button.transform = self.transform
            self.transform = self.transform == CGAffineTransform(a: -0.598460069057858, b: -0.801152635733831, c: 0.801152635733831, d: -0.598460069057858, tx: 0.0, ty: 0.0) ? CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 0.0, ty: 0.0) : CGAffineTransform(a: -0.598460069057858, b: -0.801152635733831, c: 0.801152635733831, d: -0.598460069057858, tx: 0.0, ty: 0.0)
            self.session?.stopRunning()
            do {
                self.session?.beginConfiguration()
                if let session = self.session {
                    for input in session.inputs {
                        session.removeInput(input )
                    }
                    let position = (self.videoInput?.device.position == AVCaptureDevice.Position.front) ? AVCaptureDevice.Position.back : AVCaptureDevice.Position.front
                    self.device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position)
                    self.videoInput = try AVCaptureDeviceInput(device: self.device!)
                    session.addInput(self.videoInput!)
                    self.audioInput = AVCaptureDevice.default(for: AVMediaType.audio)
                    try session.addInput(AVCaptureDeviceInput(device: self.audioInput!))
                }
                self.session?.commitConfiguration()
            } catch {
            }
            self.session?.startRunning()
        }, completion: nil)
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        toggleRecording()
    }
    
    func addAnimated(duration: Double, color: UIColor, viewer: UIView) -> (CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.repeatCount = 0
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        let circleLayer   = CAShapeLayer()
        let center = CGPoint (x: (viewer.frame.size.width / 2), y: (viewer.frame.size.height / 2))
        let circleRadius = (viewer.frame.size.width / 2) - 2
        let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(1.5*Double.pi), clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = color.cgColor
        circleLayer.fillColor = nil
        circleLayer.lineWidth = 2
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd  = 1
        circleLayer.add(animation, forKey: "strokeEnd")
        
        return circleLayer
    }
    
}

extension NewVideoEntryViewController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        
        let vcNew = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VideoEditorViewController") as? VideoEditorViewController
        vcNew?.assetsURL = outputFileURL
        vcNew?.geopoint = geopoint
//        self.navigationController?.pushViewController(vcNew!, animated: true)
        let navController: UINavigationController? = navigationController
        var controllers: [AnyHashable]? = nil
        if let aControllers = navController?.viewControllers {
            controllers = aControllers
        }
        controllers?.removeAll()
        if let aControllers = controllers as? [UIViewController] {
            navController?.viewControllers = aControllers
        }
        if let aController2 = vcNew {
            navController?.pushViewController(aController2, animated: false)
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset960x540) else {
            handler(nil)
            return
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov // AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
}

