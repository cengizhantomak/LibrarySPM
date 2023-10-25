//
//  NoEffectButtonStyle.swift
//  Folders
//
//  Created by Cengizhan Tomak on 20.10.2023.
//

import SwiftUI

struct NoEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
