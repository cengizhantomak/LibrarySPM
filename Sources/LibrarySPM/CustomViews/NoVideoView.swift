//
//  NoVideoView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 4.10.2023.
//

import SwiftUI

struct NoVideoView: View {
    var body: some View {
        VStack {
            Image(systemName: StringConstants.SystemImage.NoVideo)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            Text(StringConstants.NoVideo)
                .font(.system(size: 15))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.gray)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    NoVideoView()
}
