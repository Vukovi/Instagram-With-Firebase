//
//  ViewController.swift
//  instagramFirebase
//
//  Created by Vuk on 4/16/17.
//  Copyright © 2017 Vuk. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
//import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeedVC", sender: nil)
        }
    }


    @IBAction func facebookBtnTapped(_ sender: UIButton) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("VUČE: ne može se ulogovati Facebookom - \(error.debugDescription)")
            } else if result?.isCancelled == true {
                print("VUČE: korisnik je otkazao logovanje Facebookom")
            } else {
                print("VUČE: uspešno logovanje Facebookom")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("VUČE: ne može se ulogovati Firebaseom - \(error.debugDescription)")
            } else {
                print("VUČE: uspešno logovanje Firebaseom")
                if let user = user {
                    let userData = ["provider": credential.provider] //ovo je sa credential da bi pravio razliku izmedju registrovanja facebookom i firebaseom
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
            }
        })
    }

    @IBAction func signInTapped(_ sender: UIButton) { //dve funkcije ima dugme - registrobvanje i logovanje
        if let email = emailField.text, let password = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil { //ovo je logovanje
                    print("VUČE: uspešno logovanje emailom pomoću Firebasea")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("VUČE: ne može se ulogovati emailom pomoću Firebasea - \(error.debugDescription)")
                        } else { // ovo je registrovanje
                            print("VUČE: uspešno kreiran korisnik")
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.dataServiceSingleton.createFirebaseDBUser(uid: id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "goToFeedVC", sender: nil)
    }
}

