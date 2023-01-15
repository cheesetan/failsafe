//
//  GroupsView.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI
import Firebase

struct GroupsView: View {
    
    @ObservedObject var viewModel = GroupsVM()
    
    @State private var showingNewGroupView = false
    @State private var showingJoinGroup = false
    
    @AppStorage("isLoggedIn", store: .standard) private var isLoggedIn = false
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section(header: Text("Groups").fontWeight(.bold).font(.title3)) {
                        ForEach(viewModel.groups) { group in
                            VStack {
                                NavigationLink(destination: CompanionKSMapView(groups: group)) {
                                    Text(group.name)
                                        .padding(.vertical)
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                Firestore.firestore().collection("groups").document(group.id).updateData([
                                                    "users": FieldValue.arrayRemove([finalEmail]),
                                                ]) { err in
                                                    if let err = err {
                                                        print("Error updating document: \(err)")
                                                    } else {
                                                        print("Document successfully updated")
                                                    }
                                                }
                                            } label: {
                                                Label("Delete", systemImage: "trash.fill")
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingJoinGroup.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showingJoinGroup) {
                        joinGroup()
                            .presentationDetents([.height(190)])
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewGroupView.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .sheet(isPresented: $showingNewGroupView) {
                        newGroupView()
                            .presentationDetents([.height(190)])
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct joinGroup: View {
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @ObservedObject var viewModel = GroupsVM()
    
    @State private var groupName = String()
    
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        VStack {
            TextField("Enter Join Code", text: $groupName)
                .padding(20)
                .background(.thinMaterial)
                .cornerRadius(20)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.top, 10)
                .keyboardType(.numberPad)
            Button {
                Firestore.firestore().collection("groups").whereField("connectCode", isEqualTo: groupName).getDocuments() { (snapshot, error) in
                    if let error = error {
                        print("error getting documents! \(error)")
                    } else {
                        for document in snapshot!.documents {
                            db.collection("groups").document(document.documentID).getDocument { (document, error) in
                                guard error == nil else {
                                    print("error", error ?? "")
                                    return
                                }
                                
                                if let document = document, document.exists {
                                    let data = document.data()
                                    if let data = data {
                                        print("data", data)
                                        
                                        Firestore.firestore().collection("groups").document(document.documentID).updateData([
                                            "users": FieldValue.arrayUnion([finalEmail])])
                                        
                                        generator2.notificationOccurred(.success)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            } label: {
                Text("Join Group")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
    }
}

struct newGroupView: View {
    // MARK: - Dismiss Presentation Mode
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Feedback Haptics Generator
    let generator = UIImpactFeedbackGenerator(style: .medium)
    let generator2 = UINotificationFeedbackGenerator()
    
    private let db = Firestore.firestore()
    private let user = Auth.auth().currentUser
    
    @ObservedObject var viewModel = GroupsVM()
    
    @State private var groupName = String()
    
    @AppStorage("finalEmail", store: .standard) private var finalEmail = ""
    @AppStorage("finalPassword", store: .standard) private var finalPassword = ""
    
    var body: some View {
        VStack {
            TextField("New Group Name", text: $groupName)
                .padding(20)
                .background(.thinMaterial)
                .cornerRadius(20)
                .multilineTextAlignment(.center)
                .padding(.bottom, 5)
                .padding(.top, 10)
            Button {
                if groupName != "" && groupName != " " {
                    viewModel.createGroup(name: groupName)
                    generator2.notificationOccurred(.success)
                    presentationMode.wrappedValue.dismiss()
                } else {
                    generator2.notificationOccurred(.error)
                }
            } label: {
                Text("Create Group")
                    .bold()
                    .frame(width: 360, height: 50)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
            }
        }
        .padding(.horizontal)
    }
}

struct GroupsView_Previews: PreviewProvider {
    static var previews: some View {
        GroupsView()
    }
}
