//
//  MiniHyperkeyApp.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 29/12/2024.
//

import IOKit.hid
import SwiftUI
import Cocoa
import Foundation

@main
struct MiniHyperkeyApp: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @State private var appState = AppState()
  
  init() {
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
