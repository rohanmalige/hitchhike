//
//  AuthenticationManager.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}

//extension User {
//    var firstName: String? {
//        get {
//            return displayName?.components(separatedBy: " ").first
//        }
//    }
//    
//    var lastName: String? {
//        get {
//            return displayName?.components(separatedBy: " ").last
//        }
//    }
//    
//}

@MainActor
class AuthenticationViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  @Published var confirmPassword = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""

  @Published var flow: AuthenticationFlow = .login

  @Published var isValid  = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage = ""
  @Published var user: User?
  @Published var displayName = ""

  init() {
    registerAuthStateHandler()

    $flow
      .combineLatest($email, $password, $confirmPassword)
      .map { flow, email, password, confirmPassword in
        flow == .login
          ? !(email.isEmpty || password.isEmpty)
          : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
      }
      .assign(to: &$isValid)
  }

  private var authStateHandler: AuthStateDidChangeListenerHandle?

  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.authenticationState = user == nil ? .unauthenticated : .authenticated
        self.displayName = user?.email ?? ""
      }
    }
  }

  func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }

  private func wait() async {
    do {
      print("Wait")
      try await Task.sleep(nanoseconds: 1_000_000_000)
      print("Done")
    }
    catch {
      print(error.localizedDescription)
    }
  }

  func reset() {
    flow = .login
    email = ""
    password = ""
    confirmPassword = ""
  }
}

// MARK: - Email and Password Authentication

extension AuthenticationViewModel {
  func signInWithEmailPassword() async -> Bool {
    authenticationState = .authenticating
    do {
      try await Auth.auth().signIn(withEmail: self.email, password: self.password)
      return true
    }
    catch  {
      print(error)
      errorMessage = error.localizedDescription
      authenticationState = .unauthenticated
      return false
    }
  }

  func signUpWithEmailPassword() async -> Bool {
    authenticationState = .authenticating
    do  {
        try await Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let user = authResult?.user else {
                print(error?.localizedDescription ?? "Unknown error creating user")
                self.authenticationState = .unauthenticated
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = "\(self.firstName) \(self.lastName)"
            changeRequest.commitChanges { error in
                if let error = error {
                    print ("Error updating user profile: \(error.localizedDescription)")
                } else {
                    print("User profile updated successfully")
                }
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).setData([
                "firstName": self.firstName,
                "lastName": self.lastName
            ]) { error in
                if let error = error {
                    print("Error writing document: \(error.localizedDescription)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
        return true
    }
    catch {
      print(error)
      errorMessage = error.localizedDescription
      authenticationState = .unauthenticated
      return false
    }
  }

  func signOut() {
    do {
      try Auth.auth().signOut()
    }
    catch {
      print(error)
      errorMessage = error.localizedDescription
    }
  }

  func deleteAccount() async -> Bool {
    do {
      try await user?.delete()
      return true
    }
    catch {
      errorMessage = error.localizedDescription
      return false
    }
  }
}
