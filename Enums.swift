//
//  Enums.swift
//  WeKnow
//
//  Created by Aleksey Larichev on 18.06.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//
import Foundation


public protocol EnumCollection: Hashable {
    static func cases() -> AnySequence<Self>
    static var allValues: [Self] { get }
}

public extension EnumCollection {
    
    public static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }
    
    public static var allValues: [Self] {
        return Array(self.cases())
    }
}



enum Category: String, EnumCollection, Codable {
    case Eat = "Food & drink"
    case Job = "Education & Work"
    case Cafe = "Cafe"
    case Beatiful = "Beauty & Fashion"
    case Other = "Other"
    case Sport = "Sport"
    case Family = "Family"
    case Kids = "Kids"
    case Religion = "Religion"
    case Shopping = "Shopping"
    case LiteratureArt = "Literature & Art"
    case Tehnics = "Tehnics"
    case Politics = "Politics"
    case Travels = "Travels"
    case MoviesMusic = "Movies & music"
    
    
    var localizedDescription: String {
        switch self {
        case .Eat:
            return "Food & drink".localized
        case .Job:
            return "Education & Work".localized
        case .Cafe:
            return "Cafe".localized
        case .Beatiful:
            return "Beauty & Fashion".localized
        case .Other:
            return "Other".localized
        case .Sport:
            return "Sport".localized
        case .Family:
            return "Family".localized
        case .Kids:
            return "Kids".localized
        case .Religion:
            return "Religion".localized
        case .Shopping:
            return "Shopping".localized
        case .LiteratureArt:
            return  "Literature & Art".localized
        case .Tehnics:
            return "Tehnics".localized
        case .Politics:
            return "Politics".localized
        case .Travels:
            return "Travels".localized
        case .MoviesMusic:
            return "Movies & Music".localized
        }
    }
}

enum Sex : String, EnumCollection, Codable {
    case Male = "Male"
    case Female = "Female"
    case Other = "Other"
    
    var localizedDescription: String {
        switch self {
        case .Male:
            return "Male".localized
        case .Female:
            return "Female".localized
        case .Other:
            return "Other".localized
        }
    }
}

enum Adulthood : String, EnumCollection, Codable {
    case Yes = "Yes"
    case No = "No"

    
    var localizedDescription: String {
        switch self {
        case .Yes:
            return "Yes".localized
        case .No:
            return "No".localized
        }
    }
}
enum Marital: String, EnumCollection, Codable {
    case Marital = "<< Marital >>"
    case Married = "Married"
    case Single = "Single"
    case Widowed = "Widowed"
    case Devorced = "Devorced"
    case Other = "Other"

    var localizedDescription: String {
        switch self {
        case .Marital:
            return "<< Marital >>".localized
        case .Married:
            return "Married".localized
        case .Other:
            return "Other".localized
        case .Single:
            return "Single".localized
        case .Widowed:
            return "Widowed".localized
        case .Devorced:
            return "Devorced".localized
        }
    }
}

enum Educational: String {
    case Elementary = "Elementary school"
    case Middle = "Middle school"
    case High = "High school"
    case Other = "Other"
    var localizedDescription: String {
        
        switch self {
        case .Elementary:
            return NSLocalizedString("Elementary", comment: "")
        case .Middle:
            return NSLocalizedString("Middle", comment: "")
        case .High:
            return NSLocalizedString("High", comment: "")
        case .Other:
            return NSLocalizedString("Other", comment: "")
        }
    }
}
enum UserType: String, EnumCollection, Codable {
    case Basic = "Basic"
    case Gold =  "Gold"
    case Premium = "Premium"
    
    var localizedDescription: String {
        switch self {
        case .Basic:
            return "Basic".localized
        case .Gold:
            return "Gold".localized
        case .Premium:
            return "Premium".localized
        }
    }
}
enum TypeImage {
    case VideoPreview, Profile, Photo
}


// For Comment
enum PhotoSource {
    case library
    case camera
}

enum ShowExtraView {
    case contacts
    case profile
    case preview
    case map
}

enum MessageType {
    case photo
    case text
}

enum MessageOwner {
    case sender
    case receiver
}
