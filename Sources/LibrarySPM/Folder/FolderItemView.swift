//
//  FolderItemView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 4.09.2023.
//

import SwiftUI
import LVRealmKit
import Kingfisher

struct FolderItemView: View {
    @StateObject var ViewModel: FolderViewModel
    @Environment(\.colorScheme) var ColorScheme
    var Folder: SessionModel
    let ItemWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            FolderItem
                .overlay {
                    if ViewModel.IsSelecting {
                        SelectionIcon
                    } else if Folder.isFavorite {
                        FavoriteIcon
                    }
                }
                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 5))
                .contextMenu {
                    if !ViewModel.IsSelecting {
                        FolderContextMenu
                    }
                }
            Text(Folder.name)
                .truncationMode(.tail)
                .lineLimit(1)
                .font(.system(size: 17))
            Text(String(Folder.practiceCount))
                .font(.system(size: 15))
                .foregroundStyle(.gray)
        }
    }
}


extension FolderItemView {
    // MARK: - FolderItem
    private var FolderItem: some View {
        let SafeItemWidth = max(ItemWidth, 1)
        
        return Group {
            
            // MARK: - UIImage
//            if let ThumbPath = Folder.thumbnail,
//               let UIImageURL = UIImage(contentsOfFile: URL.documentsDirectory.appending(path: ThumbPath).path) {
//                Image(uiImage: UIImageURL)
//                    .resizable()
//                    .frame(width: SafeItemWidth, height: SafeItemWidth * (1850 / 1080))
//                    .scaledToFit()
//                    .cornerRadius(5)
                
                // MARK: - KINGFISHER
                if let ThumbPath = Folder.thumbnail {
                    KFImage(URL.documentsDirectory.appending(path: ThumbPath))
                        .cacheMemoryOnly()
                        .setProcessor(DownsamplingImageProcessor(size: .init(width: SafeItemWidth, height: SafeItemWidth * (1850 / 1080))))
                        .scaleFactor(UIApplication.shared.firstWindow?.screen.scale ?? 2)
                        .resizable()
                        .frame(width: SafeItemWidth, height: SafeItemWidth * (1850 / 1080))
                        .scaledToFit()
                        .cornerRadius(5)
            } else {
                Rectangle()
                    .fill(ColorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.9, green: 0.9, blue: 0.9))
                    .background()
                    .frame(width: SafeItemWidth, height: SafeItemWidth * (1850 / 1080))
                    .cornerRadius(5)
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
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 20, YOffsetValue: 30)
        
        return Image(systemName: StringConstants.SystemImage.HeartFill)
            .resizable()
            .scaledToFit()
            .frame(width: 15, height: 15)
            .foregroundStyle(.red)
            .offset(x: CircleOffset.X, y: CircleOffset.Y)
    }
    
    private var SelectionIcon: some View {
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 20, YOffsetValue: 30)
        
        return Image(systemName: ViewModel.SelectedSessions.contains(where: { $0.id == Folder.id }) ? StringConstants.SystemImage.CircleCircleFill : StringConstants.SystemImage.Circle)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundStyle(.white)
            .offset(x: CircleOffset.X, y: CircleOffset.Y)
    }
    
    // MARK: - Context Menu and Actions
    private var FolderContextMenu: some View {
        VStack {
            PinUnpinButton
            ToggleFavoriteButton
            Divider()
            RenameVideoButton
            DeleteVideoButton
        }
    }
    
    private var PinUnpinButton: some View {
        Button {
            ViewModel.Session = Folder
            ViewModel.TogglePin()
        } label: {
            Label(
                Folder.isPinned ? StringConstants.ContextMenu.Unpin.Text : StringConstants.ContextMenu.Pin.Text,
                systemImage:
                    Folder.isPinned ? StringConstants.ContextMenu.Unpin.SystemImage : StringConstants.ContextMenu.Pin.SystemImage
            )
        }
    }
    
    private var ToggleFavoriteButton: some View {
        Button {
            ViewModel.Session = Folder
            ViewModel.ToggleFavorite()
        } label: {
            Label(
                Folder.isFavorite ? StringConstants.ContextMenu.RemoveFavorite.Text : StringConstants.ContextMenu.AddFavorite.Text,
                systemImage:
                    Folder.isFavorite ? StringConstants.ContextMenu.RemoveFavorite.SystemImage : StringConstants.ContextMenu.AddFavorite.SystemImage
            )
        }
    }
    
    private var RenameVideoButton: some View {
        Button {
            ViewModel.Session = Folder
            ViewModel.NewName = Folder.name
            ViewModel.FolderFavorite = Folder.isFavorite
            ViewModel.FolderPinned = Folder.isPinned
            ViewModel.isActive = true
            ViewModel.ShowRenameAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ViewModel.isActive = false
            }
        } label: {
            Label(
                StringConstants.ContextMenu.Rename.Text,
                systemImage: StringConstants.ContextMenu.Rename.SystemImage
            )
        }
    }
    
    private var DeleteVideoButton: some View {
        Button(role: .destructive) {
            ViewModel.SelectedSessions.append(Folder)
            ViewModel.isActive = true
            ViewModel.ShowDeleteAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                ViewModel.isActive = false
            }
        } label: {
            Label(
                StringConstants.ContextMenu.Delete.Text,
                systemImage: StringConstants.ContextMenu.Delete.SystemImage
            )
        }
    }
}

struct FolderItemView_Previews: PreviewProvider {
    static var previews: some View {
        FolderItemView(ViewModel: FolderViewModel(), Folder: SessionModel(), ItemWidth: 150)
    }
}
