//
//  Extensions.swift
//  Wylsacom Channel
//
//  Created by AlekseyLarichev on 25.04.2018.
//  Copyright © 2018 AlekseyLarichev. All rights reserved.
//

import Foundation
import UIKit




extension Int {
    func toString() -> String {
        return String(self)
    }
}
// Новый элемент с заданной емкостью
extension Array {
    mutating func appendWithCapacity(_ value: Element, capacity: Int) {
        self.append(value)
        if self.count > capacity {
            self.remove(at: 0)
        }
    }
}

extension UIViewController {
    func createBorderForView(view: UIView, color: UIColor, radius: CGFloat, width: CGFloat, alphaAnimated: CGFloat, duration: CGFloat) {
        view.alpha = alphaAnimated
        UIView.animate(withDuration: TimeInterval(duration)) {
            view.layer.borderWidth = width
            view.layer.cornerRadius = radius
            view.layer.shouldRasterize = false
            view.layer.rasterizationScale = 2
            view.clipsToBounds = true
            view.layer.masksToBounds = true
            let cgColor: CGColor = color.cgColor
            view.layer.borderColor = cgColor
            view.alpha = 1
        }
    }
}

extension UIViewController {
    func shakeView(shakeView: UIView) {
        UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x -= 3 }, completion: { _ in
            UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x += 6 }, completion: { _ in
                UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x -= 3 }, completion: { _ in
                    UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x += 6 }, completion: { _ in
                        UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x -= 3 }, completion: { _ in
                            UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x += 6 }, completion: { _ in
                                UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x -= 3 }, completion: { _ in
                                    UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x += 6 }, completion: { _ in
                                        UIView.animate(withDuration: 0.03, animations: { shakeView.frame.origin.x -= 6 })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
}

// Border only left right bottom top
extension UIView {
    func borders(for edges:[UIRectEdge], width:CGFloat = 1, color: UIColor = .black) {
        
        if edges.contains(.all) {
            layer.borderWidth = width
            layer.borderColor = color.cgColor
        } else {
            let allSpecificBorders:[UIRectEdge] = [.top, .bottom, .left, .right]
            
            for edge in allSpecificBorders {
                if let v = viewWithTag(Int(edge.rawValue)) {
                    v.removeFromSuperview()
                }
                
                if edges.contains(edge) {
                    let v = UIView()
                    v.tag = Int(edge.rawValue)
                    v.backgroundColor = color
                    v.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(v)
                    
                    var horizontalVisualFormat = "H:"
                    var verticalVisualFormat = "V:"
                    
                    switch edge {
                    case UIRectEdge.bottom:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "[v(\(width))]-(0)-|"
                    case UIRectEdge.top:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v(\(width))]"
                    case UIRectEdge.left:
                        horizontalVisualFormat += "|-(0)-[v(\(width))]"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    case UIRectEdge.right:
                        horizontalVisualFormat += "[v(\(width))]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    default:
                        break
                    }
                    
                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": v]))
                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": v]))
                }
            }
        }
    }
}
// Split two image (pin)
extension UIViewController {
    func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage {
        
        let newImageWidth  = max(firstImage.size.width,  secondImage.size.width )
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)
        
        
        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        let firstImageDrawX  = round((newImageSize.width  - firstImage.size.width  ) / 2)
        let firstImageDrawY  = CGFloat(4) //round((newImageSize.height - firstImage.size.height ) / 2) - 15
        
        let secondImageDrawX = round((newImageSize.width  - secondImage.size.width ) / 2)
        let secondImageDrawY = round((newImageSize.height - secondImage.size.height) / 2)
        
        firstImage.draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return image!
    }
}

// Сжатие картинки
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
}

// вписать одну картинку в другую
extension UIImage {
    func overlayWith(image: UIImage, posX: CGFloat, posY: CGFloat) -> UIImage {
        let newWidth = size.width < posX + image.size.width ? posX + image.size.width : size.width
        let newHeight = size.height < posY + image.size.height ? posY + image.size.height : size.height
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        image.draw(in: CGRect(origin: CGPoint(x: posX, y: posY), size: image.size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

// Create Circle Image with border
extension UIViewController {
    func circularImageWithImage(inputImage: UIImage?, borderColor: UIColor?, borderWidth: CGFloat, frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, (inputImage?.scale)!)
        do {
            // Fill the entire circle with the border color.
            borderColor?.setFill()
            UIBezierPath(ovalIn: frame).fill()
            // Clip to the interior of the circle (inside the border).
            let interiorBox: CGRect = frame.insetBy(dx: borderWidth, dy: borderWidth)
            let interior = UIBezierPath(ovalIn: interiorBox)
            interior.addClip()
            inputImage?.draw(in: frame)
        }
        let outputImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
}


// Random String For Load File to Firebase Strorage
extension NSObject {
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}

// Delay Run
public func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}


// Для Локализации
extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    // Example use: "String".localized
}


extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(Int(round(million*10)/10)) млн."
        }
        else if thousand >= 1.0 {
            return "\(Int(round(thousand*10)/10)) тыс."
        }
        else {
            return "\(Int(number))"
        }
    }
}

