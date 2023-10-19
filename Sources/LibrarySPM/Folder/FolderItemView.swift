//
//  FolderItemView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 4.09.2023.
//

import SwiftUI
import LVRealmKit

struct FolderItemView: View {
    @StateObject var ViewModel: FolderViewModel
    @Environment(\.colorScheme) var ColorScheme
    var Folder: SessionModel
    let ItemWidth: CGFloat
    
    var body: some View {
        if ViewModel.IsSelecting {
            Button {
                if let Index = ViewModel.SelectedSessions.firstIndex(where: { $0.id == Folder.id }) {
                    ViewModel.SelectedSessions.remove(at: Index)
                } else {
                    ViewModel.SelectedSessions.append(Folder)
                }
            } label: {
                VStack(alignment: .leading) {
                    FolderItem
                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                        .contextMenu {
                            if !ViewModel.IsSelecting {
                                FolderContextMenu
                            }
                        }
                    Text(Folder.name)
                        .truncationMode(.tail)
                        .lineLimit(1)
                        .font(.system(size: 15))
                    Text(String(Folder.practiceCount))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .opacity(ViewModel.Opacity(For: Folder))
        } else {
            VStack(alignment: .leading) {
                FolderItem
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
                    .contextMenu {
                        if !ViewModel.IsSelecting {
                            FolderContextMenu
                        }
                    }
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
}

extension FolderItemView {
    
    // MARK: - FolderItem
    private var FolderItem: some View {
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 20, YOffsetValue: 20)
        let SafeItemWidth = max(ItemWidth, 1)
        
        return ZStack {
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
                    .background()
                    .frame(width: SafeItemWidth, height: SafeItemWidth * (1970 / 1080))
                    .cornerRadius(10)
                Image(systemName: StringConstants.SystemImage.RectangleStackBadgePlay)
                    .resizable()
                    .scaledToFit()
                    .frame(width: SafeItemWidth * 0.3, height: SafeItemWidth * 0.3)
                    .foregroundColor(ColorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            FavoriteIcon(CircleOffset: CircleOffset, SafeItemWidth: SafeItemWidth)
            SelectionIcon(CircleOffset: CircleOffset)
        }
        .background(.clear)
        .cornerRadius(10)
    }
    
    // MARK: - Icons
    private func FavoriteIcon(CircleOffset: (X: CGFloat, Y: CGFloat), SafeItemWidth: CGFloat) -> some View {
        Group {
            if Folder.isFavorite && !ViewModel.IsSelecting {
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
    
    private func SelectionIcon(CircleOffset: (X: CGFloat, Y: CGFloat)) -> some View {
        Group {
            if ViewModel.IsSelecting {
                Circle()
                    .stroke(.gray, lineWidth: 2)
                    .background(Circle().fill(Color.white))
                    .overlay(
                        ViewModel.SelectedSessions.contains(where: { $0.id == Folder.id }) ?
                        Circle().stroke(.gray, lineWidth: 2).frame(width: 10, height: 10) : nil
                    )
                    .frame(width: 20, height: 20)
                    .offset(x: CircleOffset.X, y: CircleOffset.Y)
            } else {
                EmptyView()
            }
        }
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

//struct FolderItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        FolderItemView(ViewModel: FolderViewModel(), Folder: FolderModel(Name: "LVS"), ItemWidth: 100)
//    }
//}
