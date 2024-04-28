//
//  HitchHikeApp.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
}


@main
struct HitchHikeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    init() {
//        FirebaseApp.configure()
//        print("Configured Firebase")
//    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AuthenticatedView() {
                    Image(systemName: "number.circle.fill")
                        .resizable()
                        .frame(width: 100 , height: 100)
                        .foregroundColor(Color(.systemPink))
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .clipped()
                        .padding(4)
                        .overlay(Circle().stroke(Color.black, lineWidth: 2))
                } content: {
                    RootView()
                }
            }
        }
    }
}
