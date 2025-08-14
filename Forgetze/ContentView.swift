//
//  ContentView.swift
//  Forgetze
//
//  Created by Mark Andrews on 8/14/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        ContactListView()
            .environmentObject(appSettings)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
        .modelContainer(for: Contact.self, inMemory: true)
}
