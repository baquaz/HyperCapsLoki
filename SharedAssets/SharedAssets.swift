//
//  SharedAssets.swift
//  HyperCapsLokiUI
//
//  Created by Piotr Błachewicz on 11/05/2025.
//

import SwiftUI

public enum SharedAssets {

  // Images
  public static var logo: NSImage {
    NSImage(resource: .logo)
  }

  public static var buyMeCoffeeQR: NSImage {
    NSImage(resource: .bmcQr)
  }

  // Colors
  public static var accentColor: Color {
    return Color(.accent)
  }

  public static var themeBold: Color {
    return Color(.themeBold)
  }

  public static var themePrimary: Color {
    Color(.themePrimary)
  }

  public static var themeSecondary: Color {
    Color(.themeSecondary)
  }

  public static var themeTertiary: Color {
    Color(.themeTertiary)
  }
}
