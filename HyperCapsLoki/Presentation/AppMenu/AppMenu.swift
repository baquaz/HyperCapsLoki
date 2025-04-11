//
//  AppMenu.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import SwiftUI

struct AppMenu: View {
  @Environment(AppState.self) private var appState
  
  var body: some View {
    Group {
      if let container = appState.container {
        let vm = AppMenuViewModel(
          keyStorageRepository: container.environment.keyStorageRepository,
          remapKeyUseCase: container.environment.remapKeyUseCase
        )
        AppMenuContent(viewModel: vm)
      } else {
        Text("Loading app state...")
      }
    }
  }
}

struct AppMenuContent: View {
  @State var viewModel: AppMenuViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Hyper Key Loki Settings")
        .font(.title3)
        .bold()
        .padding()
      
      Picker("Caps Lock remapped to:", selection: $viewModel.selectedKey) {
        ForEach(viewModel.availableKeys, id: \.self) { key in
          HStack {
            Text(viewModel.textForKey(key))
              .font(.system(.body, design: .monospaced))
          }
        }
      }
      .pickerStyle(.menu)
      .onChange(of: viewModel.selectedKey, { oldValue, newValue in
        viewModel.onSelectKey(newValue)
      })
      
      HStack {
        Text("Selected: \(viewModel.selectedKey?.rawValue ?? "-")")
          .font(.system(.headline))
          .foregroundStyle(.foreground)
      }
      
      Divider()
      
      Button("Reset to Default") {
        viewModel.resetToDefault()
      }
      .buttonStyle(.bordered)
    }
    .padding()
    .frame(width: 280)
  }
}

#Preview {
  let appState = AppState()
  appState.container = .init(
    environment: .init(
      remapper: PreviewRemapExecutor(),
      eventsHandler: .init(),
      keyStorageRepository: PreviewKeyStorage(),
      launchUseCase: PreviewUseCase(),
      exitUseCase: PreviewUseCase(),
      remapKeyUseCase: PreviewUseCase()
    )
  )
  return AppMenu()
    .environment(appState)
}
