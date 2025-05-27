//
//  AppEnvironment.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation
import CoreGraphics
import AppKit

public protocol AppEnvironmentProtocol {
  var defaultHyperkey: Key { get }

  // MARK: - Remapper
  var remapper: RemapExecutor { get }

  // MARK: - Events Handler
  var eventsHandler: EventsHandler { get }

  // MARK: - Storage Repo
  var storageRepository: StorageRepository { get }

  // MARK: - Use Cases
  var loginItemUseCase: LoginItemUseCase { get }
  var permissionUseCase: AccessibilityPermissionUseCase { get }
  var launchUseCase: LaunchUseCase { get }
  var remapKeyUseCase: RemapKeyUseCase { get }
  var hyperkeyFeatureUseCase: HyperkeyFeatureUseCase { get }
  var logsUseCase: LogsUseCase { get }
  var exitUseCase: ExitUseCase { get }
}

// MARK: - App Environment
public struct AppEnvironment: AppEnvironmentProtocol {
  public let defaultHyperkey: Key = .f15

  // Core components
  public let remapper: RemapExecutor
  public let eventsHandler: EventsHandler

  // Repositories
  public let storageRepository: StorageRepository

  // Use cases
  public let loginItemUseCase: LoginItemUseCase
  public let permissionUseCase: AccessibilityPermissionUseCase
  public let launchUseCase: LaunchUseCase
  public let remapKeyUseCase: RemapKeyUseCase
  public let hyperkeyFeatureUseCase: HyperkeyFeatureUseCase
  public let logsUseCase: LogsUseCase
  public let exitUseCase: ExitUseCase

  public init(
    remapper: RemapExecutor,
    eventsHandler: EventsHandler,
    storageRepository: StorageRepository,
    loginItemUseCase: LoginItemUseCase,
    permissionUseCase: AccessibilityPermissionUseCase,
    launchUseCase: LaunchUseCase,
    remapKeyUseCase: RemapKeyUseCase,
    hyperkeyFeatureUseCase: HyperkeyFeatureUseCase,
    logsUseCase: LogsUseCase,
    exitUseCase: ExitUseCase
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
