//
//  PropertiesVideoPostViewController.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 11.07.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import MapKit
import FirebaseUI
import GeoFire

class PropertiesVideoPostViewController: UIViewController {
    deinit {
        print("deinit PropertiesVideoPostViewController")
    }
    var geopoint : CLLocation?
    var thumbnailStringUrl: String?
    var postVideo: Post?
    var urlVideoOutput: URL?
    var viewProgress: UIView?
    
    var postForAll: Bool = false
    @IBOutlet weak var availableView: UIView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var imageSelected: UIImageView!
    // picker Data
    var categoryChange: String?
    var adulthoodChange: String?
    var genderChange: String?

    @IBOutlet weak var genderPickerView: AKGesturePickerView!
    @IBOutlet weak var categoryPickerView: AKGesturePickerView!
    @IBOutlet weak var adulthoodPickerView: AKGesturePickerView!
    @IBOutlet weak var horizontalViewGender: UIView!
    @IBOutlet weak var horizontalViewAdult: UIView!
    
    @IBOutlet weak var finishedView: UIView!
    
    @IBAction func savePost(_ sender: UIButton) {
        guard let url = urlVideoOutput else { return }
        var post = postVideo
        showActivityIndicator(text: nil)
        post?.videoStringUrl = url.absoluteString
        updateVideoPostWithNewProoerties(forAll: postForAll)
    }
    

    @IBAction func changeAvailbleButton(_ sender: UIButton) {
        postForAll = !postForAll
        switch postForAll {
        case false:
            availableView.backgroundColor = UIColor.white
            imageSelected.image = #imageLiteral(resourceName: "unselected")
            showViewWithPostAction()

        case true:
            availableView.backgroundColor = UIColor.yellow
            imageSelected.image = #imageLiteral(resourceName: "selected")
            showViewWithPostAction()

        }
    }

    func showViewWithPostAction() {
        switch postForAll {
        case false:
            if genderChange != nil && adulthoodChange != nil && self.categoryChange != nil {
//                 Показываем
                UIView.animate(withDuration: 0.7) {
                    self.horizontalViewGender.backgroundColor = UIColor.white
                    self.horizontalViewGender.frame.size.height = 1
                    
                    self.horizontalViewAdult.backgroundColor = UIColor.white
                    self.horizontalViewAdult.frame.size.height = 1
                    
                    self.finishedView.frame.origin.y = UIScreen.main.bounds.height - self.finishedView.frame.height
                    self.view.setNeedsDisplay()
                }
            
            } else {
                //            Прячем
                UIView.animate(withDuration: 0.7) {
                    self.horizontalViewGender.backgroundColor = UIColor.white
                    self.horizontalViewGender.frame.size.height = 1
                    
                    self.horizontalViewAdult.backgroundColor = UIColor.white
                    self.horizontalViewAdult.frame.size.height = 1
                    
                    self.finishedView.frame.origin.y = UIScreen.main.bounds.height
                    self.view.setNeedsDisplay()
                }
            }

//            break
        case true:
            
            if self.categoryChange != nil {
                //                 Показываем
                UIView.animate(withDuration: 0.7) {
                    self.horizontalViewGender.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                    self.horizontalViewGender.frame.size.height = self.categoryPickerView.frame.height
                    
                    self.horizontalViewAdult.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                    self.horizontalViewAdult.frame.size.height = self.adulthoodPickerView.frame.height
                    
                    self.finishedView.frame.origin.y = UIScreen.main.bounds.height - self.finishedView.frame.height
                    self.view.setNeedsDisplay()
                }
            } else {
                //            Прячем
                UIView.animate(withDuration: 0.7) {
                    self.horizontalViewGender.backgroundColor = UIColor.white
                    self.horizontalViewGender.frame.size.height = 1
                    
                    self.horizontalViewAdult.backgroundColor = UIColor.white
                    self.horizontalViewAdult.frame.size.height = 1
                    
                    self.finishedView.frame.origin.y = UIScreen.main.bounds.height
                    self.view.setNeedsDisplay()
                }
            }
            
            
            
            guard self.categoryChange != nil  else { return }
//            Прячем
            UIView.animate(withDuration: 0.7) {
                self.horizontalViewGender.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                self.horizontalViewGender.frame.size.height = self.categoryPickerView.frame.height
                
                self.horizontalViewAdult.backgroundColor = UIColor.white.withAlphaComponent(0.3)
                self.horizontalViewAdult.frame.size.height = self.adulthoodPickerView.frame.height
                
                self.finishedView.frame.origin.y = UIScreen.main.bounds.height - self.finishedView.frame.height
                self.view.setNeedsDisplay()
            }

        }
    }
    