extension Date {
    func getElapsedInterval() -> String {
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: Bundle.main.preferredLocalizations[0]) //--> IF THE USER HAVE THE PHONE IN SPANISH BUT YOUR APP ONLY SUPPORTS I.E. ENGLISH AND GERMAN WE SHOULD CHANGE THE LOCALE OF THE FORMATTER TO THE PREFERRED ONE (IS THE LOCALE THAT THE USER IS SEEING THE APP), IF NOT, THIS ELAPSED TIME IS GOING TO APPEAR IN SPANISH
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.calendar = calendar
        var ago = " назад"
        var dateString: String?
        
        let interval = calendar.dateComponents([.year, .month, .weekOfYear, .day], from: self, to: Date())
        
        if let year = interval.year, year > 0 {
            formatter.allowedUnits = [.year] //2 years
        } else if let month = interval.month, month > 0 {
            formatter.allowedUnits = [.month] //1 month
        } else if let week = interval.weekOfYear, week > 0 {
            formatter.allowedUnits = [.weekOfMonth] //3 weeks
        } else if let day = interval.day, day > 0 {
            formatter.allowedUnits = [.day] // 6 days
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Bundle.main.preferredLocalizations[0]) //--> IF THE USER HAVE THE PHONE IN SPANISH BUT YOUR APP ONLY SUPPORTS I.E. ENGLISH AND GERMAN WE SHOULD CHANGE THE LOCALE OF THE FORMATTER TO THE PREFERRED ONE (IS THE LOCALE THAT THE USER IS SEEING THE APP), IF NOT, THIS ELAPSED TIME IS GOING TO APPEAR IN SPANISH
            dateFormatter.dateStyle = .medium
            dateFormatter.doesRelativeDateFormatting = true
            
            dateString = dateFormatter.string(from: self) // IS GOING TO SHOW 'TODAY'
            ago = ""

        }
        
        if dateString == nil {
            dateString = formatter.string(from: self, to: Date())! + ago
        }
        
        return dateString!
}
}
extension String {
    func date() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone.current
        let date = dateFormatter.date(from: self)
        return date
    }
}

//extension String {
//    func deleteHTMLTag(tag:String) -> String {
//        return self.replacingOccurrences(of: "(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression, range: nil)
//    }
//    
//    func deleteHTMLTags(tags:[String]) -> String {
//        var mutableString = self
//        for tag in tags {
//            mutableString = mutableString.deleteHTMLTag(tag: tag)
//        }
//        return mutableString
//    }
//}




extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}


extension UIViewController {
    func showAlertController(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)

    }
}
extension UIViewController {
    func showActivityIndicator(text: String?) {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.backgroundColor = UIColor.lightGray
        activityIndicator.layer.cornerRadius = 6
        activityIndicator.center = CGPoint(x: view.center.x, y: view.center.y - 50)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.startAnimating()
//        if text != nil {
//            let label = UILabel()
//        label.text = text
//        label.textAlignment = .center
//        label.tag = 101
//            label.backgroundColor = UIColor.clear
//        label.textColor = .white
//        //label.sizeToFit()
//            label.frame.size = CGSize(width: 100, height: 50)
//        label.frame.origin = CGPoint(x: activityIndicator.frame.width/2 - label.frame.width/2, y: activityIndicator.frame.height*0.6)
//        activityIndicator.addSubview(label)
//        UIApplication.shared.beginIgnoringInteractionEvents()
//        }
        activityIndicator.tag = 100 // 100 for example
        
        // before adding it, you need to check if it is already has been added:
        for subview in view.subviews {
            if subview.tag == 100 {
                let labels = subview.subviews.compactMap {$0 as? UILabel }
                for label in labels {
                    label.text = text
                }
                return
            }
        }
//        activityIndicator.addSubview(label)
        view.addSubview(activityIndicator)
    }
    
    func hideActivityIndicator() {
        let activityIndicator = view.viewWithTag(100) as? UIActivityIndicatorView
        activityIndicator?.stopAnimating()
        
        // I think you forgot to remove it?
        activityIndicator?.removeFromSuperview()
        
        //UIApplication.shared.endIgnoringInteractionEvents()
    }
}
extension UIImageView {
    fileprivate var activityIndicator: UIActivityIndicatorView {
        get {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.center = CGPoint(x:self.frame.width/2,
                                               y: self.frame.height/2)
            activityIndicator.stopAnimating()
            self.addSubview(activityIndicator)
            return activityIndicator
        }
    }
}


extension UIViewController {
    func showVC(text: String?, width: CGFloat) {
        let customView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 40, width: width, height: 40))
        customView.backgroundColor = UIColor.lightGray
        let label = UILabel()
        label.text = text
        label.backgroundColor = UIColor.clear
        label.sizeToFit()
        label.frame.origin = CGPoint(x: UIScreen.main.bounds.width / 2 - label.frame.width / 2, y: customView.frame.height / 2 - label.frame.height / 2)

        customView.addSubview(label)
        customView.tag = 100 // 100 for example
        
        // before adding it, you need to check if it is already has been added:
        for subview in view.subviews {
            if subview.tag == 100 {
                subview.frame.size.width = width
                return
            }
        }
        view.addSubview(customView)
    }
    
    func hideVC() {
        let customView = view.viewWithTag(100) as? UIView
        for subview in view.subviews {
            if subview.tag == 100 {
                if subview == customView {
                    subview.isHidden = true
                }
//                subview.removeFromSuperview()
                return
            }
        }
//        let customView = view.viewWithTag(100) as? UIView
//        // I think you forgot to remove it?
//        customView?.removeFromSuperview()
        
    }
}
