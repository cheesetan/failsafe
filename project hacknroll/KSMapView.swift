//
//  KSMapView.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import CoreLocation
import MapKit

struct KSMapView: View {
    var body: some View {
        mapView()
    }
}

struct mapView: UIViewRepresentable {
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @AppStorage("locationTracking", store: .standard) private var locationTracking = false
    
    func makeCoordinator() -> Coordinator {
        return mapView.Coordinator()
    }
    
    
    let map = MKMapView()
    let manager = CLLocationManager()
    
    func makeUIView(context: UIViewRepresentableContext<mapView>) -> MKMapView {
        
        manager.delegate = context.coordinator
        manager.startUpdatingLocation()
        map.showsUserLocation = true
        manager.requestWhenInUseAuthorization()
        return map
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<mapView>) {
        
    }
    
    class Coordinator: NSObject, CLLocationManagerDelegate {
        
        @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
        @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
        @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
        
        @AppStorage("locationTracking", store: .standard) private var locationTracking = false
        
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .denied {
                CLLocationManager().requestWhenInUseAuthorization()
                print("denied")
            }
            if status == .authorizedWhenInUse {
                print("authorized when in use")
                CLLocationManager().requestAlwaysAuthorization()
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    
                    if let error = error {
                        // Handle the error here.
                    }
                    
                    // Enable or disable features based on the authorization.
                }
            }
            if status == .authorizedAlways {
                print("authorized always")
                
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    
                    if let error = error {
                        // Handle the error here.
                    }
                    
                    // Enable or disable features based on the authorization.
                }
            }
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            manager.allowsBackgroundLocationUpdates = true
            
            let last = locations.last
            
            if isLoggedIn {
                
                Firestore.firestore().collection("users").document("\(self.finalEmail)")
                    .addSnapshotListener { documentSnapshot, error in
                        guard let document = documentSnapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        guard document.data() != nil else {
                            print("Document data was empty.")
                            return
                        }
                        if let coords = document.get("emergency-notify") {
                            let emergencynotify = coords as! String
                            if emergencynotify == "true" {
                                let content = UNMutableNotificationContent()
                                content.title = "Recall Due"
                                content.body = "item has reached its deadline."
                                content.sound = UNNotificationSound.default
                                content.interruptionLevel = .critical

                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                
                                let request = UNNotificationRequest(identifier: "notif-simulate", content: content, trigger: trigger)

                                UNUserNotificationCenter.current().add(request)
                                
                                let docRef = Firestore.firestore().collection("users").document(self.finalEmail)

                                   docRef.updateData(["emergency-notify": "false"]) { error in
                                       if let error = error {
                                           print("Error updating document: \(error)")
                                       } else {
                                           print("Document successfully updated!")
                                       }
                                   }
                            }
                        }
                    }
                
                Firestore.firestore().collection("users").document("\(self.finalEmail)").updateData([
                    "coordinates" : GeoPoint(latitude: (last?.coordinate.latitude)!, longitude: (last?.coordinate.longitude)!)
                ]) { (err) in
                    
                    if err != nil {
                        print((err?.localizedDescription) as Any)
                        return
                    }
                    
                    print("success")
                    
                    Firestore.firestore().collection("users").document("\(self.finalEmail)").updateData([
                        "coordinates-lastupdate" : Date()
                    ]) { (err) in
                        
                        if err != nil {
                            print((err?.localizedDescription) as Any)
                            return
                        }
                        
                    }
                }
            }
            
        }
    }
}

struct KSMapView_Previews: PreviewProvider {
    static var previews: some View {
        KSMapView()
    }
}
