//
//  PostInfoPopover.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct PostInfoPopover: View {
    @ObservedObject private var firestoreManager = FirestoreManager()
    let postId: String
    @State private var post: Post?
    @State private var isNavigatingToTripsView = false
    
    var body: some View {
        VStack {
            if let post = post {
                Text("From: \(post.from)")
                    .font(.custom("Avenir", size: 18))
                Text("From: \(post.to)")
                    .font(.custom("Avenir", size: 18))
                Text("Desired Split")
                Button("Confirm") {
                    addRide()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding()
                
                NavigationLink(
                    destination: RideHistoryView(),
                    isActive: $isNavigatingToTripsView
                ) {
                    EmptyView()
                }
                .hidden()
            }
        
        }
        .padding()
        .onAppear {
            fetchPost()
            print(postId)
//            print(post.from)
//            print(post.to)
        }
    }
    
    private func fetchPost() {
        firestoreManager.fetchPost(id: postId) { fetchedPost, error in
            print("fetching")
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
            }
            
            if let fetchedPost = fetchedPost {
                post = fetchedPost
            }
        }
    }
    
    private func addRide() {
        guard let post = post, let userId = Auth.auth().currentUser?.uid else {
            print("Error: Post or user ID not found")
            return
        }
        
        firestoreManager.addUserToRide(postID: post.id, userID: userId) {
            error in
            if let error = error {
                print("Error adding user to ride: \(error.localizedDescription)")
            } else {
                print("User added to ride successfully")
                
                firestoreManager.addUserToRoom(postID: post.id, userID: userId) { roomError in
                    if let roomError = roomError {
                        print("Error adding user to room: \(roomError.localizedDescription)")
                    } else {
                        print("User added to room successfully")
                        isNavigatingToTripsView = true
                    }
                }
            }
        }
    }
}

#Preview {
    PostInfoPopover(postId: "FqpeEyh5OFOlNgvobD1p")
}
