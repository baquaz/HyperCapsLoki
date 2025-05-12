//
//  File.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 18/05/2025.
//

import Foundation
@testable import AppLogger

// MARK: - Log Recorder
final class LogRecorder: @unchecked Sendable {
  private var messages: [(String, LoggingTag, String)] = []
  private(set) var persistCalled = false
  private let lock = NSLock()
  private let group = DispatchGroup()
  
  init() {
    group.enter()
  }
  
  func record(_ message: (String, LoggingTag, String)) {
    lock.lock()
    messages.append(message)
    lock.unlock()
  }
  
  func setPersistCalled() {
    lock.lock()
    persistCalled = true
    lock.unlock()
    group.leave()
  }
  
  func all() -> [(String, LoggingTag, String)] {
    lock.lock()
    defer { lock.unlock() }
    return messages
  }
  
  func wasPersistCalled() -> Bool {
    lock.lock()
    defer { lock.unlock() }
    return persistCalled
  }
  
  func waitForPersist(timeout: TimeInterval = 1.0) -> Bool {
    group.wait(timeout: .now() + timeout) == .success
  }
}

// MARK: - Logging Tag Holder
actor LoggingTagHolder {
  private var tag: LoggingTag = DefaultLoggingTag.debug
  
  func get() -> LoggingTag { tag }
  func set(_ newValue: LoggingTag) { tag = newValue }
}

// MARK: - Mock Non Buffered File Log Strategy
final class MockNonBufferredFileLogStrategy: LogStrategy {
  
  let recorder = LogRecorder()
  private let tagHolder = LoggingTagHolder()
  
  var defaultLoggingTag: LoggingTag {
    get {
      fatalError("Accessing defaultLoggingTag synchronously is unsafe in this mock. Use async access methods instead.")
    }
    set {
      Task {
        await tagHolder.set(newValue)
      }
    }
  }
  
  func log(output: String, tag: LoggingTag, category: String) {
    recorder.record((output, tag, category))
  }
}

// MARK: - Mock Buffered File Log Strategy
final class MockBufferedFileLogStrategy: LogStrategy, LogPersisting {
  let recorder = LogRecorder()
  let returnURL = URL(fileURLWithPath: "/dev/null")
  
  private let tagHolder = LoggingTagHolder()
  
  var defaultLoggingTag: LoggingTag {
    get {
      fatalError("Accessing defaultLoggingTag synchronously is unsafe in this mock. Use async access methods instead.")
    }
    set {
      Task {
        await tagHolder.set(newValue)
      }
    }
  }
  
  func log(output: String, tag: any LoggingTag, category: String) {
    recorder.record((output, tag, category))
  }
  
  func persistToFile() throws -> URL {
    recorder.setPersistCalled()
    return returnURL
  }
  
  // Accessors for test
  func loggedMessages() async -> [(String, LoggingTag, String)] {
    recorder.all()
  }
  
  func didCallPersist() async -> Bool {
    recorder.wasPersistCalled()
  }
}
