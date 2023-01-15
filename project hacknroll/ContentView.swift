//
//  ContentView.swift
//  project hacknroll
//
//  Created by Tristan on 14/01/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var selection = 1
    
    var body: some View {
        ZStack {
            KSMapView()
            VStack {
                TabView(selection: $selection) {
                    ContactView()
                        .tabItem {
                            Label("Emergency", systemImage: "exclamationmark.triangle.fill")
                        }
                        .tag(0)
                    GroupsView()
                        .tabItem {
                            Label("Groups", systemImage: "rectangle.3.group.fill")
                        }
                        .tag(1)
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(2)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
