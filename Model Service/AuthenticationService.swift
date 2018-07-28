//
//  NetworkService.swift
//  decisionmaker
//
//  Created by Aleksey Larichev on 30.05.2018.
//  Copyright © 2018 Aleksey Larichev. All rights reserved.
//

import Firebase
import FirebaseUI

class AuthenticationService: UIViewController {
    static let instance = AuthenticationService()
    var docRef: DocumentReference!
    let userUid = Auth.auth().currentUser?.uid
    
    func authWithPhone(view: UIViewController, phoneNumber: String?, complete: @escaping (Bool) -> ()) {
        // регистрация
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                complete(false)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            complete(true)
        }
    }
    
    func confirmWithCodeVerification(verificationCode: String, complete: @escaping (Bool) -> ()) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID!, verificationCode: verificationCode)
        Auth.auth().signInAndRetrieveData(with: credential) { (authData, error) in
            if let error = error {
                print(error.localizedDescription)
                complete(false)
                return
            }
            //ссылку на аватарку по умолчанию вставить
            let newUser = MyUser(username: "", phoneNumber: authData!.user.phoneNumber!, sex: "Other", age: nil, adulthood: false, rating: nil, balance: nil, birthday: nil, maritalStatus: nil, educational: nil, children: nil, imageProfileURL: "https://firebasestorage.googleapis.com/v0/b/imaker-aebad.appspot.com/o/default_male600x600-79218392a28f78af249216e097aaf683.png?alt=media&token=add519a2-41f8-4af7-81da-83569fa4dc02", userType: .Basic, profilePic: nil)
            
            Database.database().reference().child("users").child(authData!.user.uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if snapshot.exists() {
                    guard let data = snapshot.value as? [String:Any] else {return}
                    print(data)
                    complete(true)
                    
                } else {
                    let key = Database.database().reference().child("users").child(authData!.user.uid).key
                    let data = try! JSONEncoder().encode(newUser)
                    let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                    let childUpdates = ["/users/\(key)": dictionary]
                    Database.database().reference().updateChildValues(childUpdates)
                    print("пусто")
                    complete(true)
                }
            })
        }
    }
}
