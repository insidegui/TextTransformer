import Cocoa
import SwiftUI
import ExtensionFoundation
import ExtensionKit
@_spi(TextTransformerSPI) import TextTransformerSDK

extension TextTransformExtensionHost {
    
    /// Returns a SwiftUI view for the extension's "options" scene.
    /// - Parameter appExtension: The extension  to get the options scene for (must be a UI extension).
    /// - Returns: A SwiftUI view that renders and controls the extension's options UI.
    func optionsView(for appExtension: TextTransformExtensionInfo) -> some View {
        assert(appExtension.hasUI, "Tried to get view for an app extension that doesn't provide UI: \(appExtension)")
        return TextTransformerUIExtensionHostViewWrapper(appExtension: appExtension)
    }
    
}

// MARK: - SwiftUI Integration

struct TextTransformerUIExtensionHostViewWrapper: View {
    
    var appExtension: TextTransformExtensionInfo
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TextTransformerUIExtensionHostView(with: appExtension)
            .frame(minWidth: 260, minHeight: 120, idealHeight: 120, maxHeight: .infinity)
    }
    
}

struct TextTransformerUIExtensionHostView: NSViewControllerRepresentable {
    
    typealias NSViewControllerType = TextTransformerExtensionUIController
    
    let appExtension: TextTransformExtensionInfo
    
    init(with appExtension: TextTransformExtensionInfo) {
        self.appExtension = appExtension
    }
    
    func makeNSViewController(context: Context) -> TextTransformerExtensionUIController {
        TextTransformerExtensionUIController(with: appExtension)
    }
    
    func updateNSViewController(_ nsViewController: TextTransformerExtensionUIController, context: Context) {
        
    }
    
}

final class TextTransformerExtensionUIController: NSViewController, EXHostViewControllerDelegate {
    
    let identity: AppExtensionIdentity
    
    init(with appExtension: TextTransformExtensionInfo) {
        self.identity = appExtension.identity
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private lazy var host: EXHostViewController = {
        let c = EXHostViewController()
        c.configuration = EXHostViewController.Configuration(appExtension: identity, sceneID: TextTransformUIExtensionOptionsSceneID)
        c.delegate = self
        c.placeholderView = NSHostingView(rootView: TextTransformUIExtensionPlaceholderView())
        return c
    }()
    
    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func shouldAccept(_ connection: NSXPCConnection) -> Bool {
        connection.resume()
        return true
    }
    
    func hostViewControllerWillDeactivate(_ viewController: EXHostViewController, error: Error?) {
        assert(error == nil, "Host view controller deactivating due to error: \(error!)")
    }
    
    func hostViewControllerDidActivate(_ viewController: EXHostViewController) {
        print("Host view controller activated")
    }
    
}

