//
//  FirestoreManager.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import Foundation
import Firebase
import FirebaseFirestore
import StoreKit
import FirebaseFirestoreSwift
import MapKit

class FirestoreManager: ObservableObject {
    var db: Firestore
    @Published var messages: [Messages]? {
        didSet {
            print("Messages array updated:", messages ?? "nil")
                        
            self.objectWillChange.send()
        }
    }
    
    init() {
//        let providerFactory = AppCheckDebugProviderFactory()
//        AppCheck.setAppCheckProviderFactory(providerFactory)
//
//        FirebaseApp.configure()
        db = Firestore.firestore()
    }
    
    struct UserLocation: Identifiable, Codable {
            let id: String  // User ID
            let groupID: String
            var location: CLLocationCoordinate2D
            var timestamp: Date

            // Codable keys corresponding to the Firestore document
            enum CodingKeys: String, CodingKey {
                case id
                case groupID
                case latitude
                case longitude
                case timestamp
            }

            // Custom decoding to handle Firestore GeoPoint or an array of [latitude, longitude]
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(String.self, forKey: .id)
                groupID = try container.decode(String.self, forKey: .groupID)
                
                // If location is stored as GeoPoint in Firestore
                let geoPoint = try container.decode(GeoPoint.self, forKey: .latitude) // Using the 'latitude' key for example purposes
                location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)

                // If location is stored as an array, it might look something like this:
                // var locationArray = try container.decode([Double].self, forKey: .location)
                // location = CLLocationCoordinate2D(latitude: locationArray[0], longitude: locationArray[1])
                
                let timestamp = try container.decode(Timestamp.self, forKey: .timestamp)
                self.timestamp = timestamp.dateValue()
            }

            // Custom encoding to handle Firestore GeoPoint or an array of [latitude, longitude]
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(id, forKey: .id)
                try container.encode(groupID, forKey: .groupID)
                
                // Encode as GeoPoint or as an array of [latitude, longitude]
                let geoPoint = GeoPoint(latitude: location.latitude, longitude: location.longitude)
                try container.encode(geoPoint, forKey: .latitude) // Using 'latitude' key for example purposes
                // or as an array:
                // try container.encode([location.latitude, location.longitude], forKey: .location)
                
                let timestamp = Timestamp(date: self.timestamp)
                try container.encode(timestamp, forKey: .timestamp)
            }
        }
    
