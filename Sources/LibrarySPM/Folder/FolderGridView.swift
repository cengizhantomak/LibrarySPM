//
//  FolderGridView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 7.09.2023.
//

import SwiftUI
import LVRealmKit

struct FolderGridView: View {
    @StateObject var ViewModel: FolderViewModel
    var Folders: [SessionModel]
    var ItemWidth: CGFloat
    
    var body: some View {
        LazyVGrid(columns: ViewModel.Columns, spacing: 10) {
            ForEach(Folders, id: \.id) { Folder in
                if !ViewModel.IsSelecting {
                    NavigatableView(For: Folder)
                } else {
                    SelectableFolderItem(For: Folder)
                }
            }
        }
    }
}

extension FolderGridView {
    
    // MARK: - Navigation Link
    private func NavigatableView(For Folder: SessionModel) -> some View {
        NavigationLink(destination: PracticeView(ViewModel: PracticeViewModel(Folder: Folder))) {
            FolderItemView(ViewModel: ViewModel, Folder: Folder, ItemWidth: ItemWidth)
        }
        .foregroundColor(.primary)
    }
    
    // MARK: - Selectable Folder Item
    private func SelectableFolderItem(For Folder: SessionModel) -> some View {
        FolderItemView(ViewModel: ViewModel, Folder: Folder, ItemWidth: ItemWidth)
            .onTapGesture {
                HandleFolderSelection(Of: Folder)
            }
            .opacity(ViewModel.Opacity(For: Folder))
    }
    
    // MARK: Selection Handling
    private func HandleFolderSelection(Of Folder: SessionModel) {
        if let Index = ViewModel.SelectedSessions.firstIndex(where: { $0.id == Folder.id }) {
            ViewModel.SelectedSessions.remove(at: Index)
        } else {
            ViewModel.SelectedSessions.append(Folder)
        }
    }
}

//struct FolderGridView_Previews: PreviewProvider {
//    static var previews: some View {
//        FolderGridView(ViewModel: FolderViewModel(), Folders: [FolderModel.init(Name: "LVS"), FolderModel.init(Name: "RnD")], ItemWidth: 150)
//    }
//}
