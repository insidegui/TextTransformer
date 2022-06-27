//
//  TextTransformExtensionHost.swift
//  TextTransformerKit
//
//  Created by Guilherme Rambo on 27/06/22.
//

import Cocoa
import ExtensionFoundation
import ExtensionKit
@_spi(TextTransformerXPC) import TextTransformerSDK

public struct TextTransformExtensionInfo: Identifiable, Hashable {
    
    public let id: String
    public let name: String
    let identity: AppExtensionIdentity
    
    init(with identity: AppExtensionIdentity) {
        self.id = identity.bundleIdentifier
        self.name = identity.localizedName
        self.identity = identity
    }
    
}

public final class TextTransformExtensionHost: ObservableObject {
    
    public init() { }
    
    @Published
    public private(set) var extensions: [TextTransformExtensionInfo] = []
    
    private var activated = false
    
    public func activate() {
        guard !activated else { return }
        activated = true
        
        Task { await discoveryTask() }
    }
    
    private func discoveryTask() async {
        do {
            let sequence = try AppExtensionIdentity.matching(appExtensionPointIDs: "codes.rambo.experiment.TextTransformer.extension")
            for await identities in sequence {
                await MainActor.run {
                    self.extensions = identities.map { TextTransformExtensionInfo(with: $0) }
                }
            }
        } catch {
            assertionFailure("Extension discovery failed: \(error)")
        }
    }
    
    public var availability: AsyncStream<AppExtensionIdentity.Availability> { AppExtensionIdentity.availabilityUpdates }
    
    private lazy var managerWindowController: NSWindowController = {
        let window = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "Extension Manager"
        let c = NSWindowController(window: window)
        let browser = EXAppExtensionBrowserViewController()
        browser.preferredContentSize = NSSize(width: 460, height: 280)
        c.contentViewController = browser
        return c
    }()
    
    public func showExtensionManager() {
        managerWindowController.showWindow(nil)
        managerWindowController.window?.center()
    }
    
    public func transform(_ input: String, using ext: TextTransformExtensionInfo) async throws -> String {
        let config = AppExtensionProcess.Configuration(appExtensionIdentity: ext.identity)
        let proc = try await AppExtensionProcess(configuration: config)
        
        let client = TextTransformerExtensionXPCClient(with: proc)
        
        let response = try await client.runOperation(with: input)
        
        return response
    }
    
}
