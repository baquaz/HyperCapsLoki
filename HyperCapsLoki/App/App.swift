//
//  HyperCapsLokiApp.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 29/12/2024.
//

import SwiftUI
import Foundation

@main
struct HyperCapsLokiApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @State private var appState = AppState()
  
  static var dependencyBuilder: DepenedencyBuilder = AppDependencyBuilder()
  
  init() {
    appState.container = Self.dependencyBuilder.build()
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
