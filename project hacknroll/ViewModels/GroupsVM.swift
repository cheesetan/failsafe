//
//  GroupsVM.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase

struct Groups: Codable, Identifiable {
    var id: String
    var name: String
}


class GroupsVM: ObservableObject {
    
    @Published var groups = [Groups]()
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
        
    func fetchData() {
        db.collection("groups").whereField("users", arrayContains: finalEmail).addSnapshotListener({(snapshot, error) in
            guard let documents = snapshot?.documents else {
                print ("no docs returned!")
                return
            }
            
            self.groups = documents.map({docSnapshot -> Groups in
                let data = docSnapshot.data()
                let docID = docSnapshot.documentID
                let name = data["name"] as? String ?? ""
                
                return Groups(id: docID, name: name)
            })
        })
    }
    
    func createGroup(name: String) {
        db.collection("groups").addDocument(data: [
            "name": "\(name)",
            "users": [finalEmail]]) { err in
                if let err = err {
                    print("error adding document! \(err)")
                }
            }
    }
}
