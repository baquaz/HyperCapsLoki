//
//  File.swift
//  HyperCapsLokiModule
//
//  Created by Piotr Błachewicz on 25/05/2025.
//

import Foundation
import Testing
@testable import HyperCapsLokiModule
@testable import AppLogger

extension AppTests {
  
  @Suite("Log Engine Tests")
  struct LogEngineTests {
    
    @Test("On Error Persistsing Non Buffered Logs")
    func persistNonBufferedLogsError() async throws {
      let expectedError = NSError(domain: "AppLoggerEngine", code: 1,
                                  userInfo: nil)
      
      let testEnv = TestEnvironment()
        .withNonBufferedLogStrategy()
      
      let sut = LogEngine()
      sut.strategy = testEnv.mockNonBufferedLogStrategy
      
      #expect(throws: expectedError, performing: {
        _ = try sut.persistBufferedLogs()
      })
    }
    
    @Test("Persisting Logs To File")
    func persistLogsToFile() async throws {
      let expectedURL = URL(fileURLWithPath: "/dev/null")
      
      let testEnv = TestEnvironment()
        .withBufferedLogStrategy()
      
      let sut = LogEngine()
      sut.strategy = testEnv.mockBufferedLogStrategy
      
      
      let resultURL = try sut.persistBufferedLogs()
      #expect(resultURL == expectedURL)
      #expect(await testEnv.mockBufferedLogStrategy.recorder.persistCalled)
    }
  }
}
