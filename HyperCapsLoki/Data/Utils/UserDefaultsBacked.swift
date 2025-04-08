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
  private let defaultValue: T
  private let defaults: UserDefaults
  
  init(key: String, defaultValue: T, defaults: UserDefaults = .standard) {
    self.key = key
    self.defaultValue = defaultValue
    self.defaults = defaults
  }
  
  var wrappedValue: T {
    get {
      defaults.object(forKey: key) as? T ?? defaultValue
    }
    nonmutating set {
      // Avoid Task.detached due to Sendable issues; run async on main queue safely
      DispatchQueue.global(qos: .utility).async { [key, newValue] in
        UserDefaults.standard.setValue(newValue, forKey: key)
      }
    }
  }
}

