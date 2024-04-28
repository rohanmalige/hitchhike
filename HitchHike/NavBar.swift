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
    init(selectedTab: Binding<Int>) {
        _selectedTab = selectedTab
        // Set the default color for tab bar items (unselected state)
        UITabBar.appearance().unselectedItemTintColor = UIColor.black
    }
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
        .accentColor(.black)
    }
}

//struct NavigationBar_Previews: PreviewProvider {
//    static var previews: some View {
//        NavBar()
//    }
//}
