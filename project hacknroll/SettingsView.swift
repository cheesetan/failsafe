//
//  SettingsView.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct SettingsView: View {
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @State private var displayName = String()
    
    // Paywalls
    @AppStorage("paidForEditingAcctDisplayName", store: .standard) private var paidForEditingAcctDisplayName = false
    @State private var openAlertForEditDisplayName = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: HStack {
                        Image(systemName: "person")
                        Text("Account")
                    }) {
                        if isLoggedIn == false {
                        } else {
                            Button {
                                
                            } label: {
                                VStack {
                                    HStack {
                                        VStack {
                                            ZStack {
                                                Image(systemName: "person.fill")
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 40, height: 40, alignment: .center)
                                                    .foregroundColor(Color.white)
                                                    .padding(15)
                                                    .background(.secondary)
                                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                                            }
                                        }
                                        .padding(.trailing, 8)
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(finalEmail)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color.primary)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Account Display Name")) {
                        TextField("Enter a display name", text: $displayName, axis: .horizontal)
                            .padding(.vertical)
                    }
                    .onAppear {
                        let db = Firestore.firestore()
                        let docRef = db.collection("users").document("\(finalEmail)")
                        docRef.getDocument { document, error in
                            if let document = document, document.exists {
                                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                
                                displayName = document.get("name") as! String
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }
                    .onChange(of: displayName) { newValue in
                        
                        if paidForEditingAcctDisplayName {
                            let docRef = Firestore.firestore().collection("users").document(finalEmail)
                            
                            docRef.updateData(["name": displayName]) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document successfully updated!")
                                }
                            }
                        } else {
                            print("bro forgor to pay")
                        }
                        
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        do {
                            try FirebaseAuth.Auth.auth().signOut()
                            isLoggedIn = false
                            finalPassword = ""
                            finalEmail = ""
                        } catch {
                            print("An error has occurred while trying to sign out.")
                        }
                    } label: {
                        HStack {
                            Text("Sign Out")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
        }
        .alert("Hey! Want to change your username?", isPresented: $openAlertForEditDisplayName) {
            Button("Cancel", role: .cancel) {
                fatalError("User didnt buy the username pack bruh")
            }
            Button("Buy", role: .destructive) {
                paidForEditingAcctDisplayName = true
            }

        } message: {
            Text("Buy our username pack!")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
