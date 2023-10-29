//
//  DestinationFolderView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 29.09.2023.
//

import SwiftUI
import TTProgressHUD
import LVRealmKit
import CustomAlertPackage

struct DestinationFolderView: View {
    @StateObject var ViewModel: DestinationFolderViewModel
    @Environment(\.horizontalSizeClass) var HorizontalSizeClass
    
    var body: some View {
        NavigationStack {
            Content
                .navigationBarTitle(StringConstants.Move, displayMode: .inline)
                .toolbar {
                    Toolbars
                }
        }
        .onAppear {
            ViewModel.SetupColumnsToDevice(To: HorizontalSizeClass)
        }
        .accentColor(.primary)
        .overlay {
            Alerts
            TTProgressHUD
        }
        .animation(.linear(duration: 0.2), value: [ViewModel.ShowFavorited, ViewModel.ShowPinned])
    }
}


// MARK: - Extension
extension DestinationFolderView {
    private var Content: some View {
        VStack {
            if ViewModel.Sessions.isEmpty {
                NoVideoView()
            } else {
                CustomSearchBar(Placeholder: "Search", Text: $ViewModel.SearchText)
                    .padding(.horizontal, 12)
                MultiSegmentView
                GridView
            }
        }
    }
    
    private var GridView: some View {
        GeometryReader { Geometry in
            let ItemWidth = ViewModel.CalculateItemWidth(ScreenWidth: Geometry.size.width, Padding: 12, Amount: CGFloat(ViewModel.Columns.count))
            ScrollView {
                LazyVGrid(columns: ViewModel.Columns, spacing: 10) {
                    ForEach(ViewModel.FilteredSessions, id: \.id) { Folder in
                        DestinationFolderItemView(ViewModel: ViewModel, Folder: Folder, ItemWidth: ItemWidth)
                            .onTapGesture {
                                withAnimation(.linear(duration: 0.2)) {
                                    ViewModel.ToggleSelection(Of: Folder)
                                }
                            }
                    }
                }
                .padding(10)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        //        .searchable(text: $ViewModel.SearchText)
    }
    
    // MARK: - MultiSegmentView
    private var MultiSegmentView: some View {
        HStack(spacing: 1) {
            Button(action: {
                ViewModel.ShowFavorited.toggle()
            }) {
                Text("Favorited")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(ViewModel.ShowFavorited ? Color.gray.opacity(0.5) : Color.gray.opacity(0.15))
                    .foregroundStyle(ViewModel.ShowFavorited ? Color.primary : Color.gray)
            }
            
            Button(action: {
                ViewModel.ShowPinned.toggle()
            }) {
                Text("Pinned")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(ViewModel.ShowPinned ? Color.gray.opacity(0.5) : Color.gray.opacity(0.15))
                    .foregroundStyle(ViewModel.ShowPinned ? Color.primary : Color.gray)
            }
        }
        .cornerRadius(8)
        .padding(.horizontal, 12)
    }
    
    // MARK: - Toolbars
    private var Toolbars: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    ViewModel.AddButtonAction()
                } label: {
                    Image(systemName: StringConstants.SystemImage.Plus)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    ViewModel.isActive = true
                    ViewModel.ShowMoveAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        ViewModel.isActive = false
                    }
                } label: {
                    Text(StringConstants.Move)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
                .disabled(ViewModel.SelectedFolder == nil)
            }
        }
    }
    
    // MARK: - Alerts
    private var Alerts: some View {
        Group {
            CustomAlert(
                IsPresented: $ViewModel.ShowCreatedAlert,
                Title: Title(
                    Text: StringConstants.Alert.Title.CreateFolder,
                    SystemImage: StringConstants.Alert.SystemImage.FolderFillBadgePlus
                ),
                TextField: TextFieldText(
                    Placeholder: StringConstants.Alert.Title.FolderName,
                    Text: $ViewModel.FolderName
                ),
                LabelLeft: LabelButton(
                    Text: StringConstants.ContextMenu.AddFavorite.Text,
                    SystemImage: ViewModel.FolderFavorite ? StringConstants.ContextMenu.RemoveFavorite.SystemImage : StringConstants.ContextMenu.AddFavorite.SystemImage,
                    Binding: $ViewModel.FolderFavorite,
                    Action: {
                        ViewModel.FolderFavorite.toggle()
                    }
                ),
                LabelRight: LabelButton(
                    Text: StringConstants.ContextMenu.Pin.Text,
                    SystemImage: ViewModel.FolderPinned ? StringConstants.ContextMenu.Pin.SystemImage : StringConstants.ContextMenu.Unpin.SystemImage,
                    Binding: $ViewModel.FolderPinned,
                    Action: {
                        ViewModel.FolderPinned.toggle()
                    }
                ),
                ButtonLeft: AlertButton(
                    Text: StringConstants.Alert.ButtonText.Cancel,
                    Action: {
                        print("Cancel Tapped")
                    }
                ),
                ButtonRight: AlertButton(
                    Text: StringConstants.Alert.ButtonText.Create,
                    Action: {
                        ViewModel.AddFolder()
                    }
                )
            )
            CustomAlert(
                IsPresented: $ViewModel.ShowMoveAlert,
                Title: Title(
                    Text: StringConstants.Alert.Title.MoveVideo,
                    SystemImage: StringConstants.SystemImage.FolderBadgePlus
                ),
                Message: StringConstants.Alert.Message.MoveConfirmationMessage,
                ButtonLeft: AlertButton(
                    Text: StringConstants.Alert.ButtonText.Cancel,
                    Action: {
                        print("Cancel Tapped")
                    }
                ),
                ButtonRight: AlertButton(
                    Text: StringConstants.Alert.ButtonText.Move,
                    Action: {
                        ViewModel.MovePractice()
                    }
                )
            )
        }
    }
    
    // MARK: - ProgressHUD
    private var TTProgressHUD: some View {
        Group {
            if ViewModel.IsSuccessTTProgressHUDVisible {
                CustomTTProgressHUD(
                    IsVisible: $ViewModel.IsSuccessTTProgressHUDVisible,
                    HudType: .success
                )
            } else if ViewModel.IsErrorTTProgressHUDVisible {
                CustomTTProgressHUD(
                    IsVisible: $ViewModel.IsErrorTTProgressHUDVisible,
                    HudType: .error
                )
            }
        }
    }
}

#Preview {
    DestinationFolderView(ViewModel: DestinationFolderViewModel(PracticeViewModel: PracticeViewModel(Folder: SessionModel())))
}
