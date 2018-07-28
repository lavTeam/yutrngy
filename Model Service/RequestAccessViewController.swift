//
//  RequestAccessViewController.swift
//  dmaker
//
//  Created by Aleksey Larichev on 31.05.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import Firebase

//import CoreLocation

class RequestAccessViewController: UIViewController {
    var checkCam = false
    var checkPho = false
    var checkLoc = false
    @IBOutlet weak var checkCamera: UIImageView!
    @IBOutlet weak var checkPhoto: UIImageView!
    @IBOutlet weak var checkLocation: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.

    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    @IBAction func requestCamera(_ sender: UIButton) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                DispatchQueue.main.async {
                    self.checkCamera.image = #imageLiteral(resourceName: "check_green")
                }
            } else {
                let alert = UIAlertController(title: "Camera", message: "Camera access is required to use this application", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                }))
                self.present(alert, animated: true)
            }
        }
        
        
        
    }
    @IBAction func requestPhoto(_ sender: UIButton) {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            if newStatus ==  PHAuthorizationStatus.authorized {
                DispatchQueue.main.async {
                    self.checkPhoto.image = #imageLiteral(resourceName: "check_green")
                    
                }
            }
        })
    }
    @IBAction func requestLocation(_ sender: UIButton) {
        LocationService.instance.requestAccessLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(checkLocation(_:)), name: NSNotification.Name(rawValue: "CheckLocationAllow"), object: nil)
    }
    
    @objc func checkLocation(_ notification: NSNotification) {
        if notification.name.rawValue == "CheckLocationAllow" {
            if let result = notification.userInfo!["result"] as? Bool {
                if result == true {
                   self.checkLocation.image = #imageLiteral(resourceName: "check_green")
                }
            }
        }
    }
    
}
