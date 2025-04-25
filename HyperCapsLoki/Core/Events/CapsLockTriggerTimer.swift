//
//  CapsLockTriggerTimer.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 19/04/2025.
//


import Foundation
import Cocoa
import IOKit.hid

protocol AsyncCapsLockTimer {
  func start(delay: Duration, onExpire: @escaping @MainActor () -> Void)
  func cancel()
}

final class CapsLockTriggerTimer: AsyncCapsLockTimer {
  private var task: Task<Void, Never>?
  
  func start(delay: Duration, onExpire: @escaping @MainActor () -> Void) {
    cancel()
    task = Task {
      try? await Task.sleep(for: delay)
      await onExpire()
    }
  }
  
  func cancel() {
    task?.cancel()
    task = nil
  }
}
