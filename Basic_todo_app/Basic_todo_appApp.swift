//
//  Basic_todo_appApp.swift
//  Basic_todo_app
//
//  Created by Waseem Abbas on 01/10/2025.
//

import SwiftUI

@main
struct Basic_todo_appApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TodoView(context: persistenceController.container.viewContext)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
