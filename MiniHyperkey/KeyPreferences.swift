//
//  KeyPreferences.swift
//  MiniHyperkey
//
//  Created by Piotr Błachewicz on 18/02/2025.
//

import Foundation

struct KeyPreferences {
  @UserDefaultsBacked(key: "selectedHyperkey", defaultValue: nil)
  static var selectedHyperkey: String?
}
