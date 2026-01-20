//
//  YieldApp.swift
//  Yield
//
//  Created on 1/8/26.
//

import SwiftData
import SwiftUI

@main
struct YieldApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Portfolio.self,
      YieldTransaction.self,
      Subscription.self,
    ])
    let modelConfiguration = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: false
    )

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
