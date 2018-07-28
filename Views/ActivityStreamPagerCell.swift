//
//  ActivityStreamPagerCell.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 03.07.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import AVKit
import FSPagerView

class ActivityStreamPagerCell: FSPagerViewCell {
    @IBOutlet weak var videoPlayerView: UIView!
    var animation: CABasicAnimation? = nil
    var avPlayerViewController: AVPlayerViewController?
    var avPlayer: AVPlayer?
    var videoItemUrl: URL? {
        didSet {
            initNewPlayerItem()
        }
    }
    var imageView2: UIImageView?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bounds = UIScreen.main.bounds
        self.layoutIfNeeded()
        
        setupMoviePlayer()
        NotificationCenter.default.addObserver(self, selector: #selector(close), name: NSNotification.Name(rawValue: "CloseAvPlayer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: NSNotification.Name(rawValue: "PauseAvPlayer"), object: nil)

    }
    
    @objc func close() {
        avPlayerViewController?.player?.pause()
        avPlayerViewController?.player = nil
    }
    @objc func pause() {
        avPlayer?.pause()
        let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }

    
    func resumeAnimation(){
        let pausedTime: CFTimeInterval = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
    
    
    private func setupMoviePlayer() {
        self.imageView2 = UIImageView()
        imageView2?.frame = self.bounds
        avPlayerViewController = AVPlayerViewController()
        avPlayerViewController?.view.frame = self.bounds
        avPlayerViewController?.view.backgroundColor = UIColor.clear
//        avPlayerViewController?.view.addSubview(imageView2!)
        self.avPlayer = AVPlayer()
        avPlayerViewController?.player = avPlayer
        avPlayerViewController?.videoGravity = AVLayerVideoGravity.resize.rawValue

//        avPlayerViewController?.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        avPlayerViewController?.showsPlaybackControls = false
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        videoPlayerView.addSubview(imageView2!)
        videoPlayerView.addSubview((avPlayerViewController?.view)!)
    }
    
    private func initNewPlayerItem() {
        
        // Pause the existing video (if there is one)
        avPlayer?.pause()
        // First we need to make sure we have a valid URL
        guard let videoPlayerItemUrl = videoItemUrl else { return }
        
        // Create a new AVAsset from the URL
        let videoAsset = AVAsset(url: videoPlayerItemUrl)
        let duration = videoAsset.duration.seconds
        print("Время в секундахЖ ", duration)
        videoAsset.loadValuesAsynchronously(forKeys: ["duration"]) {
            DispatchQueue.main.async {
                let videoPlayerItem = AVPlayerItem(asset: videoAsset)
                videoPlayerItem.preferredForwardBufferDuration = 2.0
                DispatchQueue.main.async {
                    // Finally, we set this as the current AVPlayer item
                    self.avPlayer?.replaceCurrentItem(with: videoPlayerItem)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "currentPlayerItem"), object: self.avPlayer?.currentItem)
                    self.avPlayer?.play()
                    DispatchQueue.main.async {
                        self.videoPlayerView.layer.addSublayer(self.addCircleAnimated(duration: duration, color: .blue, viewer: self.videoPlayerView))
                    }
                }
            }
            
        }
    }
    
    
    func addCircleAnimated(duration: Double, color: UIColor, viewer: UIView) -> (CAShapeLayer) {
        animation = CABasicAnimation(keyPath: "strokeEnd")
        animation?.repeatCount = 0
        animation?.duration = duration
        animation?.fromValue = 0
        animation?.toValue = 1
        animation?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        let circleLayer   = CAShapeLayer()
        let center = CGPoint (x: (viewer.frame.size.width - 40), y: 40)
        let circleRadius : CGFloat = 15
        let circlePath = UIBezierPath(arcCenter: center, radius: circleRadius, startAngle: CGFloat(-Double.pi/2), endAngle: CGFloat(1.5*Double.pi), clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = color.cgColor
        circleLayer.fillColor = nil
        circleLayer.lineWidth = 4
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd  = 1
        circleLayer.add(animation!, forKey: "strokeEnd")
        
        return circleLayer
    }
    
    
}