    func updateVideoPostWithNewProoerties(forAll: Bool) {
        guard let category = categoryChange else {showAlertController(title: "Ahtung!".localized, message: "No category selected".localized); return}
        guard let videoURL = urlVideoOutput else {showAlertController(title: "Ahtung!".localized, message: "An error occurred while uploading the video.".localized); return}
        let location = (geopoint != nil) ? geopoint! : currentLocation!
        
        switch forAll {
        case true:
            composePost(category: category, videoUrl: videoURL.absoluteString, descriptionPost: "", sex: Sex.Other.rawValue, ageLimit: false, location: location, isPublished: true) { (newVideoPost) in
                self.putPostToFirebase(newPost: newVideoPost)
            }
        case false:
            var ageLimit: Bool = false
            guard let gender = genderChange else {showAlertController(title: "Ahtung!".localized, message: "No gender selected".localized); return}
            guard let adulthood = adulthoodChange else {showAlertController(title: "Ahtung!".localized, message: "No adulthood selected".localized); return}
            if adulthood == "Yes" {
                ageLimit = true
            } else {
                ageLimit = false
            }
            composePost(category: category, videoUrl: videoURL.absoluteString, descriptionPost: "", sex: gender, ageLimit: ageLimit, location: location, isPublished: true) { (newVideoPost) in
                self.putPostToFirebase(newPost: newVideoPost)
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        adulthoodPickerView.delegate = self
        adulthoodPickerView.dataSource = self
        genderPickerView.delegate = self
        genderPickerView.dataSource = self


        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.statusUpload(_:)), name: NSNotification.Name(rawValue: "UploadVideoCheck"), object: nil)

    }
    
    // MARK: - Собираем запись и сохраняем
    func composePost(category: String, videoUrl: String, descriptionPost: String, sex: String?, ageLimit: Bool, location: CLLocation, isPublished: Bool, completion: @escaping (Post)->()) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        DispatchQueue.main.async {
            self.showActivityIndicator(text: nil)
            
        }
        let sexValue = sex == nil ? Sex.Other : Sex(rawValue: sex!)
        //        print(Category(rawValue: category)!)
        
        let post = Post(userID: currentUserID, category: Category(rawValue: category)!, videoStringUrl: videoUrl, videoThumbnailStringUrl: self.thumbnailStringUrl!, descriptionPost: descriptionPost, sex: sexValue, ageLimit: ageLimit, l: [location.coordinate.latitude, location.coordinate.longitude], g: GFGeoHash(location: location.coordinate).geoHashValue, createdAt: Date(), isPublished: true, documentID: nil, user: nil)
        completion(post)
        //            putPostToFirebase(newPost: post)
    }
    
    @objc func statusUpload(_ notification: NSNotification) {
        if notification.name.rawValue == "UploadVideoCheck" {
            guard let percent = notification.userInfo!["result"] as? Double else { return }
            print("Процентр загрузки видеоролика: ", percent)
            self.viewProgress = UIView()
            self.viewProgress?.tag = 25
            self.viewProgress?.backgroundColor = UIColor.yellow
            self.viewProgress?.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - 3)

            if !(percent.isNaN || percent.isInfinite) {
                UIView.animate(withDuration: 0.5) {
                    print("Ширина вьюшки: ", UIScreen.main.bounds.width * CGFloat(percent))
                    self.showVC(text: "Загружено", width: UIScreen.main.bounds.width * CGFloat(percent/100))

                }
                guard let url = notification.userInfo!["url"] as? URL else { return }
                self.urlVideoOutput = url
                UIView.animate(withDuration: 0.5) {
                    self.hideVC()
                }
                
            }
        }
    }
    // СОхраняем пост в Firestore
    func putPostToFirebase(newPost: Post) {
        FirebaseService.instance.createVideoPostFireBase(postType: newPost) { (test) in
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                self.closeAllVC()
            }
            
        }
    }
    func closeCurrentController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func closeAllVC() {
        let navController: UINavigationController? = navigationController
        var controllers: [AnyHashable]? = nil
        if let aControllers = navController?.viewControllers {
            controllers = aControllers
        }
        controllers?.removeAll()
    }
}

// MARK: - AKGesture Delegate
extension PropertiesVideoPostViewController: AKGesturePickerViewDelegate, AKGesturePickerViewDataSource {
    func numberOfItemsInGesturePickerView(_ gesturePickerView: AKGesturePickerView) -> Int {
        switch gesturePickerView {
        case categoryPickerView:
            return Category.allValues.count
        case adulthoodPickerView:
            return Adulthood.allValues.count
        case genderPickerView:
            return Sex.allValues.count
        default:
            return 0
        }
        
        
    }
    func gesturePickerView(_ gesturePickerView: AKGesturePickerView, titleForItem item: Int) -> String {
        switch gesturePickerView {
        case categoryPickerView:
            return Category.allValues[item].localizedDescription
        case adulthoodPickerView:
            return Adulthood.allValues[item].localizedDescription
        case genderPickerView:
            return Sex.allValues[item].localizedDescription

        default:
            return ""
        }
        
    }
    func gesturePickerView(_ gesturePickerView: AKGesturePickerView, didSelectItem item: Int) {
        switch gesturePickerView {
        case categoryPickerView:
            categoryChange = Category.allValues[item].rawValue
            showViewWithPostAction()

        case adulthoodPickerView:
            adulthoodChange = Adulthood.allValues[item].rawValue
            showViewWithPostAction()
            
        case genderPickerView:
            genderChange = Sex.allValues[item].rawValue
            showViewWithPostAction()
        default:
            break
        }
    }
    
}
