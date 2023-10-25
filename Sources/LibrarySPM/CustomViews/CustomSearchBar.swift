//
//  CustomSearchBar.swift
//  Folders
//
//  Created by Kerem Tuna Tomak on 3.10.2023.
//

import SwiftUI

struct CustomSearchBar: View {
    var Placeholder: String
    @Binding var Text: String
    
    var body: some View {
        HStack {
            Image(systemName: StringConstants.SystemImage.Magnifyingglass)
                .foregroundStyle(.gray)
            
            TextField(Placeholder, text: $Text)
                .foregroundStyle(.primary)
            
            if !Text.isEmpty {
                Button(action: {
                    self.Text = String()
                }) {
                    Image(systemName: StringConstants.SystemImage.MultiplyCircleFill)
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(7)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview {
    CustomSearchBar(Placeholder: "Search...", Text: .constant("LVS"))
}