//    struct Messages: Codable, Identifiable {
//            @DocumentID var id: String?  // Firestore document ID
//            var createdAt: Date
//            var text: String
//            var user: String
//            var groupID: String
//            
//            // Using Firestore's Timestamp requires handling when encoding and decoding
//            enum CodingKeys: String, CodingKey {
//                case id
//                case createdAt
//                case text
//                case user
//                case groupID
//            }
//            
//            init(from decoder: Decoder) throws {
//                let container = try decoder.container(keyedBy: CodingKeys.self)
//                id = try container.decodeIfPresent(String.self, forKey: .id)
//                let timestamp: Timestamp = try container.decode(Timestamp.self, forKey: .createdAt)
//                createdAt = timestamp.dateValue()
//                text = try container.decode(String.self, forKey: .text)
//                user = try container.decode(String.self, forKey: .user)
//                groupID = try container.decode(String.self, forKey: .groupID)
//            }
//            
//            func encode(to encoder: Encoder) throws {
//                var container = encoder.container(keyedBy: CodingKeys.self)
//                try container.encodeIfPresent(id, forKey: .id)
//                let timestamp = Timestamp(date: createdAt)
//                try container.encode(timestamp, forKey: .createdAt)
//                try container.encode(text, forKey: .text)
//                try container.encode(user, forKey: .user)
//                try container.encode(groupID, forKey: .groupID)
//            }
//        }
    
    
    func createChatRoom(name: String, participants: [String], completion: @escaping (Error?) -> Void) {
            let roomRef = db.collection("rooms").document()
            roomRef.setData([
                "name": name,
                "createdAt": Timestamp(),
                "members": participants
            ]) { error in
                completion(error)
            }
        }
    
    // fetch all chat rooms the current user is in
        func fetchChatRooms(completion: @escaping ([String]?, Error?) -> Void) {
            guard let currentUserUID = Auth.auth().currentUser?.uid else {
                completion(nil, NSError(domain: "CurrentUserError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Current user not found"]))
                return
            }
            
            print("current user id: ", currentUserUID)
            print(db.collection("rooms"))
            
            db.collection("rooms").whereField("members", arrayContains: currentUserUID).getDocuments { (snapshot, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(nil, NSError(domain: "SnapshotError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Snapshot is nil"]))
                    return
                }
                
                let groupIDs = snapshot.documents.map { $0.documentID }
                print("group ids: ", groupIDs)
                print(groupIDs.count)
                completion(groupIDs, nil)
            }
        }
    
    // fetch users for all corresponding chat rooms
    func fetchGroupUsers(groupID: String, completion :@escaping ([String]?, Error?) -> Void) {
        db.collection("rooms").document(groupID).getDocument { documentSnapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                completion(nil, NSError(domain: "DocumentNotFoundError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Group document not found"]))
                return
            }
            
            if let data = documentSnapshot.data(), let members = data["members"] as? [String] {
                completion(members, nil)
            } else {
                let dataError = NSError(domain: "DataUnwrapError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to unwrap members data"])
                completion(nil, dataError)
            }
        }
    }
    
    func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
        func sendMessage(groupID: String, userId: String, text: String, completion: @escaping (Error?) -> Void) {
            let roomQuery = db.collection("rooms").whereField("groupID", isEqualTo: groupID).limit(to: 1)
            
            roomQuery.getDocuments { (snapshot, error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let roomDocument = snapshot?.documents.first else {
                    completion(NSError(domain: "RoomNotFoundError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Room document not found"]))
                    return
                }
                
                let messageCollectionRef = roomDocument.reference.collection("messages")
                
                let randomID = self.generateRandomString(length: 20)
                
                let messageData: [String: Any] = [
                    "id": randomID,
                    "text": text,
                    "createdAt": Timestamp(),
                    "sender": userId
                ]
                
                let messageRef = messageCollectionRef.addDocument(data: messageData) { error in
                    completion(error)
                }
            }
        }
        
