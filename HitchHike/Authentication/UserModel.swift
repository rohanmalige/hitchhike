// UserModel.swift
import SwiftUI
import Combine
import FirebaseFirestore

class UserModel: ObservableObject {
    @Published var messages: [Message] = []
    var email: String = "user@example.com"  // Should be dynamically set based on user session
    var pairingID: String = "examplePairingID"  // Should be dynamically set based on chat room
    private var firestoreManager = FirestoreManager()

//    func getMessageHistory(groupID: String) {
//        firestoreManager.fetchMessages(roomId: groupID) { [weak self] (documents, error) in
//            if let documents = documents, !documents.isEmpty {
//                self?.messages = documents.compactMap { doc in
//                    try? doc.data(as: Message.self)
//                }
//            } else if let error = error {
//                print("Error fetching messages: \(error.localizedDescription)")
//            }
//        }
//    }

    func sendMessage(groupID: String, message: String) {
        let newMessage = Message(text: message, user: self.email)
        firestoreManager.sendMessage(groupID: groupID, userId: self.email, text: message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.messages.append(newMessage)
                }
            }
        }
    }
}

// Message struct already defined as Codable, ensure Firestore fields match the Swift model exactly
struct Message: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    var text: String
    var user: String
}
