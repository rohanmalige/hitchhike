//
//  MessagesView.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import Combine
import Firebase
import FirebaseAuth

struct MessagesView: View {
    @ObservedObject private var firestoreManager = FirestoreManager()
    @EnvironmentObject var viewModel: AuthenticationViewModel
    var groupID: String
    
    @State private var messageText = ""
    @State private var messages: [Messages] = []
    
//    init(groupID: string) {
//        self.groupID = groupID
//        self.firestoreManager = FirestoreManager(groupID: groupID)
//    }

    var body: some View {
        VStack {
            if !messages.isEmpty {
                List(messages) { message in
                    Text(message.text)
                }
            } else {
                Text("No messages")
            }
            
            HStack {
                TextField("Type your message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onTapGesture {
                        fetchMessages()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            }
            .padding()
        }
        .onAppear {
            fetchMessages()
        }
        .onTapGesture {
            print("messages view messages ", messages)
        }
    }
    
    private func fetchMessages() {
        firestoreManager.fetchMessages(groupID: groupID) { fetchedMessages, error in
            print("fetching messages")
            if let error = error {
                print("Error fetching messages: \(error.localizedDescription)")
            } else if let messages = fetchedMessages {
                self.messages = messages
                print("firestore message count: ", messages.count)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else {
            return
        }
        
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID not found")
            return
        }
        
        firestoreManager.sendMessage(groupID: groupID, userId: userID, text: messageText) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                // Clear the text field after sending the message
                self.messageText = ""
                
                // fetch messages again to update the view
                self.fetchMessages()
            }
        }
    }
}

//struct MessagesView: View {
//    @EnvironmentObject var viewModel: AuthenticationViewModel
//    
//    var body: some View {
//        Section(header: Text("Chat Rooms")) {
//            ForEach(viewModel.userGroups, id: \.self) { groupID in
//                NavigationLink(destination: ChatView(groupID: groupID)) {
//                    Text(groupID)
//                }
//            }
//        }
//    }
//}

//private var chatRoomsSection: some View {
//    Section(header: Text("Chat Rooms")) {
//        ForEach(viewModel.userGroups, id: \.self) { groupID in
//            NavigationLink(destination: ChatView(groupID: groupID)) {
//                Text(groupID)
//            }
//        }
//    }
//}

//
//struct MessagesView: View {
//    @ObservedObject private var firestoreManager = FirestoreManager()
//    var groupID: String
//    
//    var body: some View {
//        VStack {
//            if let messages = firestoreManager.messages {
//                List(messages) { message in
//                    Text(message.text)
//                }
//            } else {
//                Text("No messages")
//            }
//        }
//        .onAppear {
//            firestoreManager.fetchMessages(groupID: groupID) { fetchedMessages, error in
//                if let error = error {
//                    print("Error fetching messages: \(error.localizedDescription)")
//                } else if let messages = fetchedMessages {
//                    self.firestoreManager.messages = messages
//                }
//            }
//        }
//    }
//}

//#Preview {
//    MessagesView(groupID: "IwKOkFm0jct1wjZ9rM9O")
//}
