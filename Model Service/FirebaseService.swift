//
//  FirebaseService.swift
//  dmaker
//
//  Created by Aleksey Larichev on 13.06.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import Foundation
import Firebase
//import FirebaseAuth
import FirebaseStorage
//import CodableFirebase
import GeoFire
import Geofirestore
import MapKit




//var db = Firestore.firestore()

class  FirebaseService: NSObject {
    let refFirebase = Database.database().reference()

    static let instance = FirebaseService()
    let storageRef = Storage.storage().reference()

    
    /// Realtine Create Post
    func createVideoPostFireBase(postType: Post, completion: @escaping(String) -> ()) {
        let key = refFirebase.child("post").childByAutoId().key
        var newPost = postType
        newPost.documentID = key
        let data = try! JSONEncoder().encode(newPost)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        let childUpdates = ["/post/\(key)": dictionary]//, "/user-posts/userID/\(key)/": post]
        refFirebase.updateChildValues(childUpdates)
    }
    
    /// Realtime Get Post
    func getVideoPostFireBase(completion: @escaping([Post]) ->()) {
        var array = [Post]()
        let jsonDecoder = JSONDecoder()
        refFirebase.child("post").queryOrdered(byChild: "createdAt").observe(.childAdded) { (snapshot) in
            guard snapshot.exists(), let datas = snapshot.value as? [String:Any] else {return}
            print(datas)
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: datas, options: [])
                var posts = try jsonDecoder.decode(Post.self, from: jsonData)
                
                self.getUserByIDFirebase(userID: posts.userid, completion: { (user) in
                    posts.user = user
                    array.append(posts)
                    
                    print("время: ", posts.createdAt, "id: ", posts.documentID)
                    completion(array)

                })
            } catch {
                print(error)
            }
//            completion(array)
            
        }
    
    }
    
    /// RealTime Get Image
    func getUserByIDFirebase(userID: String, completion: @escaping(MyUser) -> ()) {
        refFirebase.child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists(), let data = snapshot.value {
                do {
                    let jsonDecoder = JSONDecoder()
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                var user = try jsonDecoder.decode(MyUser.self, from: jsonData)
                    let urlProfilePicture = URL(string: user.imageProfileURL!)
                    print(urlProfilePicture)
                    URLSession.shared.dataTask(with: urlProfilePicture!, completionHandler: { (data, response, error) in
                        if error == nil {
                            let profilePicture = UIImage.init(data: data!)
                            user.profilePic = profilePicture
                            print(user)
                            completion(user)
                        } else {
                            print(error?.localizedDescription)
                        }
                    }).resume()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func updateUserInfo(user: MyUser) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        
        let data = try! JSONEncoder().encode(user)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        let childUpdates = ["/users/\(id)": dictionary]
        refFirebase.updateChildValues(childUpdates)
    
    }

    // Get Documents
    func getVideoPostsWithLocation(location: CLLocation, completion: @escaping([Post]) ->()) {
        let geofireRef = Database.database().reference().child("post")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let query = geoFire.query(at: CLLocation(latitude: 55.761704, longitude: 37.609407), withRadius: 3)
        query.observe(GFEventType.keyMoved) { (key, location, snapshot) in
            print(snapshot.value)
        }
        query.observe(.keyEntered) { (key, location, snapshot) in
            print(snapshot.value)
        }

    }
    
    // Upload file
    func uploadVideo(videoURL: URL) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let dateString = dateFormatter.string(from: date)
        let randomFileName = dateString + randomString(length: 8)
        let mountainImagesRef = storageRef.child("\(id)/\(randomFileName).mov")
        
        let uploadTask = mountainImagesRef.putFile(from: videoURL, metadata: nil) { (meta, error) in
            guard error == nil else { print(error!); return }
        }
        
        uploadTask.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        uploadTask.observe(.pause) { snapshot in
            // Upload paused
        }
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadVideoCheck"), object: nil, userInfo: ["result": percentComplete, "url": nil])
        }
        
        uploadTask.observe(.success) { snapshot in
            print("готово")
            mountainImagesRef.downloadURL(completion: { (url, error) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "UploadVideoCheck"), object: nil, userInfo: ["result": Double(100), "url": url!])
            })
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as NSError? {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
    func uploadImage(image: UIImage, typeImage: TypeImage, completion: @escaping(StorageReference?,URL?) -> ()) {
        guard let id = Auth.auth().currentUser?.uid else { return }
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm"
        let dateString = dateFormatter.string(from: date)
        let mountainImagesRef = storageRef.child("\(typeImage)/\(id)/\(dateString).png")
        mountainImagesRef.putData(imageData!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!)
                completion(nil, nil)
            } else {
                mountainImagesRef.downloadURL(completion: { (url, error) in
                    guard let url = url else { return completion(nil, nil) }
                    completion(mountainImagesRef, url)
                })
            }
        }
    }
    
    func removeImage(imagesRef: StorageReference, completion: @escaping(Bool)->()) {
        imagesRef.delete { (error) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
