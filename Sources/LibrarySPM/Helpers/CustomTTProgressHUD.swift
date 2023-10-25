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
            TTProgressHUD($IsVisible, config: TTProgressHUDConfig(
                type: HudType,
                imageViewSize: CGSize(width: UIDevice.current.userInterfaceIdiom == .pad ? 150 : 75, height: UIDevice.current.userInterfaceIdiom == .pad ? 150 : 75)
            ))
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 500 : 250, maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? 500 : 250)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: TimeInterval, repeats: false) { _ in
                    self.IsVisible = false
                }
            }
        }
    }
}
