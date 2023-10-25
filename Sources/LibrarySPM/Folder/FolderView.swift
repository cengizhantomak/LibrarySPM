//
//  FolderView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 4.09.2023.
//

import SwiftUI
import LVRealmKit
import CustomAlertPackage

struct FolderView: View {
    @StateObject var ViewModel = FolderViewModel()
    @Environment(\.horizontalSizeClass) var HorizontalSizeClass
//    @State private var scrollPosition: CGFloat = .zero
    
    var body: some View {
        NavigationStack {
            Content
                .disabled(ViewModel.isActive)
                .animation(.default, value: [ViewModel.IsSelecting, ViewModel.OnlyShowFavorites])
                .navigationTitle(StringConstants.Videos)
                .toolbar {
                    if !ViewModel.IsSelecting {
                        DefaultTopBarLeading
                        DefaultTopBarTrailing
                    } else {
                        SelectionTopBarTrailing
                        SelectionBottomBar
                    }
                }
                .onAppear {
                    ViewModel.SetupColumnsToDevice(To: HorizontalSizeClass)
                    ViewModel.LoadFolders()
                }
        }
        .accentColor(.primary)
        .overlay {
            CreatedAlert
            RenameAlert
            DeleteAlert
            ProgressHUD
        }
    }
}


// MARK: - Extension
extension FolderView {
    private var Content: some View {
        Group {
            if ViewModel.DisplayedSessions.isEmpty {
                NoVideoView()
            } else {
                GridView
            }
        }
    }
    
