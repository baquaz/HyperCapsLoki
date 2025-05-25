//
//  File.swift
//  HyperCapsLokiUI
//
//  Created by Piotr Błachewicz on 15/05/2025.
//

import SwiftUI
import HyperCapsLokiModule

struct LogsResultSheet: View {
  @Bindable var vm: LogsViewModel
  
  var body: some View {
    if let result = vm.saveLogsResult {
      
      VStack(spacing: 20) {
        Text(result.isSuccess ? "✅ Logs saved successfully!" : "⚠️ Error")
          .font(.headline)
        
        VStack(alignment: .leading) {
          Text(
            result
              .isSuccess
            ? "Logs path:"
            : "Failed to save logs.\n\(result.error?.localizedDescription ?? "")"
          )
          .font(.caption)
          
          if result.isSuccess {
            LogsPathView(
              text: result.url?.path ?? "",
              maxLines: 4,
              onCopy: vm.copyToClipboardSavedLogsPath
            )
          }
          
          if vm.isToastConfirmationVisible {
            Text("Copied to clipboard")
              .font(.caption2)
              .padding(6)
              .background(Color.black.opacity(0.75))
              .foregroundColor(.white)
              .cornerRadius(6)
              .transition(.opacity.combined(with: .scale))
              .frame(maxWidth: .infinity, alignment: .center)
          }
        }
        .padding(.bottom)
        .animation(
          .easeInOut(duration: 0.2),
          value: vm.isToastConfirmationVisible
        )
        
        HStack() {
          if let url = result.url {
            Button("Show in Finder") {
              vm.showInFinderSavedLogs(url)
            }
          }
          
          Spacer()
          
          Button("Dismiss") {
            vm.dismiss()
          }
        }
      }
      .padding()
      .frame(minWidth: 350)
    }
    
  }
}

// MARK: - Preview
#Preview {
  let success = LogSaveResult.success(URL(fileURLWithPath: "/tmp/test.log"))
  let failure = LogSaveResult.failure(
    NSError(
      domain: "Logs",
      code: 1,
      userInfo: [NSLocalizedDescriptionKey: "Oops!"]
    )
  )
  
  let vm = LogsViewModel(logsUseCase: PreviewUseCase())
  vm.saveLogsResult = success
  return LogsResultSheet(vm: vm)
}

struct LogsResultSheet_Previews: PreviewProvider {
  static var vmSuccess: LogsViewModel {
    let success = LogSaveResult.success(URL(fileURLWithPath: "/tmp/test.log"))
    
    let vm = LogsViewModel(logsUseCase: PreviewUseCase())
    vm.saveLogsResult = success
    return vm
  }
  
  static var vmFailure: LogsViewModel {
    let failure = LogSaveResult.failure(
      NSError(
        domain: "Logs",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Oops!"]
      )
    )
    
    let vm = LogsViewModel(logsUseCase: PreviewUseCase())
    vm.saveLogsResult = failure
    return vm
  }
  
  static var previews: some View {
    Group {
      LogsResultSheet(vm: vmSuccess)
        .previewDisplayName("Success")
      
      LogsResultSheet(vm: vmFailure)
        .previewDisplayName("Failure")
    }
  }
}