//        func fetchMessages(roomId: String, completion: @escaping ([DocumentSnapshot]?, Error?) -> Void) {
//            db.collection("messages")
//                .whereField("roomId", isEqualTo: roomId)
//                .order(by: "createdAt")
//                .getDocuments { (snapshot, error) in
//                    completion(snapshot?.documents, error)
//                }
//        }
    
        func deleteChatRoom(roomId: String, completion: @escaping (Error?) -> Void) {
            let roomRef = db.collection("rooms").document(roomId)
            // Optionally delete messages first in batch operation
            db.collection("messages").whereField("roomId", isEqualTo: roomId).getDocuments { (snapshot, error) in
                guard let snapshot = snapshot else {
                    completion(error)
                    return
                }
                let batch = self.db.batch()
                snapshot.documents.forEach { batch.deleteDocument($0.reference) }
                batch.deleteDocument(roomRef)
                
                batch.commit { err in
                    completion(err)
                }
            }
        }
    
    func fetchMessages(groupID: String, completion: @escaping([Messages]?, Error?) -> Void) {
        db.collection("rooms")
            .document(groupID)
            .collection("messages")
            .order(by: "createdAt")
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    completion(nil, nil)
                    return
                }
                
                print("Size of snapshot.documents: \(snapshot.documents.count)")
                
                var history: [Messages] = []
                    for document in snapshot.documents {
                        do {
                            print("here")
                            if let messageData = document.data() as? [String: Any],
                               let id = messageData["id"] as? String,
                               let sender = messageData["sender"] as? String,
                               let createdAt = messageData["createdAt"] as? Timestamp,
                               let text = messageData["text"] as? String {
                                print("message text ", text)
                                let message = Messages(id: id, sender: sender, createdAt: createdAt, text: text)
                                history.append(message)
                            }
                        } catch let error {
                            print("Error decoding message: \(error.localizedDescription)")
                        }
                    }
                    completion(history, nil)
            }
    }
    
    func createPost(user: User, from: String, to: String, pickupDate: Timestamp, desiredSplit: Double, maxPassengers: Int, message: String) {
        let postRef = db.collection("posts").document()
        let newPost = Post(id: postRef.documentID, userID: user.uid, from: from, to: to, pickupDate: pickupDate, desiredSplit: desiredSplit, currentSplit: desiredSplit, maxPassengers: maxPassengers, spotsLeft: maxPassengers, message: message)
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
        let postDocument = db.collection("posts").whereField("spotsLeft", isGreaterThan: 0)
        
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
                      let currentSplit = postData["currentSplit"] as? Double,
                   let maxPassengers = postData["maxPassengers"] as? Int,
                      let spotsLeft = postData["spotsLeft"] as? Int,
                   let message = postData["message"] as? String {
                       print("id \(id)")
                       print("userID \(userID)")
                       print("from \(from)")
                       print("to \(to)")
                       print("pickupDate \(pickupDate)")
                       print("desiredSplit \(desiredSplit)")
                       print("currentSplit \(currentSplit)")
                       print("maxPassengers \(maxPassengers)")
                       print("spotsLeft \(spotsLeft)")
                       print("message \(message)")
                    let post = Post(id: id,
                                    userID: userID,
                                    from: from,
                                    to: to,
                                    pickupDate: pickupDate,
                                    desiredSplit: desiredSplit,
                                    currentSplit: currentSplit,
                                    maxPassengers: maxPassengers,
                                    spotsLeft: spotsLeft,
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
               let currentSplit = postData["currentSplit"] as? Double,
               let maxPassengers = postData["maxPassengers"] as? Int,
               let spotsLeft = postData["spotsLeft"] as? Int,
               let message = postData["message"] as? String {
                let post = Post(id: id,
                                userID: userID,
                                from: from,
                                to: to,
                                pickupDate: pickupDate,
                                desiredSplit: desiredSplit,
                                currentSplit: currentSplit,
                                maxPassengers: maxPassengers,
                                spotsLeft: spotsLeft,
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
    
    func addUserToRide(postID: String, userID: String, completion: @escaping(Error?) -> Void) {
        db.collection("posts").document(postID).getDocument { documentSnapshot, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let post = documentSnapshot, post.exists else {
                completion(NSError(domain: "PostNotFoundError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Post document not found"]))
                return
            }
            
            // update maxPassengers field
            if var postData = post.data(), var spotsLeft = postData["spotsLeft"] as? Int {
                spotsLeft -= 1
                print("spots left: ", spotsLeft)
                
                // update firestore
                self.db.collection("posts").document(postID).updateData(["spotsLeft": spotsLeft]) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        // calculate and update split amount
                        let desiredSplit = postData["desiredSplit"] as? Double ?? 0.0
                        let maxPassengers = postData["maxPassengers"] as? Int ?? 0
                        let splitAmount = desiredSplit / Double(maxPassengers - spotsLeft)
                        print("new split amount: ", splitAmount)
                        self.db.collection("posts").document(postID).updateData(["currentSplit": splitAmount]) { error in
                            if let error = error {
                                completion(error)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                }
            } else {
                completion(NSError(domain: "PostDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to unwrap post data"]))
            }
        }
    }
    
    func addUserToRoom(postID: String, userID: String, completion: @escaping(Error?) -> Void) {
        let db = Firestore.firestore()
            
        // Reference to the chat room document
        let roomRef = db.collection("rooms").whereField("postID", isEqualTo: postID).limit(to: 1)
        
        // Fetch the room document
        roomRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            guard let roomDocument = snapshot?.documents.first else {
                completion(NSError(domain: "RoomNotFoundError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Room document not found"]))
                return
            }
            
            // Update the members array in the chat room document
            let roomDocRef = roomDocument.reference
            print("room ref ", roomDocRef)
            roomDocRef.updateData(["members": FieldValue.arrayUnion([userID])]) { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                print("here")
                
                roomDocRef.getDocument { updatedRoomDocument, error in
                    if let error = error {
                        completion(error)
                        return
                    }
                    
                    guard let updatedRoomData = updatedRoomDocument?.data(),
                          let updatedMembers = updatedRoomData["members"] as? [String] else {
                        completion(NSError(domain: "RoomDataError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to unwrap room data"]))
                        return
                    }
                    
                    // Print the updated members array
                    print("Updated members array:", updatedMembers)
                    
                    completion(nil)
                }
            }
        }
    }
}
