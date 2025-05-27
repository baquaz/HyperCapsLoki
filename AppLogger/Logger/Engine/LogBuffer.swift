//
//  LogBuffer.swift
//  AppLogger
//
//  Created by Piotr Błachewicz on 12/05/2025.
//

import Foundation

public protocol LogBuffering: Sendable {
  var maxByteSize: Int { get }

  func add(_ message: String)
  func dump() -> [String]
}

public final class DefaultLogBuffer: @unchecked Sendable, LogBuffering {
  public static let shared = DefaultLogBuffer()
  private var buffer = [String]()
  private let queue = DispatchQueue(label: "log.buffer.queue", qos: .utility)

  public var maxByteSize: Int = 500
  private var logs: [String] = []

  public func add(_ log: String) {
    queue.async {
      if self.logs.count >= self.maxByteSize {
        self.logs.removeFirst()
      }
      self.logs.append(log)
    }
  }

  public func dump() -> [String] {
    queue.sync { logs }
  }

  func clear() {
    queue.async { self.logs.removeAll() }
  }
}
