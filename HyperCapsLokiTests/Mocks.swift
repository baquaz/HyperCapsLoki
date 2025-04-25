//
//  Mocks.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 18/04/2025.
//

import Testing
@testable import HyperCapsLoki

// MARK: - Mock AppEnvironment
final class MockAppEnvironment: AppEnvironmentProtocol {
  let defaultHyperkey: Key = .f15
  
  var remapper: any RemapExecutor = MockRemapper()
  var eventsHandler: EventsHandler
  
  var storageRepository: any StorageRepository
  
  var launchUseCase: any LaunchUseCase
  var remapKeyUseCase: any RemapKeyUseCase
  var hyperkeyFeatureUseCase: any HyperkeyFeatureUseCase
  var exitUseCase: any ExitUseCase
  
  // MARK: - Init
  init(
    remapper: any RemapExecutor,
    eventsHandler: EventsHandler,
    storageRepository: any StorageRepository,
    launchUseCase: any LaunchUseCase,
    remapKeyUseCase: any RemapKeyUseCase,
    hyperkeyFeatureUseCase: any HyperkeyFeatureUseCase,
    exitUseCase: any ExitUseCase
  ) {
    self.remapper = remapper
    self.eventsHandler = eventsHandler
    self.storageRepository = storageRepository
    self.launchUseCase = launchUseCase
    self.remapKeyUseCase = remapKeyUseCase
    self.hyperkeyFeatureUseCase = hyperkeyFeatureUseCase
    self.exitUseCase = exitUseCase
  }
}

// MARK: - Mock Remapper
struct MockRemapper: RemapExecutor {
  func remapUserKeyMappingCapsLock(using key: Key) { }
  func resetUserKeyMappingCapsLock() { }
}

// MARK: - Mock System Events Injector
class MockSystemEventsInjector: SystemEventsInjection {
  var hyperkeyDownSequence: [CGEventFlags] = []
  var hyperkeyUpSequence: [CGEventFlags] = []
  
  var injectedSequence: [Bool] = []
  private(set) var capsLockToggled = false
  
  func injectHyperkeyFlagsSequence(isKeyDown: Bool) {
    injectedSequence.append(isKeyDown)
  }
  
  func injectCapsLockStateToggle() {
    capsLockToggled = true
  }
}

// MARK: - Mock Caps Lock Trigger Timer
final class MockCapsLockTriggerTimer: AsyncCapsLockTimer {
  private(set) var started = false
  private(set) var cancelled = false
  private(set) var expired = false
  private var onExpire: (@MainActor () -> Void)?
  
  func start(delay: Duration, onExpire: @escaping @MainActor () -> Void) {
    started = true
    self.onExpire = onExpire
  }
  
  func cancel() {
    cancelled = true
  }
  
  func simulateExpiration() async {
    expired = true
    Task { @MainActor in
      onExpire?()
    }
  }
}

import Cocoa
// MARK: - Mock EventsHandler
@MainActor
class MockEventsHandler: EventsHandler {
  
  private(set) var setUpEventTapCalled = false
  
  private(set) var receivedSetEventTapEnabled: Bool?
  private(set) var receivedHyperkey: Key?
  private(set) var receivedAvailableSequenceKeys: [Key]?

  
  override func setUpEventTap() {
    setUpEventTapCalled = true
  }
  
  override func setEventTap(enabled: Bool) {
    receivedSetEventTapEnabled = enabled
  }
  
  override func set(_ hyperkey: Key?) {
    super.set(hyperkey)
    receivedHyperkey = hyperkey
  }
}

