//
//  AboutView.swift
//  HyperCapsLokiUI
//
//  Created by Piotr Błachewicz on 25/05/2025.
//

import SwiftUI
import SharedAssets

struct AboutView: View {
  var onDismiss: (() -> Void)?
  
  static let githubProfile = URL(string: "https://github.com/baquaz")
  static let githubLink = URL(string: "https://github.com/baquaz/HyperCapsLoki")!
  static let buyMeCoffeeLink = URL(string: "https://www.buymeacoffee.com/baquazan")!
  
  var body: some View {
    VStack(spacing: 16) {
      // App Icon
      Image(nsImage: NSApp.applicationIconImage)
        .resizable()
        .frame(width: 64, height: 64)
        .cornerRadius(12)
        .shadow(radius: 4)
      
      // App Name and Version
      Text(appName)
        .font(.title)
        .fontWeight(.bold)
      
      Text(appVersionString)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      
      // Links
      VStack(spacing: 10) {
        Link("GitHub Repository", destination: AboutView.githubLink)
          .padding(.bottom)
        Link("Buy Me a Coffee", destination: AboutView.buyMeCoffeeLink)
        
        // QR code image
        Link(destination: AboutView.buyMeCoffeeLink) {
          Image(nsImage: SharedAssets.buyMeCoffeeQR)
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding(.top, 8)
        }
      }
      
      Divider()
            
      HStack {
        Text("Credits:")
        Link("github.com/baquazan",
             destination: URL(string: "https://github.com/baquazan")!)

        Spacer()
        
        Button("OK") {
          onDismiss?()
        }
        .keyboardShortcut(.defaultAction)
        .buttonStyle(.borderedProminent)
      }
      .padding(.top)
    }
    .padding()
    .frame(minWidth: 350)
  }
  
  private var appName: String {
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
    ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
    ?? "Hyper Caps Loki"
  }
  
  private var appVersionString: String {
    let version = Bundle
      .main
      .infoDictionary?["CFBundleShortVersionString"] as? String
    ?? "Unknown"
    return "Version \(version)"
  }
}

// MARK: - Preview
#Preview {
  AboutView()
    .tint(SharedAssets.accentColor)
}
