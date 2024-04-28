//
//  Types.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

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
    let maxPassengers: Int
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
            "maxPassengers": maxPassengers,
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
