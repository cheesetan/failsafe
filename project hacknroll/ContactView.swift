//
//  ContactView.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase

struct ContactView: View {
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 48)
                    .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                    .foregroundColor(.red)
                
                Button {
                    Firestore.firestore().collection("groups").whereField("users", isEqualTo: "\(finalEmail)")
                        .addSnapshotListener { querySnapshot, error in
                            guard let documents = querySnapshot?.documents else {
                                print("Error fetching documents: \(error!)")
                                return
                            }
                            let docmap = documents.map({docSnapshot in
                                let data = docSnapshot.data()
                                let docID = docSnapshot.documentID
                                print(docID)
                            })
                        }
                } label: {
                    RoundedRectangle(cornerRadius: 48)
                        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
                        .foregroundColor(.red)
                        .overlay(
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5)
                            ,alignment: .center)
                }
            }
            
        }
    }
}

struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}
