//
//  TestEnvironmentBuilder.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
@testable import HyperCapsLokiModule
@testable import AppLogger

struct TestEnvironment {
  // swiftlint:disable force_cast
  // MARK: - App
  var appState: AppState!
  var appDelegate: AppDelegate!
  
  var logStrategy: LogStrategy!
  var mockBufferedLogStrategy: MockBufferedFileLogStrategy {
    logStrategy as! MockBufferedFileLogStrategy
  }
  var mockNonBufferedLogStrategy: MockNonBufferredFileLogStrategy {
    logStrategy as! MockNonBufferredFileLogStrategy
  }
  
  // MARK: - Core
  var loginItemHandler: AppLoginItemService!
  var mockLoginItemHandler: MockLoginItemHandler {
    loginItemHandler as! MockLoginItemHandler
  }
  
  var accessibilityPermissionService: AccessibilityPermissionService!
  var mockAccessibilityPermissionService: MockAccessibilityPermissionService {
    accessibilityPermissionService as! MockAccessibilityPermissionService
  }
  
  var mockEventsHandler: MockEventsHandler!
  var systemEventsInjector: SystemEventsInjection!
  var mockSystemEventsInjector: MockSystemEventsInjector {
    systemEventsInjector as! MockSystemEventsInjector
  }
  
  var capsLockTriggerTimer: AsyncTimer!
  var mockCapsLockTriggerTimer: MockAsyncTimer {
    capsLockTriggerTimer as! MockAsyncTimer
  }
  
  var remapper: RemapExecutor!
  var mockRemapper: MockRemapper {
    remapper as! MockRemapper
  }
  
  var runTimeManager: RuntimeProtocol!
  var mockRuntimeManager: MockRuntimeManager {
    runTimeManager as! MockRuntimeManager
  }
  
  // MARK: - Data
  var storage: StorageProtocol!
  
  // MARK: - Domain
  var storageRepository: StorageRepository!
  
  // MARK: - Use Cases
  var loginItemUseCase: LoginItemUseCase!
  var mockLoginItemUseCase: MockLoginItemUseCase {
    loginItemUseCase as! MockLoginItemUseCase
  }
  var permissionUseCase: AccessibilityPermissionUseCase!
  var mockPermissionUseCase: MockPermissionUseCase {
    permissionUseCase as! MockPermissionUseCase
  }
  
  var launchUseCase: LaunchUseCase!
  var mockLaunchUseCase: MockLaunchUseCase {
    launchUseCase as! MockLaunchUseCase
  }
  
  var remapKeyUseCase: RemapKeyUseCase!
  var mockRemapUseCase: MockRemapKeyUseCase {
    remapKeyUseCase as! MockRemapKeyUseCase
  }
  
  var hyperkeyFeatureUseCase: HyperkeyFeatureUseCase!
  var mockHyperkeyFeatureUseCase: MockHyperkeyFeatureUseCase {
    hyperkeyFeatureUseCase as! MockHyperkeyFeatureUseCase
  }
  
  var logsUseCase: LogsUseCase!
  var mockLogsUseCase: MockLogsUseCase {
    logsUseCase as! MockLogsUseCase
  }
  
  var exitUseCase: ExitUseCase!
  var mockExitUseCase: MockExitUseCase {
    exitUseCase as! MockExitUseCase
  }
  
  // MARK: - View Models
  var appMenuViewModel: AppMenuViewModel!
  var logsViewModel: LogsViewModel!
}
