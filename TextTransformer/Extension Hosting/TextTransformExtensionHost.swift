import Cocoa
import SwiftUI
import ExtensionFoundation
import ExtensionKit
@_spi(TextTransformerSPI) import TextTransformerSDK

enum TextTransformExtensionPoint: String, CaseIterable {
    case nonUI = "codes.rambo.experiment.TextTransformer.extension"
    case UI = "codes.rambo.experiment.TextTransformer.uiextension"
}

struct TextTransformExtensionInfo: Identifiable, Hashable {
    
    let id: String
    let name: String
    let identity: AppExtensionIdentity
    let extensionPoint: TextTransformExtensionPoint
    
    init(with identity: AppExtensionIdentity) {
        guard let extPoint = TextTransformExtensionPoint(rawValue: identity.extensionPointIdentifier) else {
            preconditionFailure("Received an extension with invalid extension point: \(identity)")
        }
        
        self.id = identity.bundleIdentifier
        self.name = identity.localizedName
        self.identity = identity
        self.extensionPoint = extPoint
    }
    
    var hasUI: Bool { extensionPoint == .UI }
    
}

final class TextTransformExtensionHost: ObservableObject {
    
    init() { }
    
    @Published
    private(set) var extensions: [TextTransformExtensionInfo] = []
    
    private var activated = false
    
    func activate() {
        guard !activated else { return }
        activated = true
        
        Task { await discoveryTask() }
    }
    
    private func discoveryTask() async {
        do {
            let sequence = try AppExtensionIdentity.matching(
                appExtensionPointIDs: TextTransformExtensionPoint.nonUI.rawValue, TextTransformExtensionPoint.UI.rawValue
            )
            for await identities in sequence {
                await MainActor.run {
                    self.extensions = identities.map { TextTransformExtensionInfo(with: $0) }
                }
            }
        } catch {
            assertionFailure("Extension discovery failed: \(error)")
        }
    }
    
    var availability: AsyncStream<AppExtensionIdentity.Availability> { AppExtensionIdentity.availabilityUpdates }
    
    private lazy var managerWindowController: NSWindowController = {
        let window = NSPanel(contentRect: NSRect(x: 0, y: 0, width: 200, height: 200), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        window.title = "Extension Manager"
        let c = NSWindowController(window: window)
        let browser = EXAppExtensionBrowserViewController()
        browser.preferredContentSize = NSSize(width: 460, height: 280)
        c.contentViewController = browser
        return c
    }()
    
    func showExtensionManager() {
        managerWindowController.showWindow(nil)
        managerWindowController.window?.center()
    }
    
    func transform(_ input: String, using ext: TextTransformExtensionInfo) async throws -> String {
        let config = AppExtensionProcess.Configuration(appExtensionIdentity: ext.identity)
        let proc = try await AppExtensionProcess(configuration: config)
        
        let client = TextTransformerExtensionXPCClient(with: proc)
        
        let response = try await client.runOperation(with: input)
        
        return response
    }
    
}

