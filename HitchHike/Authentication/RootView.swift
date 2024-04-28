////
////  RootView.swift
////  HitchHike
////
////  Created by Lena Ray on 4/27/24.
////
//
import SwiftUI
import Firebase

struct RootView: View {
    var body: some View {
        Text("hello")
    }
    
}

//
//struct RootView: View {
//    @State private var showSignInView: Bool = false
//    
//    var body: some View {
//        ZStack {
//            NavigationStack {
//                SettingsView(showSignInView: $showSignInView)
//            }
//        }
//        .onAppear {
//            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
//            self.showSignInView = authUser == nil
//            print("authUser \(authUser)")
//            print("show sign in view \(showSignInView)")
//        }
//        .fullScreenCover(isPresented: $showSignInView) {
//            NavigationStack {
//                AuthenticationView()
//            }
//        }
//    }
//}
//
//struct RootView_Previews: PreviewProvider {
//    static var previews: some View {
//        RootView()
//    }
//}
