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
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
  private var hyperkeyManager: HyperKeyManager?
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    hyperkeyManager = HyperKeyManager(remapper: Remapper(), eventsHandler: .init())
    
    hyperkeyManager?.launch()
  }
  
}
