//
//  Firebase.swift
//  StoryTime
//
//  Created by Administrator on 12/15/17.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class Firebase {
    let maxDownloadFileSize: Int64 = 100 * 1024 * 1024
    
    private init() { }
    
    static let shared = Firebase()
    
    let dbRef = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously { (user, error) in
            if let error = error {
                print("Firebase sign in annonymously failed: \(error.localizedDescription)")
            } else {
                print("Firebase signed in annonymously successfully")
            }
        }
    }
    
    func signInWithEmail(_ email: String!, _ password: String!) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Firebase sign in with email failed: \(error.localizedDescription)")
            } else if let user = user, let email = user.email {
                print("Firebase signed in with \(email)")
            }
        }
    }
}

// MARK: Database
extension Firebase {
    func read(_ childPath: String!, _ completionHandler: @escaping (_ snapshot: DataSnapshot) -> Swift.Void) {
        dbRef.child(childPath).observeSingleEvent(of: .value) { (snapshot) in
            completionHandler(snapshot)
        }
    }
}

// MARK: Storage
extension Firebase {
    func download(_ childPath: String, completionHandler: @escaping (_ data: Data?) -> Swift.Void) {
        storageRef.child(childPath).getData(maxSize: maxDownloadFileSize) { (data, error) in
            if let error = error {
                print("Firebase download \(childPath) failed \(error.localizedDescription)")
            } else {
                completionHandler(data)
            }
        }
    }
}
