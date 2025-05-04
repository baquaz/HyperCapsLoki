//
//  MockHyperkeyFeatureUseCase.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 04/05/2025.
//

import Foundation
@testable import HyperCapsLoki

final class MockHyperkeyFeatureUseCase: HyperkeyFeatureUseCase {
  
  var enabledSequenceKeys: [Key] = []
  
  private(set) var receivedHyperkeyFeatureStatus: (isActive: Bool, forced: Bool)?
  private(set) var receivedHyperkeySequenceKey: (key: Key, enabled: Bool)?
  private(set) var receivedHyperkeySequenceKeysAll: Bool?
  
  func setHyperkeyFeature(active isActive: Bool, forced: Bool) {
    receivedHyperkeyFeatureStatus = (isActive, forced)
  }
  
  func getHyperkeyEnabledSequenceKeys() -> [Key] {
    enabledSequenceKeys
  }
  
  func setHyperkeySequence(enabled: Bool, for key: Key) {
    receivedHyperkeySequenceKey = (key, enabled)
  }
  
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) {
    receivedHyperkeySequenceKeysAll = isEnabled
  }
}
