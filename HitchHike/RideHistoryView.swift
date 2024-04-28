//
//  RideHistoryView.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RideHistoryView: View {
    @ObservedObject private var firestoreManager = FirestoreManager()
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var userModel: UserModel
    @State private var upcomingPosts: [Post] = []
    @State private var groupNames: [String] = ["SF"]
    
    var body: some View {
        List(upcomingPosts, id: \.id) { post in
            // Display each upcoming trip post
            chatRoomSection
        }
        .onAppear {
            fetchUpcomingTrips()
            firestoreManager.fetchChatRooms{ groups, error in
                if let error = error {
                    print("Error fetching groups: \(error.localizedDescription)")
                } else if let groups = groups {
                    viewModel.userGroups = groups
                }
            }
        }
        
    }
    
    
    private func fetchUpcomingTrips() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Current user not found")
            return
        }
        
        firestoreManager.fetchUpcomingTrips(userID: currentUserUID) { posts, error in
            print("fetching upcoming trips")
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
            } else if let fetchedPosts = posts {
                self.upcomingPosts = fetchedPosts
                print("post count ", upcomingPosts.count)
            }
        }
    }
    
    private func fetchGroupNames() {
            for groupID in viewModel.userGroups {
                firestoreManager.fetchGroupName(groupID: groupID) { fetchedName in
                    print("fetching")
                    
                    if let name = fetchedName {
                        groupNames.append(name)
                    }
                }
            }
        }

    private var chatRoomSection: some View {
        Section(header: Text("Chat Rooms")) {
            ForEach(0..<viewModel.userGroups.count, id: \.self) { index in
                            NavigationLink(destination: MessagesView(groupID: viewModel.userGroups[index])) {
                                Text("Trip to \(groupNames.indices.contains(index) ? groupNames[index] : "")")
                            }
                        }
        }
    }
}

//#Preview {
//    RideHistoryView()
//}
