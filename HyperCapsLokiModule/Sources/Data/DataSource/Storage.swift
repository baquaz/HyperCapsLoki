//
//  Storage.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 18/02/2025.
//

import Foundation

// MARK: - StorageProtocol
public protocol StorageProtocol {
  var isLoginItemEnabled: Bool? { get set }

  var isHyperkeyFeatureActive: Bool? { get set }
  var selectedHyperkey: String? { get set }

  // Hyperkey Sequence Keys
  var commandKeyInSequence: Bool? { get set }
  var controlKeyInSequence: Bool? { get set }
  var optionKeyInSequence: Bool? { get set }
  var shiftKeyInSequence: Bool? { get set }
}

extension StorageProtocol {
  // Provides key path and subscript access to Hyperkey Sequence Keys
  func keyPath(for key: Key) -> WritableKeyPath<Self, Bool?>? {
    switch key {
      case .leftCommand: return \Self.commandKeyInSequence
      case .leftControl: return \Self.controlKeyInSequence
      case .leftOption:  return \Self.optionKeyInSequence
      case .leftShift:   return \Self.shiftKeyInSequence
      default: return nil
    }
  }

  subscript(key: Key) -> Bool? {
    get {
      guard let path = keyPath(for: key) else { return nil }
      return self[keyPath: path]
    }
    set {
      guard let path = keyPath(for: key) else { return }
      self[keyPath: path] = newValue
    }
  }
}

// MARK: - Storage
public struct Storage: StorageProtocol {

  @UserDefaultsBacked(key: "isLoginItemEnabled", defaultValue: true)
  public var isLoginItemEnabled: Bool?

  @UserDefaultsBacked(key: "isHyperkeyFeatureActive", defaultValue: true)
  public var isHyperkeyFeatureActive: Bool?

  @UserDefaultsBacked(key: "selectedHyperkey", defaultValue: nil)
  public var selectedHyperkey: String?

  // MARK: - Hyperkey Sequence Keys
  @UserDefaultsBacked(key: "commandKeyInSequence", defaultValue: nil)
  public var commandKeyInSequence: Bool?

  @UserDefaultsBacked(key: "controlKeyInSequence", defaultValue: nil)
  public var controlKeyInSequence: Bool?

  @UserDefaultsBacked(key: "optionKeyInSequence", defaultValue: nil)
  public var optionKeyInSequence: Bool?

  @UserDefaultsBacked(key: "shiftKeyInSequence", defaultValue: nil)
  public var shiftKeyInSequence: Bool?

  public init() { }
}
