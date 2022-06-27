import Foundation
import ExtensionKit
import SwiftUI

@_spi(TextTransformerSPI)
public let TextTransformUIExtensionOptionsSceneID = "options-scene"

/// Protocol implemented by text transform extensions that also provide a view for configuration options.
///
/// You create a struct conforming to this protocol and implement the ``transform(_:)`` method
/// in order to perform the custom text transformation that your extension provides to the app, just like the non-ui variant (``TextTransformExtension``).
///
/// Extensions also implement the ``body-swift.property`` property, providing a scene with the user interface to configure
/// settings specific to the functionality of this extension.
public protocol TextTransformUIExtension: TextTransformExtension where Configuration == AppExtensionSceneConfiguration {
    
    associatedtype Body: TextTransformUIExtensionScene
    var body: Body { get }
    
}

/// Protocol implemented by scenes that can be used in ``TextTransformUIExtension/body-swift.property``.
public protocol TextTransformUIExtensionScene: AppExtensionScene {}

/// A concrete implementation of ``TextTransformUIExtensionScene`` that provides a form where the user can configure options for a given extension.
/// You return an instance of this scene type from the ``TextTransformUIExtension/body-swift.property`` property.
///
/// The content of the scene is where you create your user interface, using SwiftUI.
/// Do not use any property wrappers that invalidate the view hierarchy directly in your extension, wrap your UI in a custom view type
/// and add any property wrappers to the view.
public struct TextTransformUIExtensionOptionsScene<Content>: TextTransformUIExtensionScene where Content: View {
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    private let content: () -> Content
    
    public var body: some AppExtensionScene {
        PrimitiveAppExtensionScene(id: TextTransformUIExtensionOptionsSceneID) {
            TextTransformUIExtensionOptionsContainer(content: content)
        } onConnection: { connection in
            connection.resume()
            
            return true
        }
    }
}

@_spi(TextTransformerSPI)
public struct TextTransformUIExtensionOptionsContainer<Content>: View where Content: View {
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    private let content: () -> Content
    
    public var body: some View {
        Form {
            content()
        }
        .formStyle(.grouped)
        .frame(minWidth: 280)
        .padding()
    }
    
}

@_spi(TextTransformerSPI)
public struct TextTransformUIExtensionPlaceholderView: View {
    
    public init() { }
    
    public var body: some View {
        TextTransformUIExtensionOptionsContainer {
            Toggle("Placeholder Label", isOn: .constant(false))
        }
        .redacted(reason: .placeholder)
    }
    
}

public extension TextTransformUIExtension {
    /// The configuration for the UI extension. You do not call this directly, it is implemented by TextTransformerSDK on your behalf.
    var configuration: AppExtensionSceneConfiguration {
        AppExtensionSceneConfiguration(
            self.body,
            configuration: TextTransformExtensionConfiguration(self)
        )
    }
}
