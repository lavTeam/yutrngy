//
//  MapVIewController.swift
//  dmaker
//
//  Created by Aleksey Larichev on 31.05.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseAuth
import SDWebImage

protocol RecieveDataToActivityPager {
    func reciviedData(data: [PinsVideoPost], currentState: Int)
}

class MapViewController: UIViewController {
    deinit {
        print("deinit MapViewController")
    }
    
    var temoOldArray = [PinsVideoPost]()
    
    
    // For Gesture
    var previusPoint: CGPoint?
    let userUid = Auth.auth().currentUser?.uid
    //
    var containerController: EmbedContainerController?
var oldGeoPoint: CLLocation?
    var firstRun: Bool = true
    var delegate : RecieveDataToActivityPager?
    var selectedElement: Int?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileViewHeight: NSLayoutConstraint!
    @IBOutlet weak var profileNameUser: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let locationManager = CLLocationManager()
    let geocode = CLGeocoder()
    var annotation = MKPointAnnotation()
    let regionRadius: CLLocationDistance = 20000
    var geopoint: CLLocation?
    var visibleAnnotations: Set<AnyHashable> = []
    var arrayVisiblePins = [PinsVideoPost]()
    // MARK:  поиск для геолокации
    var matchingItems = [MKMapItem]()
    @IBOutlet weak var searchText: UITextField!
    @IBAction func searchTextFields(_ sender: UITextField) {
        _ = sender.resignFirstResponder()
        //удаляем аннотации
        mapView.removeAnnotations(mapView.annotations)
        performSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        LocationService.instance.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        LocationService.instance.requestAccessLocation()
        
        // Gesture for map press Get Location
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(getTapCoordinate(gestureRecognizer:)))
        longPressGesture.minimumPressDuration = 0.2
        mapView.addGestureRecognizer(longPressGesture)
        
        LocationService.instance.startUpdatingLocation()
 
        NotificationCenter.default.addObserver(self, selector: #selector(showHideConteinerView), name: NSNotification.Name(rawValue: "CloseContainer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColectionView), name: NSNotification.Name("PinOnMapComplete"), object: nil)

        FirebaseService.instance.getVideoPostFireBase { (arrayVideoPosts) in
            self.createPinsWithVideoPost(array: arrayVideoPosts)
        }
        configProfileActions()

        
        if currentUser == nil {
            FirebaseService.instance.getUserByIDFirebase(userID: (Auth.auth().currentUser?.uid)!) { (user) in
                currentUser = user
            }
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView!.contentInset = UIEdgeInsets(top: 5, left: 5, bottom:5, right: 5)
        
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 10
            layout.itemSize = CGSize(width: 50, height: 50)
            layout.invalidateLayout()
        }
    }
    
