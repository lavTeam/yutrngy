//
//  PinsVideoPost.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 04.07.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import SDWebImage

class PinsVideoPost: NSObject, MKAnnotation {
    var user: MyUser
    var imageProfileStringUrl: String?
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var isNew: Bool
    var descriptionPost: String?
    var category: Category?
    var documentID: String?
    var videoStringUrl: String?
    var videoThumbnailStringUrl: String?
    
    var sex: Sex?
    var ageLimit: Bool?
    var createdAt: Timestamp?

    init(user: MyUser,imageProfileStringUrl: String?, titleCategory:String?, lat:CLLocationDegrees,long:CLLocationDegrees, new:Bool, description: String?, documentID_Post: String?, videoURL: String?, videoThumbnailURL: String?, sexUser: Sex?, limitAge: Bool, created: Date){
        self.user = user
        self.imageProfileStringUrl = imageProfileStringUrl
        title = titleCategory
        category = Category(rawValue: titleCategory!)
        coordinate = CLLocationCoordinate2DMake(lat, long)
        isNew = new
        descriptionPost = description
        documentID = documentID_Post
        
        videoStringUrl = videoURL
        videoThumbnailStringUrl = videoThumbnailURL
        sex = sexUser
        ageLimit = limitAge
        createdAt = Timestamp(date: created)
    }
}
