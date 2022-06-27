import Foundation
import ExtensionFoundation

/// Protocol implemented by text transform extensions.
///
/// You create a struct conforming to this protocol and implement the ``transform(_:)`` method
/// in order to perform the custom text transformation that your extension provides to the app.
public protocol TextTransformExtension: AppExtension {
    
    /// Transform the input string according to your extension's behavior
    /// - Parameter input: The text entered by the user in TextTransformer.
    /// - Returns: The output that should be shown to the user, or `nil` if the transformation failed.
    func transform(_ input: String) async -> String?
    
}

/// Configuration for extensions that conform to the ``TextTransformExtension`` protocol.
public struct TextTransformExtensionConfiguration<E: TextTransformExtension>: AppExtensionConfiguration {
    let appExtension: E
    let server: TextTransformerExtensionXPCServer
    
    /// Creates a default configuration for the given extension.
    /// - Parameter appExtension: An instance of your custom extension that conforms to the ``TextTransformExtension`` protocol.
    public init(_ appExtension: E) {
        self.appExtension = appExtension
        self.server = TextTransformerExtensionXPCServer(with: appExtension)
    }
}
