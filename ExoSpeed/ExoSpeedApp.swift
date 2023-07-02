//
//  ExoSpeedApp.swift
//  ExoSpeed
//
//  Created by Terence Grover on 02/07/2023.
//

import SwiftUI

@main
struct ExoSpeedApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
