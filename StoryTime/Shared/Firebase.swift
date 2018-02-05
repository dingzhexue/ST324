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
    var REF_RESULTS = Database.database().reference().child("results")
    var REF_USERS = Database.database().reference().child("users")
    static var STORAGE_ROOF_REF = "gs://storytime-app.appspot.com"
    
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
    
    var CURRENT_USER: User? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser
        }
        
        return nil
    }
    
    func currentUserId() -> String{
        guard let currentUser = Auth.auth().currentUser else {
            return ""
        }
        return currentUser.uid
    }
    
    func observeCurrentUser(completion: @escaping (DataSnapshot) -> Void){
        REF_USERS.child(currentUserId()).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            completion(snapshot)
        })
    }
    
    func saveUserProfile(imgUrl:String, onSucess: @escaping() -> Void, onError:  @escaping (_ errorMessage: String?) -> Void){
        let dict = ["profileImage": imgUrl]
        REF_USERS.child(currentUserId()).updateChildValues(dict) { (error, ref) in
            if(error != nil){
                onError(error?.localizedDescription)
            }else{
                onSucess()
            }
        }
    }
    
    func uploadImage(imageData: Data, onSuccess: @escaping(_ imageUrl:String) -> Void, onError: @escaping (_ errorMessage: String?)->Void){
        let uid = currentUserId()
        storageRef.child("users").child(uid).putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil{
                onError(error?.localizedDescription)
                return
            }
            
            if let profileImageUrl = metadata?.downloadURL()?.absoluteString{
                onSuccess(profileImageUrl)
            }else{
                onError("Can't get image URL")
            }
        }
    }
    func observeResult(id:String, level: Int, story: String, completion: @escaping (DataSnapshot) -> Void){
        REF_RESULTS.child(id + "/\(level)/" + story).observeSingleEvent(of: DataEventType.value, with: {
            snapshot in
            completion(snapshot)
        })
    }
    
    func postResult(id:String, level: Int, story: String, wrongCount: Int, time: Int, onSuccess: @escaping () -> Void){
        let ref = REF_RESULTS.child(id + "/\(level)/" + story)
        ref.setValue(["wrongcount" : wrongCount, "time": time])
        onSuccess()
    }
}

// MARK: Storage
extension Firebase {
    func download(_ childPath: String, completionHandler: @escaping (_ data: Data?) -> Swift.Void) {
        storageRef.child(childPath).getData(maxSize: maxDownloadFileSize) { (data, error) in
            if let error = error {
                print("Firebase download \(childPath) failed \(error.localizedDescription)")
                completionHandler(nil)
            } else {
                completionHandler(data)
            }
        }
    }
}

