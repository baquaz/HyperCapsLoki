//
//  AppMenu.swift
//  HyperCapsLoki
//
//  Created by Piotr Błachewicz on 06/04/2025.
//

import SwiftUI
import HyperCapsLokiModule
import SharedAssets

public struct AppMenu: View {
  @Environment(AppState.self) private var appState
  @State private var appViewModel: AppMenuViewModel?
  @State private var presenter = LogsWindowPresenter()
  
  public init() { }
  
  public var body: some View {
    Group {
      if let appViewModel {
        AppMenuContent(vm: appViewModel)
      } else {
        Text("Loading app state...")
      }
    }.task {
      if let container = appState.container {
        if appViewModel == nil {
          appViewModel = AppMenuViewModel(
            defaultHyperkey: container.environment.defaultHyperkey,
            storageRepository: container.environment.storageRepository,
            loginItemUseCase: container.environment.loginItemUseCase,
            permissionUseCase: container.environment.permissionUseCase,
            hyperkeyFeatureUseCase: container.environment.hyperkeyFeatureUseCase,
            remapKeyUseCase: container.environment.remapKeyUseCase,
            exitUseCase: container.environment.exitUseCase
          )
        }
        
        appViewModel?.onSaveLogs = {
          let logsViewModel = LogsViewModel(logsUseCase:
                                              container.environment.logsUseCase)
          logsViewModel.reset()
          logsViewModel.saveLogs()
          presenter.show(using: logsViewModel)
        }
      }
    }
  }
}

// MARK: - App Menu Content
struct AppMenuContent: View {
  @Environment(AppState.self) private var appState
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Headline()
      PermissionInfoSection(vm: vm)
      SubHeadline()
      RemappingSection(vm: vm)
      Divider()
      HyperkeySequenceSection(vm: vm)
      Divider()
      BottomSection(vm: vm)
    }
    .padding(.all, 16)
    .frame(width: 420)
  }
}

// MARK: -
struct Headline: View {
  @Environment(AppState.self) private var appState
  
  var body: some View {
    HStack(alignment: .center, spacing: 16) {
      Image(nsImage: SharedAssets.logo)
        .resizable()
        .interpolation(.high)
        .scaledToFit()
        .frame(height: 64)
      
      VStack(alignment: .leading) {
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
struct PermissionInfoSection: View {
  @Environment(AppState.self) private var appState
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    if !appState.accessibilityPermissionGranted {
      HStack(alignment: .center) {
        Spacer()
        
        VStack {
          Button("Open Accessibility Settings") {
            vm.openAccessibilityPermissionSettings()
          }
          .buttonStyle(.borderedProminent)
          Text("App needs permission to track keyboard events")
        }
        
        Spacer()
      }
    }
  }
}

// MARK: -
struct SubHeadline: View {
  @Environment(AppState.self) private var appState
  
  var body: some View {
    Text("Settings")
      .font(.title3)
      .bold()
      .padding(.top, 16)
      .padding(.bottom, 4)
      .disabled(!appState.accessibilityPermissionGranted)
  }
}

// MARK: -
struct RemappingSection: View {
  @Environment(AppState.self) private var appState
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    VStack(alignment: .leading) {
      Button("Set Default Remapping") {
        vm.resetRemappingToDefault()
      }
      .buttonStyle(.bordered)
      .padding(.bottom, 10)
      .disabled(!appState.accessibilityPermissionGranted)
      
      HStack {
        Circle()
          .fill(
            (vm.isHyperkeyFeatureActive && appState.accessibilityPermissionGranted)
            ? Color.green : Color.secondary)
          .fixedSize()
        
        Text("Caps Lock remapped to:")
          .fixedSize()
          .opacity(
            (vm.isHyperkeyFeatureActive &&
             appState.accessibilityPermissionGranted) ? 1 : 0.6
          )
        
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
        .disabled(!appState.accessibilityPermissionGranted)
        
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
        .disabled(!appState.accessibilityPermissionGranted)
      }
      .padding(.horizontal, 4)
    }
  }
}

// MARK: -
struct HyperkeySequenceSection: View {
  @Environment(AppState.self) private var appState
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
              .grayscale(
                (vm.isSequenceEnabled(for: key) &&
                 appState.accessibilityPermissionGranted) ? 0 : 1.0
              )
              .opacity(
                (vm.isSequenceEnabled(for: key) &&
                 appState.accessibilityPermissionGranted) ? 1 : 0.2
              )
          }
          .toggleStyle(TopLabelCheckboxStyle())
          .frame(width: 70)
          .disabled(
            !vm.isHyperkeyFeatureActive ||
            !appState.accessibilityPermissionGranted
          )
          
          VStack {
            Text(key.alias.uppercased())
              .fixedSize()
              .font(.system(.headline, design: .default, weight: .bold))
            Rectangle()
              .fill(vm.getSequenceColor(for: index))
              .frame(height: 4)
          }
          .opacity(
            (vm.isSequenceEnabled(for: key) &&
             appState.accessibilityPermissionGranted) ? 1 : 0.1
          )
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
struct BottomSection: View {
  @Environment(AppState.self) private var appState
  @Bindable var vm: AppMenuViewModel
  
  var body: some View {
    VStack {
    
      HStack(alignment: .bottom) {
        Toggle(
          isOn:
            Binding(
              get: { vm.isOpenAtLoginEnabled },
              set: { newValue in
                vm.setLoginItem(newValue)
              })
        ) {
          Group {
            Text("Launch app on system login")
            Text("System Settings / Login Items & Extensions")
          }
          .padding(.leading, 4)
        }

        Spacer()
      }.padding(.bottom)
      
      HStack(spacing: 20) {
        Button("About") {
          // TODO: about info
        }
        .buttonStyle(.bordered)
        
        Spacer()
        
        Button("Save Logs") {
          vm.triggerSaveLogs()
        }
        .buttonStyle(.bordered)
//        .sheet(item: $vm.logsSaveResult) { result in
//          LogsResultSheet(result: vm.logsSaveResult) {
//            vm.clearSavedLogsResult()
//          }
//        }

        Button("Reset All") {
          vm.resetAll()
        }
        .buttonStyle(.bordered)
        .disabled(!appState.accessibilityPermissionGranted)
        
        Button("Quit ( ⌘Q )") {
          vm.quit()
        }
        .buttonStyle(.bordered)
      }
    }
  }
}

// MARK: - Preview
#Preview {
  let appState = AppState()
  appState.container = .init(environment: AppEnvironment.preview)
  
  return AppMenu()
    .environment(appState)
    .tint(SharedAssets.accentColor)
}
