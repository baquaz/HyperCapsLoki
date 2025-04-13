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
  private var appState: AppState?
  private var hyperkeyManager: HyperkeyManager?
  
  // MARK: - AppState inject
  func inject(appState: AppState) {
    self.appState = appState
  }
  
  // MARK: - applicationDidFinishLaunching
  func applicationDidFinishLaunching(_ notification: Notification) {
    let container = Self.bootstrap()
    appState?.container = container
    
    Task {
      hyperkeyManager = HyperkeyManager(
        launchUseCase: container.environment.launchUseCase,
        exitUseCase: container.environment.exitUseCase
      )
      await hyperkeyManager?.launch()
    }
  }
  
  // MARK: - applicationShouldTerminate
  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    Task {
      await hyperkeyManager?.exit()
      NSApp.reply(toApplicationShouldTerminate: true)
    }
    return .terminateLater
  }
  
  // MARK: - DIContainer bootstrap
  private static func bootstrap() -> DIContainer {
    // MARK: Core
    let remapper = Remapper()
    let eventsHandler = EventsHandler()
    
    // MARK: Repositories
    let keyStorageRepo = KeyStorageRepositoryImpl(dataSource: KeyStorage())
    
    // MARK: Use Cases
    let launchUseCase = LaunchUseCaseImpl(
      remapper: remapper,
      eventsHandler: eventsHandler,
      keyStorageRepository: keyStorageRepo
    )
    
    let exitUseCase = ExitUseCaseImpl(
      remapper: remapper,
      eventsHandler: eventsHandler
    )
    
    let remapKeyUseCase = RemapKeyUseCaseImpl(
      keyStorageRepo: keyStorageRepo,
      eventsHandler: eventsHandler,
      remapper: remapper
    )
    
    // MARK: Environment
    let environment = AppEnvironment(
      remapper: remapper,
      eventsHandler: eventsHandler,
      keyStorageRepository: keyStorageRepo,
      launchUseCase: launchUseCase,
      exitUseCase: exitUseCase,
      remapKeyUseCase: remapKeyUseCase
    )
    
    return DIContainer(environment: environment)
  }
  
}
