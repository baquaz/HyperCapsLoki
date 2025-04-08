//
//  KeyStorage.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 18/02/2025.
//

import Foundation

struct KeyStorage {
  @UserDefaultsBacked(key: "selectedHyperkey", defaultValue: nil)
  var selectedHyperkey: String?
}
