//
//  AppDelegate.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import AppKit

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
  internal var appState: AppState?
  internal var runtimeManager: RuntimeProtocol?
  internal var makeRuntimeManager: (_ appState: AppState?) -> RuntimeProtocol =
  { RuntimeManager(appState: $0) }
  
  // MARK: - AppState inject
  func inject(appState: AppState) {
    self.appState = appState
  }
  
  // MARK: - applicationDidFinishLaunching
  func applicationDidFinishLaunching(_ notification: Notification) {
    #if DEBUG
    if CommandLine.arguments.contains("-ResetAppState") {
      resetAppState()
    }
    #endif
    
    Task {
      runtimeManager = makeRuntimeManager(appState)
      runtimeManager?.start()
    }
  }
  
  // MARK: - applicationShouldTerminate
  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    Task {
      runtimeManager?.exit()
      NSApp.reply(toApplicationShouldTerminate: true)
    }
    return .terminateLater
  }
  
#if DEBUG
  func resetAppState() {
    if let appDomain = Bundle.main.bundleIdentifier {
      UserDefaults.standard.removePersistentDomain(forName: appDomain)
      UserDefaults.standard.synchronize()
    }
  }
#endif
}
