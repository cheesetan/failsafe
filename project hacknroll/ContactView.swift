//
//  ContactView.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase

struct ContactView: View {
    
    @State private var arrayofusers = []
    
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
                    Firestore.firestore().collection("groups").whereField("users", arrayContains: "\(finalEmail)")
                        .getDocuments() { (querySnapshot, err) in
                            if let err = err {
                                print("Error getting documents: \(err)")
                            } else {
                                for document in querySnapshot!.documents {
                                    Firestore.firestore().collection("groups").document("\(document.documentID)").getDocument { (document, error) in
                                        if let document = document, document.exists {
                                            let user = document.get("users") as! [Any]
                                            var temparray = Array<Any>()
                                            temparray = Array(user)
                                            
                                            temparray.forEach { user in
                                                if self.arrayofusers.firstIndex(where: {$0 as! String == "\(user)"}) == nil {
                                                    if user as! String != finalEmail {
                                                        arrayofusers.append(user)
                                                        
                                                        Firestore.firestore().collection("users").document("\(user)").updateData(["emergency-notify": "true"]) { error in
                                                            if let error = error {
                                                                print("Error updating document: \(error)")
                                                            } else {
                                                                print("Document successfully updated!")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            print("Document does not exist")
                                        }
                                    }
                                }
                            }
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
