//
//  AppEnvironment.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

protocol AppEnvironmentProtocol {
  var defaultHyperkey: Key { get }
  
  // MARK: - Remapper
  var remapper: RemapExecutor { get }
  
  // MARK: - Events Handler
  var eventsHandler: EventsHandler { get }
  
  // MARK: - Storage Repo
  var storageRepository: StorageRepository { get }
  
  // MARK: - Use Cases
  var permissionUseCase: AccessibilityPermissionUseCase { get }
  var launchUseCase: LaunchUseCase { get }
  var remapKeyUseCase: RemapKeyUseCase { get }
  var hyperkeyFeatureUseCase: HyperkeyFeatureUseCase { get }
  var exitUseCase: ExitUseCase { get }
}

// MARK: - App Environment
struct AppEnvironment: AppEnvironmentProtocol {
  
  let defaultHyperkey: Key = .f15
  
  // Core components
  let remapper: RemapExecutor
  let eventsHandler: EventsHandler
  
  // Repositories
  let storageRepository: StorageRepository
  
  // Use cases
  let permissionUseCase: AccessibilityPermissionUseCase
  let launchUseCase: LaunchUseCase
  let remapKeyUseCase: RemapKeyUseCase
  let hyperkeyFeatureUseCase: HyperkeyFeatureUseCase
  let exitUseCase: ExitUseCase
}

// MARK: - Previews
extension AppEnvironment {
  @MainActor
  static let preview = AppEnvironment(
    remapper: PreviewRemapExecutor(),
    eventsHandler: EventsHandler(
      systemEventsInjector: SystemEventsInjector(),
      capsLockTriggerTimer: DefaultAsyncTimer()
    ),
    storageRepository: PreviewStorage(),
    permissionUseCase: PreviewUseCase(),
    launchUseCase: PreviewUseCase(),
    remapKeyUseCase: PreviewUseCase(),
    hyperkeyFeatureUseCase: PreviewUseCase(),
    exitUseCase: PreviewUseCase()
  )
}

struct PreviewUseCase:
  AccessibilityPermissionUseCase,
  LaunchUseCase,
  RemapKeyUseCase,
  HyperkeyFeatureUseCase,
  ExitUseCase
{
  
  func ensureAccessibilityPermissionsAreGranted() -> Bool { false }
  func monitorChanges(completion: @escaping (Bool) -> Void) {}
  func stopMonitoring() { }
  func launch() { }
  func execute(newKey: Key?) { }
  func setHyperkeyFeature(active: Bool, forced: Bool) {}
  func getHyperkeySequenceKeysEnabled() -> [Key] { [] }
  func setHyperkeySequence(enabled: Bool, for key: Key) { }
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) { }
  func terminate() { }
  func exit() { }
}

struct PreviewRemapExecutor: RemapExecutor {
  func remapUserKeyMappingCapsLock(using key: Key) { }
  func resetUserKeyMappingCapsLock() { }
}

struct PreviewStorage: StorageRepository {
  func getHyperkeyFeatureState() -> Bool? { nil }
  func setHyperkeyFeatureState(_ isActive: Bool) {  }

  func getSelectedHyperkey() -> Key? { .f15 }
  func saveSelectedHyperkey(_ key: Key?) { }

  func getHyperkeySequenceKeysUnset() -> [Key] { [] }
  func getHyperkeySequenceKeysEnabled() -> [Key] { [] }
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) { }
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) { }
}
