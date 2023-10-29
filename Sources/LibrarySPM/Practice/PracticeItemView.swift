//
//  PracticeItemView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 11.09.2023.
//

import SwiftUI
import LVRealmKit
import Kingfisher

struct PracticeItemView: View {
    @StateObject var ViewModel: PracticeViewModel
    @Environment(\.colorScheme) var ColorScheme
    var Practice: PracticeModel
    let ItemWidth: CGFloat
    
    var body: some View {
        PracticeItem
            .overlay {
                if ViewModel.IsSelecting {
                    SelectionIcon
                } else if Practice.isFavorite {
                    FavoriteIcon
                }
            }
            .contextMenu {
                if !ViewModel.IsSelecting {
                    VideoContextMenu
                }
            }
    }
}


extension PracticeItemView {
    // MARK: - PracticeItem
    private var PracticeItem: some View {
        let SafeItemWidth = max(ItemWidth, 1)
        
        return Group {
            
            // MARK: - UIImage
//            if let ThumbPath = Practice.ThumbPath,
//               let UIImageURL = UIImage(contentsOfFile: URL.documentsDirectory.appending(path: ThumbPath).path) {
//                Image(uiImage: UIImageURL)
//                    .resizable()
//                    .frame(width: SafeItemWidth, height: SafeItemWidth * (16 / 9))
//                    .scaledToFit()
                
            // MARK: - AsyncImage
//            if let ThumbPath = Practice.ThumbPath {
//                AsyncImage(url: URL.documentsDirectory.appending(path: ThumbPath)) { Image in
//                    Image
//                        .resizable()
//                        .frame(width: SafeItemWidth, height: SafeItemWidth * (16 / 9))
//                        .scaledToFit()
//                } placeholder: {
//                    ProgressView()
//                        .frame(width: SafeItemWidth, height: SafeItemWidth * (16 / 9))
//                }
                    
            // MARK: - KINGFISHER
            if let ThumbPath = Practice.ThumbPath {
                KFImage(URL.documentsDirectory.appending(path: ThumbPath))
                    .cacheMemoryOnly()
                    .setProcessor(DownsamplingImageProcessor(size: .init(width: SafeItemWidth, height: SafeItemWidth * (16 / 9))))
                    .scaleFactor(UIApplication.shared.firstWindow?.screen.scale ?? 2)
                    .resizable()
                    .frame(width: SafeItemWidth, height: SafeItemWidth * (16 / 9))
                    .scaledToFit()
                
                
            } else {
                Rectangle()
                    .fill(ColorScheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : Color(red: 0.9, green: 0.9, blue: 0.9))
                    .frame(width: SafeItemWidth, height: SafeItemWidth * (16 / 9))
                    .overlay {
                        Image(systemName: StringConstants.SystemImage.RectangleStackBadgePlay)
                            .resizable()
                            .scaledToFit()
                            .frame(width: SafeItemWidth * 0.3, height: SafeItemWidth * 0.3)
                            .foregroundStyle(ColorScheme == .dark ? Color(red: 0.3, green: 0.3, blue: 0.3) : Color(red: 0.6, green: 0.6, blue: 0.6))
                    }
            }
        }
        .overlay {
            VStack {
                Spacer()
                LinearGradient(colors: [Color.black, Color.clear], startPoint: .bottom, endPoint: .top)
                    .frame(height: 100)
            }
            NameTimeTitle
        }
    }
    
    private var NameTimeTitle: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Text(Practice.Name)
                    .truncationMode(.tail)
                    .lineLimit(1)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                Text(Date.CurrentTime(From: Practice.UpdatedAt))
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.gray)
            }
            .padding(5)
            
            Spacer()
        }
    }
    
    // MARK: - Icons
    private var FavoriteIcon: some View {
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 15, YOffsetValue: 15)
        
        return Image(systemName: StringConstants.SystemImage.HeartFill)
            .resizable()
            .scaledToFit()
            .frame(width: 12, height: 12)
            .foregroundStyle(.red)
            .offset(x: CircleOffset.X, y: CircleOffset.Y)
    }
    
    private var SelectionIcon: some View {
        let CircleOffset = ViewModel.CircleOffset(For: ItemWidth, XOffsetValue: 15, YOffsetValue: 15)
        
        return Image(systemName: ViewModel.SelectedPractices.contains(where: { $0.id == Practice.id }) ? StringConstants.SystemImage.CircleCircleFill : StringConstants.SystemImage.Circle)
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundStyle(.white)
            .offset(x: CircleOffset.X, y: CircleOffset.Y)
    }
    
    // MARK: - Context Menu and Actions
    private var VideoContextMenu: some View {
        VStack {
            ToggleFavoriteButton
            SaveToPhoneButton
            MoveButton
            Divider()
            RenameVideoButton
            DeleteVideoButton
        }
    }
    
    private var ToggleFavoriteButton: some View {
        Button {
            ViewModel.Practice = Practice
            ViewModel.ToggleFavorite()
        } label: {
            Label(
                Practice.isFavorite ? StringConstants.ContextMenu.RemoveFavorite.Text : StringConstants.ContextMenu.AddFavorite.Text,
                systemImage: Practice.isFavorite ? StringConstants.ContextMenu.RemoveFavorite.SystemImage : StringConstants.ContextMenu.AddFavorite.SystemImage
            )
        }
    }
    
    private var SaveToPhoneButton: some View {
        Button {
            ViewModel.SaveToPhonePractice()
        } label: {
            Label(
                StringConstants.ContextMenu.SaveToPhone.Text,
                systemImage: StringConstants.ContextMenu.SaveToPhone.SystemImage
            )
        }
    }
    
    private var MoveButton: some View {
        Button {
            ViewModel.SelectedPractices.append(Practice)
            ViewModel.ShowMove = true
        } label: {
            Label(
                StringConstants.ContextMenu.Move.Text,
                systemImage: StringConstants.ContextMenu.Move.SystemImage
            )
        }
    }
    
    private var RenameVideoButton: some View {
        Button {
            ViewModel.Practice = Practice
            ViewModel.NewName = Practice.Name
            ViewModel.PracticeFavorite = Practice.isFavorite
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
            ViewModel.SelectedPractices.append(Practice)
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

struct PracticeItemView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeItemView(ViewModel: PracticeViewModel(Folder: SessionModel()), Practice: PracticeModel(id: "", Name: "", VideoPath: ""), ItemWidth: 150)
    }
}
