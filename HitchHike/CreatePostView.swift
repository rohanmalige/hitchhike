//
//  CreatePostView.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct CreatePostView: View {
    @ObservedObject private var firestoreManager = FirestoreManager()
    @State private var from: String = ""
    @State private var to: String = ""
    @State private var maxPassengers: String = ""
    @State private var desiredSplit: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.trailing, 8)
                
                Text("Name")
                    .font(.custom("Avenir", size: 18))
            }
            
            TextField("From", text: $from)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("To", text: $to)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Max Passengers", text: $maxPassengers)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)
            
            TextField("Desired Split", text: $desiredSplit)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.decimalPad)
            
            Button(action: createPost) {
                Text("Submit")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    private func createPost() {
        guard let maxPassengers = Int(maxPassengers),
              let desiredSplit = Double(desiredSplit) else {
            print("Invalid input")
            return
        }
        
        if let user = Auth.auth().currentUser {
            // user is signed in
            let uid = user.uid
            let email = user.email
            
            firestoreManager.createPost(user: user,
                                        from: from,
                                        to: to,
                                        pickupDate: Timestamp(),
                                        desiredSplit: desiredSplit,
                                        maxPassengers: maxPassengers,
                                        message: "")
            presentationMode.wrappedValue.dismiss()
        } else {
            // no user is signed in
            print("Error: no user logged in")
        }
    }
    
}

#Preview {
    CreatePostView()
}