    private var GridView: some View {
        GeometryReader { Geometry in
            let ItemWidth = ViewModel.CalculateItemWidth(ScreenWidth: Geometry.size.width, Padding: 16, Amount: CGFloat(ViewModel.Columns.count))
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 44) {
                    CreateSection(WithTitle: StringConstants.SectionTitle.Todays, Folders: ViewModel.TodaySection, ItemWidth: ItemWidth)
                    CreateSection(WithTitle: StringConstants.SectionTitle.Pinned, Folders: ViewModel.PinnedSection, ItemWidth: ItemWidth)
                    CreateSection(WithTitle: StringConstants.SectionTitle.Session, Folders: ViewModel.SessionSection, ItemWidth: ItemWidth)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 75)
//                .background(GeometryReader { Proxy -> Color in
//                    DispatchQueue.main.async {
//                        //                                                     ViewModel.UpdateClampedOpacity(With: Proxy, Name: StringConstants.Scroll)
//                    }
//                    return Color.clear
//                })
//                //                .background(GeometryReader { geometry in
//                //                        Color.clear
//                //                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("Scroll")).origin)
//                //                })
//                //                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
//                //                    self.scrollPosition = value.y
//                //                    print("scrollPosition: ", value)
//                //                }
            }
//            .coordinateSpace(name: StringConstants.Scroll)
//            //            LinearGradient(
//            //                gradient: Gradient(colors: [.black, .clear]),
//            //                startPoint: .top,
//            //                endPoint: .bottom)
//            //            .opacity(ViewModel.ClampedOpacity)
//            //            .edgesIgnoringSafeArea(.top)
//            //            .frame(height: 10)
        }
    }
    
    private func CreateSection(WithTitle Title: String, Folders: [SessionModel], ItemWidth: CGFloat) -> some View {
        Group {
            if !Folders.isEmpty {
                VStack(alignment: .leading) {
                    Divider()
                    Section(header: Text(Title).font(.title2.weight(.bold))) {
                        LazyVGrid(columns: ViewModel.Columns, spacing: 14) {
                            ForEach(Folders, id: \.id) { Folder in
                                if !ViewModel.IsSelecting {
                                    NavigationLink(destination: PracticeView(ViewModel: PracticeViewModel(Folder: Folder))) {
                                        FolderItemView(ViewModel: ViewModel, Folder: Folder, ItemWidth: ItemWidth)
                                    }
                                    .buttonStyle(NoEffectButtonStyle())
                                } else {
                                    FolderItemView(ViewModel: ViewModel, Folder: Folder, ItemWidth: ItemWidth)
                                        .onTapGesture{
                                            if let Index = ViewModel.SelectedSessions.firstIndex(where: { $0.id == Folder.id }) {
                                                ViewModel.SelectedSessions.remove(at: Index)
                                            } else {
                                                ViewModel.SelectedSessions.append(Folder)
                                            }
                                        }
                                        .opacity(ViewModel.Opacity(For: Folder))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Toolbars
    private var DefaultTopBarLeading: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Button {
                ViewModel.AddButtonAction()
            } label: {
                Image(systemName: StringConstants.SystemImage.Plus)
                    .padding(7)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            // TODO: Delete Toolbar
            Button {
                ViewModel.AddPractice()
            } label: {
                Text("Ekle")
                    .padding(7)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
    }
    
    private var DefaultTopBarTrailing: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack(spacing: 0) {
                Button {
                    ViewModel.FavoritesButtonAction()
                } label: {
                    Image(systemName: ViewModel.OnlyShowFavorites ? StringConstants.SystemImage.HeartFill : StringConstants.SystemImage.Heart)
                        .padding(7)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                Button {
                    ViewModel.SelectCancelButtonAction()
                } label: {
                    Text(StringConstants.Select)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var SelectionTopBarTrailing: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                ViewModel.SelectCancelButtonAction()
            } label: {
                Text(StringConstants.Cancel)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
    }
    
    private var SelectionBottomBar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            Text(ViewModel.SelectionCountText(For: ViewModel.SelectedSessions.count))
                .foregroundColor(ViewModel.SelectedSessions.isEmpty ? .gray : .primary)
            Spacer()
            Button {
                ViewModel.isActive = true
                ViewModel.ShowDeleteAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ViewModel.isActive = false
                }
            } label: {
                Image(systemName: StringConstants.SystemImage.Trash)
            }
            .disabled(ViewModel.SelectedSessions.isEmpty)
        }
    }
    
    // MARK: - Alerts
    private var CreatedAlert: some View {
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
                Text: StringConstants.ContextMenu.Pin.Text, SystemImage: ViewModel.FolderPinned ? StringConstants.ContextMenu.Pin.SystemImage : StringConstants.ContextMenu.Unpin.SystemImage,
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
    }
    
    private var RenameAlert: some View {
        CustomAlert(
            IsPresented: $ViewModel.ShowRenameAlert,
            Title: Title(
                Text: StringConstants.Alert.Title.RenameFolder,
                SystemImage: StringConstants.Alert.SystemImage.Pencil
            ),
            TextField: TextFieldText(
                Placeholder: StringConstants.Alert.Title.FolderName,
                Text: $ViewModel.NewName
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
                Text: StringConstants.ContextMenu.Pin.Text, SystemImage: ViewModel.FolderPinned ? StringConstants.ContextMenu.Pin.SystemImage : StringConstants.ContextMenu.Unpin.SystemImage,
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
                Text: StringConstants.Alert.ButtonText.Save,
                Action: {
                    ViewModel.RenameFolder(NewName: ViewModel.NewName)
                }
            )
        )
    }
    
    private var DeleteAlert: some View {
        CustomAlert(
            IsPresented: $ViewModel.ShowDeleteAlert,
            Title: Title(
                Text: StringConstants.Alert.Title.Deleting,
                SystemImage: StringConstants.Alert.SystemImage.Trash
            ),
            Message: StringConstants.Alert.Message.DeleteConfirmationMessage,
            ButtonLeft: AlertButton(
                Text: StringConstants.Alert.ButtonText.Cancel,
                Action: {
                    print("Cancel Tapped")
                }
            ),
            ButtonRight: AlertButton(
                Text: StringConstants.Alert.ButtonText.Delete,
                Action: {
                    ViewModel.DeleteFolders(ViewModel.SelectedSessions)
                    ViewModel.IsSelecting = false
                }
            )
        )
    }
    
    // MARK: - ProgressHUD
    private var ProgressHUD: some View {
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

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}

//struct ScrollOffsetPreferenceKey: PreferenceKey {
//    static var defaultValue: CGPoint = .zero
//
//    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
//    }
//}
