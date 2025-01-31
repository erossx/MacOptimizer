//
//  MacOptimizerApp.swift
//  MacOptimizer
//
//  Created by 이은환 on 2/1/25.
//

import SwiftUI

@main
struct MacOptimizerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
