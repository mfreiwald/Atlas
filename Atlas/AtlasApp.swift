//
//  AtlasApp.swift
//  Atlas
//
//  Created by Michael on 08.10.24.
//

/*
This app can be used to receive a URL
 Extract the content of the URL with JinaAI
 Send content to GPT
 Receive summary from LLM
 */

import SwiftUI
import SwiftData

@main
struct AtlasApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Article.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
