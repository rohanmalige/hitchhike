//
//  Types.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import MapKit

// Users
struct appUser {
    let id: String
    let email: String
    let first: String
    let last: String
    
    init(id: String, email: String, firstName: String, lastName: String) {
        self.id = id
        self.email = email
        self.first = firstName
        self.last = lastName
    }
}

//extension FirebaseAuth.User {
//    var appUser: User {
//        return User(id: uid, email: email ?? "", firstName: "", lastName: "")
//    }
//}

// Post
struct Post {
    let id: String
    let userID: String
    let from: String
    let to: String
    let pickupDate: Timestamp
    let desiredSplit: Double
    let currentSplit: Double
    let maxPassengers: Int
    let spotsLeft: Int
    let message: String
}

// Request
struct Request {
    let id: String
    let userID: String
    let from: String
    let to: String
    let pickupDate: Date
    let desiredSplit: Double
    let message: String
}

struct Messages: Identifiable {
    let id: String
    let sender: String
    let createdAt: Timestamp
    let text: String
}

struct UserLocation: Identifiable {
    let id: String
    var location: CLLocationCoordinate2D
    var timestamp: Date
}

// Post Extension
extension Post {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "userID": userID,
            "from": from,
            "to": to,
            "pickupDate": pickupDate,
            "desiredSplit": desiredSplit,
            "currentSplit": currentSplit,
            "maxPassengers": maxPassengers,
            "spotsLeft": spotsLeft,
            "message": message
        ]
    }
}

extension Request {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "userID": userID,
            "from": from,
            "to": to,
            "pickupDate": pickupDate,
            "desiredSplit": desiredSplit,
            "message": message
        ]
    }
}

extension Messages {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "sender": sender,
            "createdAt": createdAt,
            "text": text
        ]
    }
}

extension UserLocation {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "location": location,
            "timestamp": timestamp
        ]
    }
}
