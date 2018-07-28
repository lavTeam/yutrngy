//
//  MenuViewController.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 03.07.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
class MenuViewController: UIViewController {
    deinit {
        print("deinit MenuViewController")
    }
//    var user: MyUser?

    let segueIdentificator = "SettingsProfile"
    var previusPoint: CGPoint?
    var originalPosition: CGPoint?
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var settingsButton: UIButton!

    var image: UIImage? = nil
    let uiPicker: UIPickerView = UIPickerView()
    var shapelayer = CAShapeLayer()
    var shapelayer_new = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    var newImageProfileCreate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.isEnabled = false
        
        guard let user = currentUser else {return}
        self.createBorderForView(view: self.profileImage, color: UIColor.white, radius: self.profileImage.frame.width/2, width: 1, alphaAnimated: 1, duration: 0)
        self.profileImage.sd_setImage(with: URL(string: (user.imageProfileURL)!), placeholderImage: nil, options: SDWebImageOptions.allowInvalidSSLCertificates, completed: nil)
        self.nameLabel.text = (currentUser?.username)!
        self.settingsButton.isEnabled = true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentificator {
            
 
        }
    }
    @IBAction func pressBtnSettings(_ sender: UIButton) {
        let vcNew = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: segueIdentificator) as? EditProfileViewController

        let navController: UINavigationController? = navigationController
        let controllers: [AnyHashable]? = nil

        if let aControllers = controllers as? [UIViewController] {
            navController?.viewControllers = aControllers
        }
        if let aController2 = vcNew {
            navController?.pushViewController(aController2, animated: false)
        }
    }
    @IBAction func gesture(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        let currentPosition = panGesture.location(in: view)

        switch panGesture.state {
        case .began:
            originalPosition = view.center
            previusPoint = currentPosition
        case .changed:
            if currentPosition.y - (previusPoint?.y)! > 0 {
            view.frame.origin = CGPoint(
                x:  view.frame.origin.x,
                y:  view.frame.origin.y + translation.y
            )
            panGesture.setTranslation(CGPoint.zero, in: self.view)
                }

        case .ended:
            let velocity = panGesture.velocity(in: view)
            if velocity.y >= 150 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.view.frame.origin = CGPoint(
                            x: self.view.frame.origin.x,
                            y: self.view.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = self.originalPosition!
                })
            }
        default:
            break
        }
    }
}


extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        let imagePickerView = UIImagePickerController()
        imagePickerView.delegate = self
        
        let actionSheet = UIAlertController(title: nil, message: NSLocalizedString("Источник изображения:", comment: "Источник изображения:"), preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Камера", comment: "Камера"), style: .default, handler: { (action) in
            imagePickerView.sourceType = .camera
            imagePickerView.allowsEditing = false
            imagePickerView.cameraCaptureMode = .photo
            imagePickerView.modalPresentationStyle = .fullScreen
            self.present(imagePickerView, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Галерея", comment: "Галерея"), style: .default, handler: { (action) in
            imagePickerView.sourceType = .photoLibrary
            self.present(imagePickerView, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Отмена", comment: "Отмена"), style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        animation.toValue = 1
        animation.duration = 5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false
        shapelayer_new.add(animation, forKey: nil)
        delay(3) {
            self.shapelayer_new.removeFromSuperlayer()
        }
        let imagePicker  = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        profileImage.image = imagePicker
        newImageProfileCreate = true
        picker.dismiss(animated: true, completion: nil)
        
        
    }
}
