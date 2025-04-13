//
//  Storage.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 18/02/2025.
//

import Foundation

struct Storage {
  
  @UserDefaultsBacked(key: "isHyperkeyFeatureActive", defaultValue: true)
  var isHyperkeyFeatureActive: Bool?
  
  @UserDefaultsBacked(key: "selectedHyperkey", defaultValue: nil)
  var selectedHyperkey: String?
  
  @UserDefaultsBacked(key: "commandKeyInSequence", defaultValue: nil)
  var commandKeyInSequence: Bool?
  
  @UserDefaultsBacked(key: "controlKeyInSequence", defaultValue: nil)
  var controlKeyInSequence: Bool?
  
  @UserDefaultsBacked(key: "optionKeyInSequence", defaultValue: nil)
  var optionKeyInSequence: Bool?
  
  @UserDefaultsBacked(key: "shiftKeyInSequence", defaultValue: nil)
  var shiftKeyInSequence: Bool?
}
