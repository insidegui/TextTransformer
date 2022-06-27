#if os(macOS)
import Foundation
import ExtensionFoundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

@_spi(TextTransformerSPI)
@objc public protocol TextTransformerXPCProtocol: NSObjectProtocol {
    func transform(input: String, reply: @escaping (String?) -> Void)
}

@objc final class TextTransformerExtensionXPCServer: NSObject, TextTransformerXPCProtocol {
    
    let implementation: any TextTransformExtension
    
    init(with implementation: some TextTransformExtension) {
        self.implementation = implementation
    }
    
    func transform(input: String, reply: @escaping (String?) -> Void) {
        Task {
            let result = await implementation.transform(input)
            await MainActor.run { reply(result) }
        }
    }
    
}
#endif
