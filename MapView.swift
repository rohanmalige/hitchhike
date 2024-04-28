//
//  MapView.swift
//  HitchHike
//
//  Created by Lena Ray on 4/27/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @State private var annotations: [IdentifiablePointAnnotation] = []
    
    let tower = CLLocationCoordinate2D(latitude: 43.64272145122822, longitude: -79.38712117539345)
    
    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: annotations) { annotation in
            MapMarker(coordinate: annotation.coordinate, tint: .blue)
        }
        .onAppear {
            print("fetching locations")
            locationViewModel.fetchAllLocations(groupID: "IwKOkFm0jct1wjZ9rM9O") { userLocations, error in
                if let error = error {
                    print("Error fetching user locations: \(error.localizedDescription)")
                } else if let userLocations = userLocations {
                    DispatchQueue.main.async {
                        self.annotations = userLocations.map { value in
                            let annotation = IdentifiablePointAnnotation()
                            annotation.coordinate = value.location
                            annotation.title = value.id
                            return annotation
                        }
                    }
                }
            }
        }
    }
        
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.54135, longitude: -121.77019),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
}

class IdentifiablePointAnnotation: NSObject, MKAnnotation, Identifiable {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var title: String?
}



struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView().environmentObject(LocationViewModel())
    }
}
