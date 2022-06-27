//
//  TextTransformerXPCProtocol.swift
//  TextTransformerKit
//
//  Created by Guilherme Rambo on 27/06/22.
//

import Foundation
import ExtensionFoundation

extension String: LocalizedError {
    public var errorDescription: String? { self }
}

@objc protocol TextTransformerXPCProtocol: NSObjectProtocol {
    func transform(input: String, reply: @escaping (String?) -> Void)
}

final class TextTransformerExtensionXPCClient: NSObject {
    
    let process: AppExtensionProcess
    
    init(with process: AppExtensionProcess) {
        self.process = process
    }
    
    private var currentConnection: NSXPCConnection?
    
    func runOperation(with input: String) async throws -> String {
        var done = false
        
        let connection = try process.makeXPCConnection()
        connection.remoteObjectInterface = NSXPCInterface(with: TextTransformerXPCProtocol.self)
        
        connection.resume()
        
        currentConnection = connection
        
        return try await withCheckedThrowingContinuation { continuation in
            defer { currentConnection = nil }
            
            guard let service = connection.remoteObjectProxyWithErrorHandler({ error in
                if !done {
                    continuation.resume(throwing: error)
                }
            }) as? TextTransformerXPCProtocol else {
                continuation.resume(throwing: "Couldn't communicate with the extension")
                return
            }
            
            service.transform(input: input) { result in
                done = true
                
                if let result {
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: "Extension returned nil response")
                }
            }
        }
    }
    
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
