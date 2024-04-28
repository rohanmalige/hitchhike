//
//  NavBar.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI

struct NavBar: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            RidesView()
                .tabItem {
                    Image(systemName: "car")
                    Text("Rides")
                }
                    
            MessagesView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Messages")
                }
        
            RideHistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Trips")
                }
            
//            UserProfileView()
//                .environmentObject(viewModel)
//                .tabItem {
//                    Image(systemName: "person")
//                    Text("Profile")
//                }
        }
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavBar()
    }
}
