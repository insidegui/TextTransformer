import Foundation
import ExtensionFoundation

extension TextTransformExtensionConfiguration {
    /// You don't call this method, it is implemented by TextTransformerKit and used internally by ExtensionKit.
    public func accept(connection: NSXPCConnection) -> Bool {
        connection.exportedInterface = NSXPCInterface(with: TextTransformerXPCProtocol.self)
        connection.exportedObject = server
        
        connection.resume()
        
        return true
    }
}
