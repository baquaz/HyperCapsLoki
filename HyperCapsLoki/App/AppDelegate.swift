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
  private var runtimeManager: RuntimeManager?
  
  // MARK: - AppState inject
  func inject(appState: AppState) {
    self.appState = appState
  }
  
  // MARK: - applicationDidFinishLaunching
  func applicationDidFinishLaunching(_ notification: Notification) {
    let container = Self.bootstrap()
    appState?.container = container
    
    Task {
      runtimeManager = RuntimeManager(
        launchUseCase: container.environment.launchUseCase,
        exitUseCase: container.environment.exitUseCase
      )
      await runtimeManager?.launch()
    }
  }
  
  // MARK: - applicationShouldTerminate
  func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    Task {
      await runtimeManager?.exit()
      NSApp.reply(toApplicationShouldTerminate: true)
    }
    return .terminateLater
  }
  
  // MARK: - DIContainer bootstrap
  private static func bootstrap() -> DIContainer {
    // MARK: Core
    let remapper = Remapper()
    let eventsHandler = EventsHandler(
      systemEventsInjector: SystemEventsInjector(),
      capsLockTriggerTimer: CapsLockTriggerTimer()
    )
    
    // MARK: Repositories
    let storageRepo = StorageRepositoryImpl(dataSource: Storage())
    
    // MARK: Use Cases
    let launchUseCase = LaunchUseCaseImpl(
      remapper: remapper,
      eventsHandler: eventsHandler,
      storageRepository: storageRepo
    )
    
    let remapKeyUseCase = RemapKeyUseCaseImpl(
      storageRepo: storageRepo,
      eventsHandler: eventsHandler,
      remapper: remapper
    )
    
    let hyperkeyFeatureUseCase = HyperkeyFeatureUseCaseImpl(
      storageRepository: storageRepo,
      eventsHandler: eventsHandler,
      remapper: remapper
    )
    
    let exitUseCase = ExitUseCaseImpl(
      remapper: remapper,
      eventsHandler: eventsHandler
    )
    
    // MARK: Environment
    let environment = AppEnvironment(
      remapper: remapper,
      eventsHandler: eventsHandler,
      storageRepository: storageRepo,
      launchUseCase: launchUseCase,
      remapKeyUseCase: remapKeyUseCase,
      hyperkeyFeatureUseCase: hyperkeyFeatureUseCase,
      exitUseCase: exitUseCase
    )
    
    return DIContainer(environment: environment)
  }
  
}
