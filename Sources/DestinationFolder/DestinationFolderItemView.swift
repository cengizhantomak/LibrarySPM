//
//  DestinationFolderItemView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 12.10.2023.
//

import SwiftUI
import LVRealmKit

struct DestinationFolderItemView: View {
    @StateObject var ViewModel: DestinationFolderViewModel
    @Environment(\.colorScheme) var ColorScheme
    var Folder: SessionModel
    let ItemWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            FolderItem
            Text(Folder.name)
                .truncationMode(.tail)
                .lineLimit(1)
                .font(.system(size: 15))
            Text(String(Folder.practiceCount))
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
}


extension DestinationFolderItemView {
    
    // MARK: - FolderItem
    private var FolderItem: some View {
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 20, YOffsetValue: 20)
        let SafeItemWidth = max(ItemWidth, 1)
        
        return ZStack {
            Group {
                if let ThumbPath = Folder.thumbnail {
                    AsyncImage(url: URL.documentsDirectory.appending(path: ThumbPath)) { Image in
                        Image
                            .resizable()
                            .frame(width: SafeItemWidth, height: SafeItemWidth * (1970 / 1080))
                            .scaledToFit()
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: SafeItemWidth, height: SafeItemWidth * (1970 / 1080))
                    }
                } else {
                    Rectangle()
                        .fill(ColorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.9, green: 0.9, blue: 0.9))
                        .frame(width: SafeItemWidth, height: SafeItemWidth * (1970 / 1080))
                        .cornerRadius(10)
                    Image(systemName: StringConstants.SystemImage.RectangleStackBadgePlay)
                        .resizable()
                        .scaledToFit()
                        .frame(width: SafeItemWidth * 0.3, height: SafeItemWidth * 0.3)
                        .foregroundColor(ColorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            }
            .overlay {
                Color.black.opacity(ViewModel.isSelected(session: Folder) ? 0.3 : 0.0)
                    .cornerRadius(10)
            }
            FavoriteIcon(CircleOffset: CircleOffset, SafeItemWidth: SafeItemWidth)
            SelectionIcon(CircleOffset: CircleOffset, SafeItemWidth: SafeItemWidth)
        }
    }
    
    // MARK: - Icons
    private func FavoriteIcon(CircleOffset: (X: CGFloat, Y: CGFloat), SafeItemWidth: CGFloat) -> some View {
        Group {
            if Folder.isFavorite && !ViewModel.isSelected(session: Folder) {
                Image(systemName: StringConstants.SystemImage.HeartFill)
                    .resizable()
                    .scaledToFit()
                    .frame(width: SafeItemWidth * 0.08, height: SafeItemWidth * 0.08)
                    .foregroundColor(.red)
                    .offset(x: CircleOffset.X, y: CircleOffset.Y)
            } else {
                EmptyView()
            }
        }
    }
    
    private func SelectionIcon(CircleOffset: (X: CGFloat, Y: CGFloat), SafeItemWidth: CGFloat) -> some View {
        Group {
            if ViewModel.isSelected(session: Folder) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: SafeItemWidth * 0.08, height: SafeItemWidth * 0.08)
                    .foregroundColor(.green)
                    .offset(x: CircleOffset.X, y: CircleOffset.Y)
            }
        }
    }
}

//#Preview {
//    DestinationFolderItemView()
//}
