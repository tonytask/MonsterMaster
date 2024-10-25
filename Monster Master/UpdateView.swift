//
//  UpdateView.swift
//  Monster Master
//
//  Created by Tony on 6/9/24.
//

import SwiftUI


struct Version: Identifiable {
    let id = UUID()
    let number: String
    let updates: [String]
}

struct UpdateView: View {
    let versionHistory: [Version] = [
        
        /*Version(number: "1.1", updates: [
            "Implemented Offline Progression",
            "Shop System added",
            "Improved Alert UI"
        ]),*/
        
        Version(number: "1.0 11/06/24", updates: [
            "Basic layout Created",
            "Party and Explore Implemented",
            "Monsters and Auto Battling Implemented",
            "Energy System",
        ]),
        
    ]
    
    
    var body: some View {
        List {
            ForEach(versionHistory) { version in
                Section(header: Text("Version \(version.number)")) {
                    ForEach(version.updates, id: \.self) { update in
                        Text(update)
                    }
                }
            }
            Section("To-Do List"){
                Text("Battle Text")
                Text("Asynchronous Battles")
                Text("Daily Quests")
                Text("Passive")
                Text("More Missions,Monsters,Abilities")
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Updates")
    }
}

#Preview {
    UpdateView()
}
