//
//  VideoPlayerView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 27.09.2023.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let url: String
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: URL.documentsDirectory.appending(path: url)))
                    .navigationTitle("Video Oynatıcı")
                    .edgesIgnoringSafeArea(.all)
    }
}

//#Preview {
//    VideoPlayerView()
//}
