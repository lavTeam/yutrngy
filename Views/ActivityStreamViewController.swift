    //
//  ActivityStreamViewController.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 03.07.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import FSPagerView
import SDWebImage
import AVKit

class ActivityStreamViewController: UIViewController {
    //Массив пока не ясно каких данных из mapVC
    //    var array = [Any]()
    var previusPoint: CGPoint?
    var firstRun = true
    var activePager: Int?// = Int()
    
    var arrayVisible = [PinsVideoPost]()
    var originalPosition: CGPoint?
    var currentPosition: CGPoint?
    
    
    
    @IBAction func pressShowCommentsBtn(_ sender: UIButton) {
    
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
        vc.currentConversations = Conversation(video: nil, conversationID: arrayVisible[activePager!].documentID!, conversationURL: "http://yandex.ru", conversationTitle: "ЧАТИК!!!!!", lastMessage: nil)
//        vc.view.center = self.view.center
//        vc.view.frame.size = CGSize(width: self.view.frame.width * 0.9, height: self.view.frame.height * 0.9)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PauseAvPlayer"), object: nil, userInfo: nil)
        
        UIView.animate(withDuration: 0.5) {
            self.activityStreamPager?.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
        }
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    
    @IBOutlet weak var activityCollection: UICollectionView!
    @IBOutlet weak var activityStreamPager: FSPagerView?  {
        didSet {
            let nib = UINib(nibName: "ActivityStreamPagerCell", bundle: nil)
            activityStreamPager?.register(nib,forCellWithReuseIdentifier: "ActCell")
            activityStreamPager?.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 4, height: UIScreen.main.bounds.size.height - 24)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        activityCollection.isHidden = true
    
        activityStreamPager?.alwaysBounceVertical = false

        activityCollection.allowsMultipleSelection = false

        activityStreamPager?.delegate = self
        activityStreamPager?.dataSource = self
        
        let tap = UIPanGestureRecognizer(target: self, action: #selector(gesture(_:)))
        tap.maximumNumberOfTouches = 1
        activityStreamPager?.addGestureRecognizer(tap)
        findMapViewController()
        
        // следим зановым экземляром плеера
        NotificationCenter.default.addObserver(self, selector: #selector(observerCurrentPlayerItem), name: NSNotification.Name(rawValue: "currentPlayerItem"), object: nil)
        


    }
    @objc func observerCurrentPlayerItem(_ notification: Notification?) {
        if notification?.object != nil {
//            print(notification?.object)
                    NotificationCenter.default.addObserver(self, selector: #selector(playNextItem(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: notification?.object)
        }
        
    }
    @objc func closeControllerWithContainer() {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CloseAvPlayer"), object: nil, userInfo: ["result": true])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CloseContainer"), object: nil, userInfo: ["result": true])
            self.dismiss(animated: true, completion: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PauseAvPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CloseAvPlayer"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CloseContainer"), object: nil)
    }
    
    @objc func gesture(_ panGesture: UIPanGestureRecognizer) {
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
                        self.closeControllerWithContainer()
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

    
    func findMapViewController() {
        // Ищем MapViewController
        let app = UIApplication.shared.delegate! as! AppDelegate
        if let viewControllers = app.window?.rootViewController?.childViewControllers {
            viewControllers.forEach { vc in
                if let cont = vc as? MapViewController {
                    cont.delegate = self
                }
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}


extension ActivityStreamViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
//        print(arrayVisible.count)
        return arrayVisible.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "ActCell", at: index) as! ActivityStreamPagerCell

        DispatchQueue.global().async {
            let data = try? Data(contentsOf: URL(string: self.arrayVisible[index].videoThumbnailStringUrl!)!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                cell.imageView2?.image = UIImage(data: data!)
            }
        }
        showActivityIndicator(text: nil)
        CacheManager.shared.getFileWith(stringUrl: arrayVisible[index].videoStringUrl!) { result in
            switch result {
            case .success(let url):
                cell.videoItemUrl = url
                self.hideActivityIndicator()
//                print(cell.avPlayer?.currentItem)
                // загружаем следующее видео
                if index + 1 <= self.arrayVisible.count - 1 {
                    CacheManager.shared.getFileWith(stringUrl: self.arrayVisible[index + 1].videoStringUrl!) { result in
                    }
                }
            case .failure(let error):
                print("fucking error: \(error)")
                self.hideActivityIndicator()
            }
        }
        
// если не первый запуск
        guard !firstRun else { firstRun = false; return cell }
        activePager = index
        UIView.animate(withDuration: 0.3) {
            self.activityCollection.scrollToItem(at: IndexPath(row: self.activePager!, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: false)
        }
        activityCollection.reloadData()
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "ActCell", at: index) as! ActivityStreamPagerCell
        cell.close()

    }
    @objc public func playNextItem(_ notification: Notification?) {
//        print("funcional :", notification?.object as? AVPlayerItem)
        print("playNextItem: ", activePager)
        guard let activePager = activePager else { return }
        if activePager + 1 > arrayVisible.count - 1 {
            activityStreamPager?.scrollToItem(at: 0, animated: true)
        } else {
            activityStreamPager?.scrollToItem(at: activePager + 1, animated: true)
        }
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: notification?.object)
    }
}

extension ActivityStreamViewController: RecieveDataToActivityPager {
    func reciviedData(data: [PinsVideoPost], currentState: Int) {
        // получаем от map массив из ленты активности
        arrayVisible = data
        activityCollection.delegate = self
        activityCollection.dataSource = self
        activePager = currentState
        delay(0.2) {
            self.activityStreamPager?.scrollToItem(at: self.activePager!, animated: false)
            self.activityStreamPager?.reloadData()
        }
    }
}

extension ActivityStreamViewController:  UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayVisible.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BottomCollectionViewCell
        cell.image.image = #imageLiteral(resourceName: "465982789")
        if activePager == indexPath.row {
            self.createBorderForView(view: cell, color: .green, radius: cell.frame.width/2, width: 1, alphaAnimated: 0.2, duration: 0.5)
        } else {
            createBorderForView(view: cell, color: .clear, radius: cell.frame.width/2, width: 0, alphaAnimated: 1, duration: 0)
        }
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.activityStreamPager?.scrollToItem(at: indexPath.row, animated: false)


        if indexPath.row == activePager {
            closeControllerWithContainer()
        }
    }
}
