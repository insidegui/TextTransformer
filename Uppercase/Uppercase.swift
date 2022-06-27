//
//  Uppercase.swift
//  Uppercase
//
//  Created by Guilherme Rambo on 27/06/22.
//

import Foundation
import ExtensionFoundation
import TextTransformerSDK

/// Sample extension that transforms the input into its uppercase representation.
@main
struct Uppercase: TextTransformExtension {
    typealias Configuration = TextTransformExtensionConfiguration<Uppercase>
    
    var configuration: Configuration { Configuration(self) }
    
    func transform(_ input: String) async -> String? {
        input.uppercased()
    }
    
    init() { }
}
