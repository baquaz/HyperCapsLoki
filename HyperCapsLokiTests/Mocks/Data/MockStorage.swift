//
//  MockStorage.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 03/05/2025.
//

import Foundation
@testable import HyperCapsLoki

struct MockStorage: StorageProtocol {
  var isHyperkeyFeatureActive: Bool?
  var selectedHyperkey: String?
  
  // Hyperkey Sequence Keys
  var commandKeyInSequence: Bool?
  var controlKeyInSequence: Bool?
  var optionKeyInSequence: Bool?
  var shiftKeyInSequence: Bool?
}
