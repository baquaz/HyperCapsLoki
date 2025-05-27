//
//  MockAppEnvironment.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 02/05/2025.
//

import Foundation
import Cocoa
@testable import HyperCapsLokiModule

final class MockAppEnvironment: AppEnvironmentProtocol {
  
  let defaultHyperkey: Key = .f15
  
  var remapper: any RemapExecutor = MockRemapper()
  var eventsHandler: EventsHandler
  
  var storageRepository: any StorageRepository
  
  var loginItemUseCase: any LoginItemUseCase
  var permissionUseCase: any AccessibilityPermissionUseCase
  var launchUseCase: any LaunchUseCase
  var remapKeyUseCase: any RemapKeyUseCase
  var hyperkeyFeatureUseCase: any HyperkeyFeatureUseCase
  var logsUseCase: any LogsUseCase
  var exitUseCase: any ExitUseCase
  
  // MARK: - Init
  init(
    remapper: any RemapExecutor,
    eventsHandler: EventsHandler,
    storageRepository: any StorageRepository,
    loginItemUseCase: any LoginItemUseCase,
    permissionUseCase: any AccessibilityPermissionUseCase,
    launchUseCase: any LaunchUseCase,
    remapKeyUseCase: any RemapKeyUseCase,
    hyperkeyFeatureUseCase: any HyperkeyFeatureUseCase,
    logsUseCase: any LogsUseCase,
    exitUseCase: any ExitUseCase
  ) {
    self.remapper = remapper
    self.eventsHandler = eventsHandler
    self.storageRepository = storageRepository
    self.loginItemUseCase = loginItemUseCase
    self.permissionUseCase = permissionUseCase
    self.launchUseCase = launchUseCase
    self.remapKeyUseCase = remapKeyUseCase
    self.hyperkeyFeatureUseCase = hyperkeyFeatureUseCase
    self.logsUseCase = logsUseCase
    self.exitUseCase = exitUseCase
  }
}
