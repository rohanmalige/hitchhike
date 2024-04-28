//
//  LocationViewmodel.swift
//  HitchHike
//
//  Created by Rohan Malige on 4/27/24.
//

import Foundation
import CoreLocation
import FirebaseFirestore

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocations: [UserLocation] = []
    
    private let locationManager = CLLocationManager()
    private var db = Firestore.firestore()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        locationManager.requestWhenInUseAuthorization() // Request appropriate authorization from the user
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    func fetchUserLocation(groupID: String, userID: String, completion: @escaping (UserLocation?, Error?) -> Void) {
        db.collection("rooms").document(groupID).collection("location").whereField("id", isEqualTo: userID).limit(to: 1).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching user locations \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("No user location found")
                completion(nil, nil)
                return
            }
            
            if let data = document.data() as? [String: Any],
                       let location = data["location"] as? GeoPoint {
                        print("Latitude: \(location.latitude)")
                    }
            
            if let data = document.data() as? [String: Any],
              let location = data["location"] as? GeoPoint,
              let timestamp = data["timestamp"] as? Timestamp {
                let userLocation = UserLocation(id: userID, location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), timestamp: timestamp.dateValue())
                print("location: ", location)
                completion(userLocation, nil)
            } else {
                print("Failed to parse user location data")
                completion(nil, nil)
            }
        }
    }
    
    func fetchAllLocations(groupID: String, completion: @escaping ([UserLocation]?, Error?) -> Void) {
        FirestoreManager().fetchGroupUsers(groupID: groupID) { [weak self] users, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching group users: \(error.localizedDescription)")
                return
            }
            
            guard let users = users else {
                print("No users found in the group")
                return
            }
            
            print(users)
            
            // For each user in the group, fetch their location
            for userID in users {
                self.fetchUserLocation(groupID: groupID, userID: userID) { userLocation, error in
                    if let error = error {
                        print("Error fetching user location for userID: \(userID), \(error.localizedDescription)")
                        return
                    }
                    
                    if let userLocation = userLocation {
                        self.userLocations.append(userLocation)
                        print("fetch all user locations: ", self.userLocations)
                    }
                }
            }
        }
    }
    
    func updateLocationInFirebase(_ location: CLLocationCoordinate2D, forUserID userID: String, inGroup groupID: String) {
        // Here you would implement the logic to update the user's location in Firestore
        // Convert CLLocationCoordinate2D to a Firestore-friendly format
        let locationData: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("rooms").document(groupID).collection("location").document(userID).setData(locationData) { error in
            if let error = error {
                print("Error updating location: \(error)")
            } else {
                print("Location updated successfully")
            }
        }
    }
}

extension FirestoreManager {
    func updateUserLocation(userID: String, groupID: String, location: CLLocationCoordinate2D) {
        // Prepare the data as per your Firestore structure
        let locationData: [String: Any] = [
            "location": [location.latitude, location.longitude],
            "timestamp": Timestamp(date: Date()) // Use the current date and time as the timestamp
        ]

        // Add or update the user's location in Firestore
        db.collection("rooms").document(groupID).collection("location").document(userID).setData(locationData) { error in
            if let error = error {
                print("Error updating user location: \(error.localizedDescription)")
            } else {
                print("Successfully updated user location")
            }
        }
    }
}
