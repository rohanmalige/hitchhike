//
//  NavBar.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI

struct NavBar: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .environmentObject(locationViewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(0)
            
            RidesView()
                .tabItem {
                    Image(systemName: "car")
                    Text("Rides")
                }
                .tag(1)
                    
//            MessagesView()
//                .tabItem {
//                    Image(systemName: "message")
//                    Text("Messages")
//                }
        
            RideHistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Trips")
                }
                .tag(2)
            
            UserProfileView()
                .environmentObject(viewModel)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
    }
}

//struct NavigationBar_Previews: PreviewProvider {
//    static var previews: some View {
//        NavBar()
//    }
//}
