//
//  ContentView.swift
//  TextTransformer
//
//  Created by Guilherme Rambo on 27/06/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var host = TextTransformExtensionHost()
    
    @State private var automaticSelectionUIShown = false
    
    @State var text = ""
    
    @State var selectedExtension: TextTransformExtensionInfo?
    
    @State var configuringExtension: TextTransformExtensionInfo?

    @State var isLoading = false
    
    var body: some View {
        Form {
            HStack {
                Picker("Extension", selection: $selectedExtension) {
                    if selectedExtension == nil {
                        Text("Select")
                            .tag(Optional<TextTransformExtensionInfo>.none)
                    }
                    
                    ForEach(host.extensions) { info in
                        Text(info.name)
                            .tag(Optional<TextTransformExtensionInfo>.some(info))
                    }
                }
                .disabled(host.extensions.isEmpty)
                
                if let selectedExtension, selectedExtension.hasUI {
                    Button {
                        configuringExtension = selectedExtension
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .help("Configure \(selectedExtension.name)")
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .popover(item: $configuringExtension) { appExtension in
                        host.optionsView(for: appExtension)
                    }
                }
            }
            
            HStack {
                TextField("Text To Transform", text: $text)
                    .labelsHidden()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                } else {
                    Button("Transform") { performRequest() }
                        .controlSize(.large)
                        .keyboardShortcut(.defaultAction)
                        .disabled(selectedExtension == nil)
                }
            }
            
            Button("Manage Extensions…") { presentExtensionSelection() }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
        .task {
            for await availability in host.availability {
                if availability.enabledCount >= 0 { automaticSelectionUIShown = true }
                
                if availability.unapprovedCount > 0, !automaticSelectionUIShown {
                    automaticSelectionUIShown = true
                    presentExtensionSelection()
                }
            }
        }
        .onAppear(perform: host.activate)
    }
    
    private func presentExtensionSelection() {
        host.showExtensionManager()
    }
    
    private func performRequest() {
        guard let selectedExtension else { return }
        
        isLoading = true
        
        Task {
            do {
                let result = try await host.transform(text, using: selectedExtension)
                
                text = result
            } catch {
                text = "ERROR: \(error)"
            }

            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
