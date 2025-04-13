//
//  StorageRepositoryImpl.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import Foundation

final class StorageRepositoryImpl: StorageRepository {
  
  private var dataSource: Storage
  
  init(dataSource: Storage) {
    self.dataSource = dataSource
  }
  
  func getHyperkeyFeatureState() -> Bool? {
    dataSource.isHyperkeyFeatureActive
  }
  
  func setHyperkeyFeatureState(_ isActive: Bool) {
    dataSource.isHyperkeyFeatureActive = isActive
  }
  
  func getSelectedHyperkey() -> Key? {
    Key(rawValue: dataSource.selectedHyperkey ?? "")
  }
  
  func saveSelectedHyperkey(_ key: Key?) {
    dataSource.selectedHyperkey = key?.rawValue
  }
  
  func getHyperkeySequenceKeysUnset() -> [Key] {
    Key.allHyperkeySequenceKeys.filter {
      switch $0 {
        case .leftCommand: dataSource.commandKeyInSequence == nil
        case .leftControl: dataSource.controlKeyInSequence == nil
        case .leftOption: dataSource.optionKeyInSequence == nil
        case .leftShift: dataSource.shiftKeyInSequence ==  nil
        default: false
      }
    }
  }
  
  func getHyperkeySequenceKeysEnabled() -> [Key] {
    Key.allHyperkeySequenceKeys.filter {
      switch $0 {
        case .leftCommand: dataSource.commandKeyInSequence == true
        case .leftControl: dataSource.controlKeyInSequence == true
        case .leftOption: dataSource.optionKeyInSequence == true
        case .leftShift: dataSource.shiftKeyInSequence == true
        default: false
      }
    }
  }
  
  func setHyperkeySequence(enabled isEnabled: Bool, for key: Key) {
    if Key.allHyperkeySequenceKeys.first(where: {$0 == key }) != nil {
      switch key {
        case .leftCommand:
          dataSource.commandKeyInSequence = isEnabled
        case .leftOption:
          dataSource.optionKeyInSequence = isEnabled
        case .leftShift:
          dataSource.shiftKeyInSequence = isEnabled
        case .leftControl:
          dataSource.controlKeyInSequence = isEnabled
        default: break
      }
    }
  }
  
  func setHyperkeySequenceKeysAll(enabled isEnabled: Bool) {
    Key.allHyperkeySequenceKeys.forEach {
      switch $0 {
          case .leftCommand:
          dataSource.commandKeyInSequence = isEnabled
        case .leftOption:
          dataSource.optionKeyInSequence = isEnabled
        case .leftShift:
          dataSource.shiftKeyInSequence = isEnabled
        case .leftControl:
          dataSource.controlKeyInSequence = isEnabled
        default: break
      }
    }
  }
  
}
