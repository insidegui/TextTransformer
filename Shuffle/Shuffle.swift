//
//  Shuffle.swift
//  Shuffle
//
//  Created by Guilherme Rambo on 27/06/22.
//

import Foundation
import ExtensionFoundation
import ExtensionKit
import SwiftUI
import TextTransformerSDK

/// Sample extension that shuffles the input string and provides an "options" scene
/// with UI to toggle between also uppercasing the string when doing the shuffle.
@main
struct Shuffle: TextTransformUIExtension {
    fileprivate static let uppercaseEnabledKey = "uppercaseEnabled"
    
    init() { }
    
    var body: some TextTransformUIExtensionScene {
        TextTransformUIExtensionOptionsScene {
            ShuffleOptions()
        }
    }
    
    func transform(_ input: String) async -> String? {
        /// The uppercaseEnabled flag is written to UserDefaults by the `@AppStorage`
        /// property wrapper used in the `ShuffleOptions` view.
        if UserDefaults.standard.bool(forKey: Self.uppercaseEnabledKey) {
            return input.uppercased().shuffled().reduce("", { $0 + "\($1)" })
        } else {
            return input.shuffled().reduce("", { $0 + "\($1)" })
        }
    }
}

struct ShuffleOptions: View {
    
    @AppStorage(Shuffle.uppercaseEnabledKey)
    private var uppercaseEnabled = false
    
    var body: some View {
        Toggle("Also Uppercase", isOn: $uppercaseEnabled)
    }
    
}
