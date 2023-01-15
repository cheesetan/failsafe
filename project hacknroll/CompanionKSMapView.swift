//
//  CompanionKSMapView.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import CoreLocation
import MapKit

struct Point: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct CompanionKSMapView: View {
    
    let groups: Groups
    
    @Environment(\.presentationMode) var presentationMode

    @State private var showingJoinCode = false
    
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    @State private var lat = Double()
    @State private var lon = Double()
    @State private var userList = Array<Any>()
    @State private var userListCount = Int()
    
    @State private var updateDate = ""
    @State private var updateTime = ""
    
    let db = Firestore.firestore()
    
    @State var tracking: MapUserTrackingMode = .follow
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.45, longitudeDelta: 0.45))
    
    @State private var annotations = [Point]()
    
    
    var body: some View {
        NavigationView {
            Map(coordinateRegion: $region, interactionModes: MapInteractionModes.all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: annotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    VStack {
                        Text(annotation.name)
                            .fontWeight(.bold)
                            .font(.subheadline)
                        Image(systemName: "person.circle")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
            }
            .onAppear {
                db.collection("groups").document("\(groups.id)")
                    .addSnapshotListener { documentSnapshot, error in
                        guard let document = documentSnapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        guard document.data() != nil else {
                            print("Document data was empty.")
                            return
                        }
                        if let users = document.get("users") {
                            let user2 = users as! [Any]
                            userListCount = user2.count
                            userList = Array(user2)
                            
                            userList.forEach { user in
                                if user as! String != finalEmail {
                                    db.collection("users").document("\(user)")
                                        .addSnapshotListener { documentSnapshot, error in
                                            guard let document = documentSnapshot else {
                                                print("Error fetching document: \(error!)")
                                                return
                                            }
                                            guard document.data() != nil else {
                                                print("Document data was empty.")
                                                return
                                            }
                                            if let coords = document.get("coordinates") {
                                                let point = coords as! GeoPoint
                                                lat = point.latitude
                                                lon = point.longitude
                                                print(lat, lon) //here you can let coor = CLLocation(latitude: longitude:)
                                                
                                                let name = document.get("name") as! String
                                                
                                                if let index = self.annotations.firstIndex(where: {$0.id == "\(user)"}) {
                                                    annotations[index] = Point(id: "\(user)", name: "\(name)", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon)))
                                                } else if self.annotations.firstIndex(where: {$0.id == "\(user)"}) == nil {
                                                    annotations.append(Point(id: "\(user)", name: "\(name)", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))))
                                                }
                                                
                                                print("abc: \(annotations)")
                                            }
                                        }
                                    
                                    db.collection("users").document("\(user)")
                                        .addSnapshotListener { documentSnapshot, error in
                                            guard let document = documentSnapshot else {
                                                print("Error fetching document: \(error!)")
                                                return
                                            }
                                            guard document.data() != nil else {
                                                print("Document data was empty.")
                                                return
                                            }
                                            if let lastupdate = document.get("coordinates-lastupdate") {
                                                let lastupdate2 = lastupdate as! Timestamp
                                                
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "hh:mm:ss a"
                                                updateTime = dateFormatter.string(from: lastupdate2.dateValue())
                                                
                                                let dateFormatter2 = DateFormatter()
                                                dateFormatter2.dateStyle = .long
                                                dateFormatter2.timeStyle = .none
                                                updateDate = dateFormatter2.string(from: lastupdate2.dateValue())
                                                
                                                print(updateDate, updateTime)
                                            }
                                        }
                                }
                            }
                        }
                    }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(groups.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingJoinCode.toggle()
                    } label: {
                        Image(systemName: "info.circle.fill")
                    }
                    .sheet(isPresented: $showingJoinCode) {
                        groupJoinCode(groups: groups)
                            .presentationDetents([.height(190)])
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct groupJoinCode: View {
    
    let groups: Groups
    @State private var titletext = String()
    
    var body: some View {
        VStack {
            Text(titletext)
                .font(.title3)
                .fontWeight(.bold)
            Text("Keep this screen open until the other person has joined.")
                .padding(.top, 5)
                .multilineTextAlignment(.center)
                .font(.caption)
        }
        .onAppear {
            let rng = String(Int.random(in: 10000000..<99999999))
            titletext = rng
            
            Firestore.firestore().collection("groups").document(groups.id).updateData([
                "connectCode": rng,
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
        .onDisappear {
            Firestore.firestore().collection("groups").document(groups.id).updateData([
                "connectCode": FieldValue.delete(),
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
}

struct CompanionKSMapView_Previews: PreviewProvider {
    static var previews: some View {
        CompanionKSMapView(groups: Groups(id: "abc", name: "abc"))
    }
}