    @objc func updateColectionView() {
        mapView(mapView, regionDidChangeAnimated: true)
    }
    func configProfileActions() {
        profileBtn.addTarget(self, action: #selector(didTapProfileButton), for: .touchUpInside)
        profileBtn.imageView?.contentMode = .scaleAspectFit
        
        logoutBtn.addTarget(self, action: #selector(logout), for: .touchUpInside)
        logoutBtn.imageView?.contentMode = .scaleAspectFit
    }
    
    @objc func didTapProfileButton() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "menuVC") as! MenuViewController

        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .overFullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func logout() {
        try! Auth.auth().signOut()
    }
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - Location (Begin)

extension MapViewController: LocationServiceDelegate {
    func tracingLocation(currentLocation: CLLocation) {
        centerMapOnLocation(location: currentLocation)
        FirebaseService.instance.getVideoPostsWithLocation(location: currentLocation) { (posts) in
            print(posts)
        }

    }
    
    func tracingLocationDidFailWithError(error: Error) {
        print(error)
    }
    
}


extension MapViewController : MKMapViewDelegate {

    //Video Post Pin
    func createPinsWithVideoPost(array: [Post]) {
        var postPins = [PinsVideoPost]()
        mapView.removeAnnotations(mapView.annotations)
        for item in array {
            postPins.insert(PinsVideoPost(user: item.user!,
                                              imageProfileStringUrl: nil,
                                              titleCategory: item.category.localizedDescription,
                                              lat: item.l[0],
                                              long: item.l[1],
                                              new: false,
                                              description: item.descriptionPost,
                                              documentID_Post: item.documentID,
                                              videoURL: item.videoStringUrl,
                                              videoThumbnailURL: item.videoThumbnailStringUrl,
                                              sexUser: Sex(rawValue: item.sex!.localizedDescription)!,
                                              limitAge: item.ageLimit!,
                                              created: item.createdAt), at: 0)
                print(postPins)

        }
        temoOldArray = postPins
        mapView.addAnnotations(postPins)
        self.arrayVisiblePins = postPins
    }
    
    // получает координты с нажатия на экран
    @objc func getTapCoordinate(gestureRecognizer:UIGestureRecognizer) {
        if(gestureRecognizer.state == UIGestureRecognizerState.began) {
            // Получаем точку с долгово нажатия
            let touchPoint = gestureRecognizer.location(in: mapView)
            //Point to Coordinate
            let newCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            self.geopoint = location

            //coordinateToAdress
            createPinOnMap(location)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard ((view.annotation as? PinsVideoPost)?.documentID) != nil else { return }
        guard let item = (view.annotation as? PinsVideoPost) else { return }
//        print("Номер элемента в массиве: ", arrayVisiblePins.index(of: item)!)
        selectedElement = arrayVisiblePins.index(of: item)!

    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("mapView(_:annotationView:calloutAccessoryControlTapped)")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotationNew = annotation as? PinsVideoPost else { return nil}
        
        let reuseId = "ProfilePinView"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        
        switch annotationNew.isNew {
        case true:
            let rightButton = UIButton(type: .contactAdd)
            rightButton.tag = annotation.hash
            rightButton.addTarget(self, action: #selector(goToNewEntry), for: UIControlEvents.touchUpInside)
            pinView!.rightCalloutAccessoryView = rightButton
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label1.text = annotationNew.descriptionPost
            label1.numberOfLines = 0
            pinView!.detailCalloutAccessoryView = label1
            
        default:
            let rightButton = UIButton(type: .infoDark)
            rightButton.tag = annotation.hash
            rightButton.addTarget(self, action: #selector(goToShowEntry), for: UIControlEvents.touchUpInside)
            pinView!.rightCalloutAccessoryView = rightButton
            let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label1.text = annotationNew.descriptionPost
            label1.numberOfLines = 0
            pinView!.detailCalloutAccessoryView = label1
        }
        
        switch annotationNew.category {
        case .none:
            self.mapView.removeAnnotation(annotationNew)

            pinView!.image = #imageLiteral(resourceName: "pinSmall")

        case .some(.Eat):
            pinView!.image = UIImage(named: "Eat")  ///!!!!
        case .some(.Job):
            pinView!.image = UIImage(named: "Job") ////!!!!
        case .some(.Cafe):
            pinView!.image = UIImage(named: Category.Cafe.rawValue) // #imageLiteral(resourceName: "pinSmall") //UIImage(named: "pinsForMap")
        case .some(.Beatiful):
            pinView!.image = UIImage(named: "Beatiful") ///!!!!!!!!

        case .some(.Other):
            pinView!.image = UIImage(named: Category.Other.rawValue)

        case .some(.Sport):
            pinView!.image = UIImage(named: Category.Sport.rawValue)

        case .some(.Family):
            pinView!.image = UIImage(named: Category.Family.rawValue)

        case .some(.Kids):
            pinView!.image = UIImage(named: Category.Kids.rawValue)

        case .some(.Religion):
            pinView!.image = UIImage(named: Category.Religion.rawValue)

        case .some(.Shopping):
            pinView!.image = UIImage(named: Category.Shopping.rawValue)

        case .some(.LiteratureArt):
            pinView!.image = UIImage(named: "LiteratureArt")

        case .some(.Tehnics):
            pinView!.image = UIImage(named: Category.Tehnics.rawValue)

        case .some(.Politics):
            pinView!.image = UIImage(named: Category.Politics.rawValue)

        case .some(.Travels):
            pinView!.image = UIImage(named: Category.Travels.rawValue)

        case .some(.MoviesMusic):
            pinView!.image = UIImage(named: "MoviesMusic")

        }
//        print("ЗАКОНЧИЛИ СТАВИТЬ ПИНЫ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        pinView!.canShowCallout = true

        
        NotificationCenter.default.post(name: NSNotification.Name("PinOnMapComplete"), object: nil)
        return pinView
        
    }
    func getRadius(centralLocation: CLLocation) -> Double{
        let topCentralLat:Double = centralLocation.coordinate.latitude -  mapView.region.span.latitudeDelta/2
        let topCentralLocation = CLLocation(latitude: topCentralLat, longitude: centralLocation.coordinate.longitude)
        let radius = centralLocation.distance(from: topCentralLocation)
        return radius / 1000.0 // to convert radius to meters
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // MARK: - Видимые пины на карте!
        let centralLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude:  mapView.centerCoordinate.longitude)
        print("Radius - \(self.getRadius(centralLocation: centralLocation))")

        
        var distance: CLLocationDistance?
        let visibleMapRect: MKMapRect = mapView.visibleMapRect
//        print(mapView.region)
         let currentGeoPoint = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        if oldGeoPoint != nil {
            distance = oldGeoPoint!.distance(from: currentGeoPoint)
        }
        if distance != nil && Int(distance!) >= 30000 {
            oldGeoPoint = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        }
        if firstRun {
            firstRun = false
            oldGeoPoint = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        }



        visibleAnnotations = mapView.annotations(in: visibleMapRect)
        print("ОБНОВЛЯЕМ РЕГИОН!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
            let arra = (Array(visibleAnnotations)) as! Array<PinsVideoPost>
            self.arrayVisiblePins = arra.sorted{ $0.createdAt!.seconds > $1.createdAt!.seconds}
            self.collectionView.reloadData()
    }

    @objc func goToNewEntry() {

        performSegue(withIdentifier: "NewVideoPost", sender: self)
        
    }
    @objc func goToShowEntry() {
        showHideConteinerView()
//        selectedElement! - на новом элементе почему-то нил !!!!!!!!!!!!!!!!!!!
        let selElement = (selectedElement != nil) ? selectedElement! : 0
        delegate?.reciviedData(data: arrayVisiblePins, currentState: selElement)

    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewVideoPost" {
            LocationService.instance.stopUpdatingLocation()
            let secondVC = segue.destination as? NewVideoEntryViewController
            secondVC?.geopoint = geopoint

        }
    }
    
    
    func createPinOnMap(_ location: CLLocation) {
        let title = "Do you have anything to write about?".localized
        let new = PinsVideoPost(user: currentUser!, imageProfileStringUrl: nil, titleCategory: "New element".localized, lat: location.coordinate.latitude, long: location.coordinate.longitude, new: true, description: title, documentID_Post: nil, videoURL: nil, videoThumbnailURL: nil, sexUser: nil, limitAge: false, created: Date())
        mapView.addAnnotation(new)
        // select annotation
        mapView.selectAnnotation(new, animated: true)
        locationManager.stopUpdatingLocation()
        
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func performSearch() {
        matchingItems.removeAll()
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start(completionHandler: {(response, error) in
            guard error == nil else { return }
            
            switch response!.mapItems.count {
            case 0:
                print("No matches found")
            default:
                for item in response!.mapItems {
                    self.matchingItems.append(item as MKMapItem)
                    let location = CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                    self.centerMapOnLocation(location: location)
                }
            }
        })
    }
    
    // MARK:  Location (End)
}

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayVisiblePins.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BottomCollectionViewCell
        cell.image.image = self.arrayVisiblePins[indexPath.row].user.profilePic
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showHideConteinerView()
        delegate?.reciviedData(data: arrayVisiblePins, currentState: indexPath.row)
    }
    
    
    
    
    func sortirovka(pinArray: Set<AnyHashable>, completion: @escaping([PinsVideoPost])->()) {
        print("how much")
        let arra = Array(pinArray)
        let arrr = arra as! Array<PinsVideoPost>
        _ = arrr.sorted{(($0.createdAt?.dateValue()))! > ($1.createdAt?.dateValue())!}
        completion(arrr)

    }
}

extension MapViewController {
    @objc func showHideConteinerView() {
        if containerController == nil {
            containerController = EmbedContainerController(rootViewController: self)
            addChildViewControllers()
        } else {
            containerController = nil
            print("\nChildViewControllers removed")
            printChildViewControllesInfo()
        }
    }
    
    func addChildViewControllers() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "pagerView") as! ActivityStreamViewController
        if let _ = newViewController.view {
            newViewController.view.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height) //self.view.frame
            newViewController.view.backgroundColor = UIColor.clear
            
            containerController?.append(viewController: newViewController)
            print("\nChildViewControllers added")
            printChildViewControllesInfo()
        }
       // let newViewController = ActivityStreamViewController() // SecondViewController

    }
    
    func printChildViewControllesInfo() {
        print("view.subviews.count: \(view.subviews.count)")
        print("childViewControllers.count: \(childViewControllers.count)")
    }

}



