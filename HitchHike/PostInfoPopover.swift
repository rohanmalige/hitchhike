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
    @State private var fromText = ""
    @State private var toText = ""
    @State private var currentsplit: Double = 0
    @State private var remainingSpots: Int = 0
    @State private var isNavigatingToTripsView = false
    
    var body: some View {
        VStack{
            VStack {
                //            if let post = post {
                TextField("I am going from...", text: $fromText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .font(.custom("Avenir", size: 18))
                TextField("I am going to...", text: $toText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .font(.custom("Avenir", size: 18))
                if let currentSplit = post?.currentSplit {
                    Text("Desired Split: $\(currentSplit, specifier: "%.2f")")
                        .font(.custom("Avenir", size: 18))
                        .padding()
                }
                
                if let spotsLeft = post?.spotsLeft {
                    Text("Remaining Spots: \(spotsLeft)")
                        .font(.custom("Avenir", size: 18))
                        .padding()
                }
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
            .background(Color("BackgroundColor"))
            
            
            
            
            .padding()
            .onAppear {
                fetchPost()
                print(postId)
                //            print(post.from)
                //            print(post.to)
            }
        }
        .containerRelativeFrame([.horizontal,.vertical])
        .background(Color("BackgroundColor"))
    }
        
        
    
    private func fetchPost() {
        firestoreManager.fetchPost(id: postId) { fetchedPost, error in
            if let error = error {
                print("Error fetching post: \(error.localizedDescription)")
                return
            }
            if let fetchedPost = fetchedPost {
                self.post = fetchedPost
                fromText = fetchedPost.from
                toText = fetchedPost.to
                currentsplit = fetchedPost.currentSplit
                remainingSpots = fetchedPost.spotsLeft
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
