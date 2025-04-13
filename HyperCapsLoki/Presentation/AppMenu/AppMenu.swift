//
//  AppMenu.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import SwiftUI

struct AppMenu: View {
  @Environment(AppState.self) private var appState
  @State private var vm: AppMenuViewModel?
  
  var body: some View {
    Group {
      if let vm {
        AppMenuContent(vm: vm)
      } else {
        Text("Loading app state...")
      }
    }.task {
      if vm == nil, let container = appState.container {
        vm = AppMenuViewModel(
          defaultHyperkey: container.environment.defaultHyperkey,
          storageRepository: container.environment.storageRepository,
          hyperkeyFeatureUseCase: container.environment.hyperkeyFeatureUseCase,
          remapKeyUseCase: container.environment.remapKeyUseCase,
          exitUseCase: container.environment.exitUseCase
        )
      }
    }
  }
}

// MARK: - App Menu Content
struct AppMenuContent: View {
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Headline()
      SubHeadline()
      RemappingSection(vm: vm)
      Divider()
      HyperkeySequenceSection(vm: vm)
      Divider()
      BottonSection(vm: vm)
    }
    .padding(.all, 16)
    .frame(width: 400)
  }
}

// MARK: -
struct Headline: View {
  var body: some View {
    HStack(alignment: .bottom, spacing: 16) {
      Image(.logo)
        .resizable()
        .interpolation(.high)
        .scaledToFit()
        .frame(height: 64)
      
      VStack {
        Spacer()
        Text("Hyper Caps Loki")
          .font(.title3)
          .fixedSize()
        Spacer()
      }
    }
    .padding(.horizontal, -5)
  }
}

// MARK: -
struct SubHeadline: View {
  var body: some View {
    Text("Settings")
      .font(.title3)
      .bold()
      .padding(.top, 16)
      .padding(.bottom, 4)
  }
}

// MARK: -
struct RemappingSection: View {
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    VStack(alignment: .leading) {
      Button("Set Default Remapping") {
        vm.resetRemappingToDefault()
      }
      .buttonStyle(.bordered)
      .padding(.bottom, 10)
      
      HStack {
        Circle()
          .fill(vm.isHyperkeyFeatureActive ? Color.green : Color.secondary)
          .fixedSize()
        
        Text("Caps Lock remapped to:")
          .fixedSize()
          .opacity(vm.isHyperkeyFeatureActive ? 1 : 0.6)
        
        Picker("", selection: $vm.selectedKey) {
          ForEach(vm.availableKeys, id: \.self) { key in
            Text(vm.getTextForKey(key))
              .font(.system(.body, design: .monospaced))
          }
        }
        .pickerStyle(.menu)
        .fixedSize()
        .onChange(of: vm.selectedKey, { oldValue, newValue in
          vm.onSelectKey(newValue)
        })
        
        Spacer()
        
        Toggle(
          "",
          isOn:
            Binding(
              get: { vm.isHyperkeyFeatureActive },
              set: { newValue in
                vm.setActiveStatus(newValue)
              })
        )
        .toggleStyle(.checkbox)
      }
      .padding(.horizontal, 4)
    }
  }
}

// MARK: -
struct HyperkeySequenceSection: View {
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    HStack(spacing: 4) {
      Spacer()
      ForEach(Array(vm.allHyperkeySequenceKeys.enumerated()), id: \.offset) { index, key in
        VStack {
          Toggle(
            isOn: Binding(
              get: { vm.isSequenceEnabled(for: key) },
              set: { isOn in
                vm.setHyperkeySequence(enabled: isOn, for: key)
              })
          ) {
            Text(key.symbol)
              .grayscale(vm.isSequenceEnabled(for: key) ? 0 : 1.0)
              .opacity(vm.isSequenceEnabled(for: key) ? 1 : 0.2)
          }
          .toggleStyle(TopLabelCheckboxStyle())
          .frame(width: 70)
          .disabled(!vm.isHyperkeyFeatureActive)
          
          VStack {
            Text(key.alias.uppercased())
              .fixedSize()
              .font(.system(.headline, design: .default, weight: .bold))
            Rectangle()
              .fill(vm.getSequenceColor(for: index))
              .frame(height: 4)
          }
          .opacity(vm.isSequenceEnabled(for: key) ? 1 : 0.1)
        }
        Spacer()
      }
    }
  }
}

// MARK: Top Label Checkbox Style
struct TopLabelCheckboxStyle: ToggleStyle {
  func makeBody(configuration: Configuration) -> some View {
    Button(action: {
      configuration.isOn.toggle()
    }) {
      VStack(spacing: 16) {
        configuration.label
          .font(.largeTitle)
          .lineLimit(1)
          .frame(maxWidth: .infinity)
        
        Image(systemName: configuration.isOn ? "checkmark.square" : "square")
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .frame(maxWidth: .infinity)
      }
      .padding(.top, 2)
      .padding(.bottom, 18)
      .contentShape(Rectangle())
    }
    .buttonStyle(PlainButtonStyle())
    .background(Color.clear)
    //    .background(Color.red.opacity(0.3)) // debug tap area
  }
}

// MARK: -
struct BottonSection: View {
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    HStack(spacing: 20) {
      Spacer()
      
      Button("Reset All") {
        vm.resetAll()
      }
      
      .buttonStyle(.bordered)
      Button("Quit ( ⌘Q )") {
        vm.quit()
      }
      .buttonStyle(.bordered)
    }
  }
}

// MARK: - Preview
#Preview {
  let appState = AppState()
  appState.container = .init(environment: .preview)
  
  return AppMenu()
    .environment(appState)
}
