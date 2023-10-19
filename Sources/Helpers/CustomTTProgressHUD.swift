//
//  CustomTTProgressHUD.swift
//  Folders
//
//  Created by Cengizhan Tomak on 20.09.2023.
//

import SwiftUI
import TTProgressHUD

struct CustomTTProgressHUD: View {
    @Binding var IsVisible: Bool
    var HudType: TTProgressHUDType
    var TimeInterval: Double = 0.7
    
    var body: some View {
        if IsVisible {
            TTProgressHUD($IsVisible, config: .init(type: HudType))
                .scaleEffect(0.5)
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: TimeInterval, repeats: false) { _ in
                        self.IsVisible = false
                    }
                }
        }
    }
}
