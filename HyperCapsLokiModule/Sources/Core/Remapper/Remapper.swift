//
//  Remapper.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 26/01/2025.
//

import Foundation

/// Protocol defining operations for remapping and resetting the Caps Lock key.
public protocol RemapExecutor {
  /// Remaps the Caps Lock key to another key defined by the user.
  ///
  /// - Parameter key: The target key to which Caps Lock should be remapped.
  func remapUserKeyMappingCapsLock(using key: Key)

  /// Resets the user key mapping for Caps Lock to its original behavior.
  func resetUserKeyMappingCapsLock()
}

public struct Remapper: RemapExecutor {

  /// Provider for HID usage codes and key mappings.
  let keysProvider: KeysProvider

  /// HID usage value representing the Caps Lock key.
  private var capsLockUsage: Int {
    keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad,
                                    usage: kHIDUsage_KeyboardCapsLock)
  }

  // MARK: - Init

  /// Initializes a new `Remapper` instance.
  ///
  /// - Parameter keysProvider: Dependency for resolving key-to-HID usage mapping.
  init(keysProvider: KeysProvider = .shared) {
    self.keysProvider = keysProvider
  }

  // MARK: - Remap

  /// Remaps the Caps Lock key to a different key by modifying the user key mapping via `hidutil`.
  ///
  /// - Parameter key: The target key to map Caps Lock to.
  public func remapUserKeyMappingCapsLock(using key: Key) {
    guard let destinationUsageCode = keysProvider.hidUsageCode(for: key) else {
      Applog.print(
        tag: .critical,
        context: .keyRemapping,
        key.rawValue,
        "key not found."
      )
      return
    }
    let destinationUsage = keysProvider.makeHIDUsageNumber(page: kHIDPage_KeyboardOrKeypad, usage: destinationUsageCode)

    Applog.print(context: .keyRemapping, "Remapping Caps Lock...")

    var userKeyMapping = getCurrentUserKeyMapping()

    // remove any existing Caps Lock remap
    removeCapsLockRemapping(from: &userKeyMapping)

    // add new remap
    userKeyMapping.append([
      "HIDKeyboardModifierMappingSrc": capsLockUsage, // Caps Lock (0x700000039)
      "HIDKeyboardModifierMappingDst": destinationUsage
    ])

    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"

        _ = shell(command)
        Applog.print(context: .keyRemapping,
                     "Caps Lock remapped to \(key.rawValue).")
      }
    } catch {
      Applog.print(
        tag: .critical,
        context: .keyRemapping,
        "Error serializing UserKeyMapping JSON: \(error)"
      )
    }
  }

  // MARK: - Reset

  /// Removes any custom Caps Lock remapping, restoring it to default behavior.
  public func resetUserKeyMappingCapsLock() {
    var userKeyMapping = getCurrentUserKeyMapping()

    // remove any existing Caps Lock remap
    removeCapsLockRemapping(from: &userKeyMapping)

    do {
      let data = try JSONSerialization.data(withJSONObject: userKeyMapping, options: [])
      if let jsonString = String(data: data, encoding: .utf8) {
        let command = "hidutil property --set '{\"UserKeyMapping\": \(jsonString)}'"

        _ = shell(command)
        Applog.print(context: .keyRemapping, "Caps Lock remapping has been removed.")
      }
    } catch {
      Applog.print(
        tag: .critical,
        context: .keyRemapping,
        "Error serializing UserKeyMapping JSON: \(error)"
      )
    }
  }

  /// Removes all entries in the user key mapping that remap the Caps Lock key.
  ///
  /// - Parameter userKeyMapping: The current user key mapping list, passed as `inout`.
  private func removeCapsLockRemapping(from userKeyMapping: inout [[String: Any]]) {
    let capsLockUsage = self.capsLockUsage

    userKeyMapping.removeAll {
      guard let src = $0["HIDKeyboardModifierMappingSrc"] else { return false }

      let intValue: Int? = {
        if let val = src as? Int {
          val
        } else if let val = src as? NSNumber {
          val.intValue
        } else if let val = src as? String {
          Int(val)
        } else {
          nil
        }
      }()

      return intValue == capsLockUsage
    }
  }

  // MARK: - Current User Key Mapping

  /// Retrieves the current user key mapping using `hidutil`.
  ///
  /// - Returns: A list of key remapping dictionaries, or an empty array if none exist.
  private func getCurrentUserKeyMapping() -> [[String: Any]] {
    let command = "hidutil property --get \"UserKeyMapping\""
    let output = shell(command)

    guard let data = output.data(using: .utf8) else {
      Applog.print(
        tag: .critical,
        context: .keyRemapping,
        "Failed to convert shell output to data"
      )
      return []
    }
    do {
      let plist = try PropertyListSerialization.propertyList(from: data, format: nil)

      if let mappings = plist as? [[String: Any]] {
        return mappings

      } else if let dict = plist as? [String: Any],
                let mappings = dict["UserKeyMapping"] as? [[String: Any]] {
        return mappings
      } else {
        return []
      }
    } catch {
      Applog.print(
        tag: .critical,
        context: .keyRemapping,
        error.localizedDescription
      )
      return []
    }
  }

  // MARK: - Shell Executor

  /// Executes a shell command and returns the output.
  ///
  /// - Parameter command: The shell command to run.
  /// - Returns: Standard output from the shell command as a string.
  private func shell(_ command: String) -> String {
    let task = Process()

    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    return output
  }
}
