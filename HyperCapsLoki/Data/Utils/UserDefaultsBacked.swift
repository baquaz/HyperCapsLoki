//
//  UserDefaultsBacked.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 18/02/2025.
//

import Foundation

@propertyWrapper
struct UserDefaultsBacked<T: Sendable> {
  private let key: String
  private let defaultValue: T?
  private let defaults: UserDefaults
  
  init(key: String, defaultValue: T?, defaults: UserDefaults = .standard) {
    self.key = key
    self.defaultValue = defaultValue
    self.defaults = defaults
  }
  
  var wrappedValue: T? {
    get {
      defaults.object(forKey: key) as? T ?? defaultValue
    }
    set {
      if let value = newValue {
        defaults.setValue(value, forKey: key)
      } else {
        defaults.removeObject(forKey: key)
      }
    }
  }
}
