//
//  Uppercase.swift
//  Uppercase
//
//  Created by Guilherme Rambo on 27/06/22.
//

import Foundation
import ExtensionFoundation
import TextTransformerKit
import OSLog

let logger = Logger(subsystem: "codes.rambo.ExtensionProvider", category: "TextTransformerKit-ProviderTest")

///// The AppExtensionConfiguration that will be provided by this extension.
///// This is typically defined by the extension host in a framework.
//struct ExampleConfiguration<E:ExampleExtension>: AppExtensionConfiguration {
//
//    let appExtension: E
//
//    init(_ appExtension: E) {
//        self.appExtension = appExtension
//    }
//
//    /// Determine whether to accept the XPC connection from the host.
//    func accept(connection: NSXPCConnection) -> Bool {
//        // TODO: Configure the XPC connection and return true
//        return false
//    }
//}
//
///// The AppExtension protocol to which this extension will conform.
///// This is typically defined by the extension host in a framework.
//protocol ExampleExtension : AppExtension { }
//
//extension ExampleExtension {
//    var configuration: ExampleConfiguration<some ExampleExtension> {
//        // Return your extension's configuration upon request.
//        return ExampleConfiguration(self)
//    }
//}

@main
class Uppercase: TextTransformExtension {
    typealias Configuration = TextTransformExtensionConfiguration<Uppercase>
    
    var configuration: Configuration {
        Configuration(self)
    }
    
    func transform(_ input: String) async -> String? {
        input.uppercased()
    }
    
    required init() {
        logger.log("Uppercase extension initialized")
    }
}
