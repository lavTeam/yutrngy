//
//  Post.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 02.07.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import Foundation
import Firebase
import Bolts
import FirebaseFirestore
import FirebaseAuth
import MapKit
import CodableFirebase
import GeoFire

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}

struct Post: Codable {
    var userid: String
    var category: Category
    var videoStringUrl: String
    var videoThumbnailStringUrl: String
    var descriptionPost: String
    var sex: Sex?
    var ageLimit: Bool?
    var l: Array<Double>
    let g: String
    var createdAt: Date
    var isPublished: Bool
    var documentID: String?
    var user: MyUser?
    
    init(userID: String,
         category: Category,
         videoStringUrl: String,
         videoThumbnailStringUrl: String,
         descriptionPost: String,
         sex: Sex?,
         ageLimit: Bool,
         l: Array<Double>,
         g: String, createdAt: Date,
         isPublished: Bool,
         documentID: String?,
         user: MyUser?) {
        self.userid = userID
        self.category = Category(rawValue: category.rawValue)!
        self.videoStringUrl = videoStringUrl
        self.videoThumbnailStringUrl = videoThumbnailStringUrl
        self.descriptionPost = descriptionPost
        self.sex = sex
        self.ageLimit = ageLimit
        self.l = l
        self.g = g
        self.createdAt = createdAt
        self.isPublished = isPublished
        self.documentID = documentID
        self.user = user
    }
    
    enum CodingKeys: String, Swift.CodingKey {
        case userid
        case category
        case videoStringUrl
        case videoThumbnailStringUrl
        case descriptionPost
        case sex
        case ageLimit
        case l
        case g
        case createdAt
        case isPublished
        case documentID
    }
}


