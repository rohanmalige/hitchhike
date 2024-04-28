//
//  FirestoreManager.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager: ObservableObject {
    var db: Firestore
    
    init() {
//        let providerFactory = AppCheckDebugProviderFactory()
//        AppCheck.setAppCheckProviderFactory(providerFactory)
//
//        FirebaseApp.configure()
        db = Firestore.firestore()
    }
    
    
    func createPost(user: User, from: String, to: String, pickupDate: Timestamp, desiredSplit: Double, maxPassengers: Int, message: String) {
        let postRef = db.collection("posts").document()
        let newPost = Post(id: postRef.documentID, userID: user.uid, from: from, to: to, pickupDate: pickupDate, desiredSplit: desiredSplit, maxPassengers: maxPassengers, message: message)
        postRef.setData(newPost.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Post added with ID: \(String(describing: newPost.id))")
            }
        }
    }
    
    func createRequest(user: appUser, from: String, to: String, pickupDate: Date, desiredSplit: Double, message: String) {
        let requestRef = db.collection("requests").document()
        let newRequest = Request(id: requestRef.documentID, userID: user.id, from: from, to: to, pickupDate: pickupDate, desiredSplit: desiredSplit, message: message)
        requestRef.setData(newRequest.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Request added with ID: \(String(describing: newRequest.id))")
            }
        }
    }

    func fetchPosts(completion: @escaping ([Post]?, Error?) -> Void) {
        let postDocument = db.collection("posts")
        
        postDocument.getDocuments { querySnapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let querySnapshot = querySnapshot else {
                completion(nil, nil)
                return
            }
            
            var posts: [Post] = []
            for document in querySnapshot.documents {
                let postData = document.data()
                print(postData["from"])
                   if let id = postData["id"] as? String,
                   let userID = postData["userID"] as? String,
                   let from = postData["from"] as? String,
                   let to = postData["to"] as? String,
                   let pickupDate = postData["pickupDate"] as? Timestamp,
                   let desiredSplit = postData["desiredSplit"] as? Double,
                   let maxPassengers = postData["maxPassengers"] as? Int,
                   let message = postData["message"] as? String {
                       print("id \(id)")
                       print("userID \(userID)")
                       print("from \(from)")
                       print("to \(to)")
                       print("pickupDate \(pickupDate)")
                       print("desiredSplit \(desiredSplit)")
                       print("maxPassengers \(maxPassengers)")
                       print("message \(message)")
                    let post = Post(id: id,
                                    userID: userID,
                                    from: from,
                                    to: to,
                                    pickupDate: pickupDate,
                                    desiredSplit: desiredSplit,
                                    maxPassengers: maxPassengers,
                                    message: message)
                    posts.append(post)
                }
//                else {
//                    let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
//                    completion(nil, dataError)
//                }
            }
            completion(posts, nil)
        }
    }
    
    func fetchPost(id: String, completion: @escaping (Post?, Error?) -> Void) {
        let postDocument = db.collection("posts").document(id)
        
        postDocument.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }
            
            if let postData = document.data(),
               let userID = postData["userID"] as? String,
               let from = postData["from"] as? String,
               let to = postData["to"] as? String,
               let pickupDate = postData["pickupDate"] as? Timestamp,
               let desiredSplit = postData["desiredSplit"] as? Double,
               let maxPassengers = postData["maxPassengers"] as? Int,
               let message = postData["message"] as? String {
                let post = Post(id: id,
                                userID: userID,
                                from: from,
                                to: to,
                                pickupDate: pickupDate,
                                desiredSplit: desiredSplit,
                                maxPassengers: maxPassengers,
                                message: message
                )
                completion(post, nil)
                }
//                else {
//                    let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
//                    completion(nil, dataError)
//                }
        }
    }
    
    func fetchRequests(id: String, completion: @escaping (Request?, Error?) -> Void) {
        let requestDocument = db.collection("requests").document(id)
        
        requestDocument.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = document, document.exists else {
                completion(nil, nil)
                return
            }
            
            if let requestData = document.data(),
               let id = requestData["id"] as? String,
               let userID = requestData["userID"] as? String,
               let from = requestData["from"] as? String,
               let to = requestData["to"] as? String,
               let pickupDate = requestData["pickupDate"] as? Date,
               let desiredSplit = requestData["desiredSplit"] as? Double,
               let message = requestData["message"] as? String {
                let request = Request(id: id,
                                      userID: userID,
                                      from: from,
                                      to: to,
                                      pickupDate: pickupDate,
                                      desiredSplit: desiredSplit,
                                      message: message)
                completion(request, nil)
            } else {
                let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: nil)
                completion(nil, dataError)
            }
        }
    }
}
