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
                .overlay {
                    if Folder.isFavorite && !ViewModel.IsSelected(Session: Folder) {
                        FavoriteIcon
                    } else if ViewModel.IsSelected(Session: Folder) {
                        Color.primary.opacity(0.5)
                            .cornerRadius(10)
                        SelectionIcon
                    }
                }
            
            Text(Folder.name)
                .truncationMode(.tail)
                .lineLimit(1)
                .font(.system(size: 15))
            Text(String(Folder.practiceCount))
                .font(.system(size: 14))
                .foregroundStyle(.gray)
        }
    }
}


extension DestinationFolderItemView {
    
    // MARK: - FolderItem
    private var FolderItem: some View {
        let SafeItemWidth = max(ItemWidth, 1)
        
        return Group {
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
                    .overlay {
                        Image(systemName: StringConstants.SystemImage.RectangleStackBadgePlay)
                            .resizable()
                            .scaledToFit()
                            .frame(width: SafeItemWidth * 0.3, height: SafeItemWidth * 0.3)
                            .foregroundStyle(ColorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.6, green: 0.6, blue: 0.6))
                    }
            }
        }
    }
    
    // MARK: - Icons
    private var FavoriteIcon: some View {
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 20, YOffsetValue: 20)
        
        return Image(systemName: StringConstants.SystemImage.HeartFill)
            .resizable()
            .scaledToFit()
            .frame(width: 17, height: 17)
            .foregroundStyle(.red)
            .offset(x: CircleOffset.X, y: CircleOffset.Y)
    }
    
    private var SelectionIcon: some View {
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 20, YOffsetValue: 20)
        
        return Group {
//            Color.primary.opacity(0.3)
//                .cornerRadius(10)
            Circle()
                .fill(Color.green)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(.black)
                        .fontWeight(.semibold)
                }
                .offset(x: CircleOffset.X, y: CircleOffset.Y)
        }
    }
}

#Preview {
    DestinationFolderItemView(ViewModel: DestinationFolderViewModel(PracticeViewModel: PracticeViewModel(Folder: SessionModel())), Folder: SessionModel(), ItemWidth: 150)
}
