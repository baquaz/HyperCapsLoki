//
//  App.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 29/12/2024.
//

import SwiftUI
import HyperCapsLokiUI
import HyperCapsLokiModule

@main
struct HyperCapsLokiApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @State private var appState = AppState()
  
  static var dependencies: DepenedencyBuilder = AppDependencyBuilder()
  
  init() {
    appState.container = Self.dependencies.build()
    appDelegate.inject(appState: appState)
  }
  
  var body: some Scene {
    MenuBarExtra("HyperCapsLoki", systemImage: "keyboard.onehanded.right") {
      AppMenu()
        .environment(appState)
    }
    .menuBarExtraStyle(.window)
  }
}
