//
//  AsyncTimer.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 27/04/2025.
//

import Foundation

protocol AsyncTimer {
  func start(interval: Duration, repeating: Bool, action: @escaping @MainActor () -> Void)
  func cancel()
}

final class DefaultAsyncTimer: AsyncTimer {
  private var task: Task<Void, Never>?
  
  func start(interval: Duration, repeating: Bool, action: @escaping @MainActor () -> Void) {
    cancel()
    
    task = Task {
      repeat {
        try? await Task.sleep(for: interval)
        await action()
      } while repeating && !Task.isCancelled
    }
  }
  
  func cancel() {
    task?.cancel()
    task = nil
  }
}
