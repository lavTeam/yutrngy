//
//  MyUser.swift
//  dmaker
//
//  Created by Aleksey Larichev on 30.05.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//
import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

var currentUser: MyUser?

struct MyUser: Codable {
    var username: String = ""
    var phoneNumber: String?
    var sex: String?
    var age: Double?
    var adulthood: Bool?
    var rating: Double?
    var balance: Double?
    var birthday: Date?
    var maritalStatus: String?
    var educational: String?
    var children: String?
    var imageProfileURL: String?
    var userType: UserType
    var profilePic: UIImage?
    
    enum CodingKeys: String, CodingKey {
        // include only those that you want to decode/encode
        case username
        case phoneNumber
        case sex
        case age
        case adulthood
        case rating
        case balance
        case birthday
        case maritalStatus
        case educational
        case children
        case imageProfileURL
        case userType
//        case profilePic
    }
    
    
    init(username: String,
        phoneNumber: String?,
        sex: String?,
        age: Double?,
        adulthood: Bool?,
        rating: Double?,
        balance: Double?,
        birthday: Date?,
        maritalStatus: String?,
        educational: String?,
        children: String?,
        imageProfileURL: String?,
        userType: UserType,
        profilePic: UIImage?) {
        self.username = username
        self.phoneNumber = phoneNumber
        self.sex = sex
        self.age = age
        self.adulthood = adulthood
        self.rating = rating
        self.balance = balance
        self.birthday = birthday
        self.maritalStatus = maritalStatus
        self.educational = educational
        self.children = children
        self.imageProfileURL = imageProfileURL
        self.userType = userType
        self.profilePic = profilePic
    }
}

extension MyUser: Equatable {
    static func ==(lhs: MyUser, rhs: MyUser) -> Bool {
        return lhs.username == rhs.username &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.sex  == rhs.sex &&
        lhs.age == rhs.age &&
        lhs.adulthood == rhs.adulthood &&
        lhs.rating == rhs.rating &&
        lhs.balance == rhs.balance &&
        lhs.birthday == rhs.birthday &&
        lhs.maritalStatus == rhs.maritalStatus &&
        lhs.educational == rhs.educational &&
        lhs.children == rhs.children &&
        lhs.imageProfileURL == rhs.imageProfileURL &&
        lhs.userType == rhs.userType &&
        lhs.profilePic == rhs.profilePic

    }
}


