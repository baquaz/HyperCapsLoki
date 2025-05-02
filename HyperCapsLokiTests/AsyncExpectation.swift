//
//  AsyncExpectation.swift
//  HyperCapsLokiTests
//
//  Created by Piotr Błachewicz on 03/05/2025.
//

import Foundation

actor AsyncExpectation {
  private var continuation: CheckedContinuation<Void, Never>?
  
  func fulfill() {
    continuation?.resume()
  }
  
  func wait() async {
    await withCheckedContinuation { continuation = $0 }
  }
}
