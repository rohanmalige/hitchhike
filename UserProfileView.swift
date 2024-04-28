//import SwiftUI
//import Firebase
//import FirebaseAnalyticsSwift
//import FirebaseAuth
//
//struct ProfileHeaderView: View {
//    var body: some View {
//        VStack {
//            HStack {
//                Spacer()
//                Image(systemName: "person.fill")
//                    .resizable()
//                    .frame(width: 100, height: 100)
//                    .aspectRatio(contentMode: .fit)
//                    .clipShape(Circle())
//                    .clipped()
//                    .padding(4)
//                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
//                Spacer()
//            }
//            Button(action: {}) {
//                Text("Edit Profile")
//            }
//        }
//    }
//}
//
//struct ChatRoomRow: View {
//    var user: appUser
//    @EnvironmentObject var userModel: UserModel
//    var body: some View {
//        NavigationLink(destination: ChatView(groupID: user.groupID, userModel: userModel)) {
//            HStack {
//                Text(user.first + " " + user.last)
//                Spacer()
//                Text(user.notes)
//            }
//        }
//    }
//}
//
//struct UserProfileView: View {
//    @EnvironmentObject var viewModel: AuthenticationViewModel
//    @EnvironmentObject var userModel: UserModel
//    @Environment(\.dismiss) var dismiss
//    @State var presentingConfirmationDialog = false
//
//    private func deleteAccount() {
//        Task {
//            if await viewModel.deleteAccount() {
//                dismiss()
//            }
//        }
//    }
//
//    private func signOut() {
//        viewModel.signOut()
//    }
//
//    var body: some View {
//        NavigationView {
//            List {
//                Section(header: Text("Profile Information")) {
//                    ProfileHeaderView()
//                }
//                
//                Section(header: Text("Chat Rooms")) {
//                    ForEach(userModel.recipientUsers) { user in
//                        ChatRoomRow(user: user)
//                    }
//                }
//                
//                Section {
//                    Button(role: .cancel, action: signOut) {
//                        HStack {
//                            Spacer()
//                            Text("Sign out")
//                            Spacer()
//                        }
//                    }
//                }
//                
//                Section {
//                    Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
//                        HStack {
//                            Spacer()
//                            Text("Delete Account")
//                            Spacer()
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Profile")
//            .navigationBarTitleDisplayMode(.inline)
//            .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
//                                isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
//                Button("Delete Account", role: .destructive, action: deleteAccount)
//                Button("Cancel", role: .cancel, action: { })
//            }
//        }
//        .onAppear {
//            userModel.getChatRooms(querySearch: viewModel.email)  // Assuming email is used as a key
//        }
//    }
//}



//
//  UserProfileView.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import Firebase
import FirebaseAnalyticsSwift
import FirebaseAuth

struct UserProfileView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel
  @Environment(\.dismiss) var dismiss
  @State var presentingConfirmationDialog = false

  private func deleteAccount() {
    Task {
      if await viewModel.deleteAccount() == true {
        dismiss()
      }
    }
  }

  private func signOut() {
    viewModel.signOut()
  }

  var body: some View {
    Form {
      Section {
        VStack {
          HStack {
            Spacer()
            Image(systemName: "person.fill")
              .resizable()
              .frame(width: 100 , height: 100)
              .aspectRatio(contentMode: .fit)
              .clipShape(Circle())
              .clipped()
              .padding(4)
              .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
            Spacer()
          }
          Button(action: {}) {
            Text("edit")
          }
        }
      }
      .listRowBackground(Color(UIColor.systemGroupedBackground))
      Section("Email") {
        Text(viewModel.displayName)
      }
//        Section(header: Text("Name")) {
//            Text("First Name: \(viewModel.user?.firstName ?? "")")
//            Text("Last Name: \(viewModel.user?.lastName ?? "")")
//        }
      Section {
        Button(role: .cancel, action: signOut) {
          HStack {
            Spacer()
            Text("Sign out")
            Spacer()
          }
        }
      }
      Section {
        Button(role: .destructive, action: { presentingConfirmationDialog.toggle() }) {
          HStack {
            Spacer()
            Text("Delete Account")
            Spacer()
          }
        }
      }
    }
    .navigationTitle("Profile")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
        let db = Firestore.firestore()
        if let uid = Auth.auth().currentUser?.uid {
            db.collection("users").document(uid).getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    viewModel.firstName = data?["firstName"] as? String ?? ""
                    viewModel.lastName = data?["lastName"] as? String ?? ""
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
    .analyticsScreen(name: "\(Self.self)")
    .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                        isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
      Button("Delete Account", role: .destructive, action: deleteAccount)
      Button("Cancel", role: .cancel, action: { })
    }
  }
}

struct UserProfileView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      UserProfileView()
        .environmentObject(AuthenticationViewModel())
    }
  }
}
