//
//  ScrollPreferenceKey.swift
//  Folders
//
//  Created by Cengizhan Tomak on 27.10.2023.
//

import SwiftUI

struct ScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
