//
//  PracticeView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 11.09.2023.
//

import SwiftUI
import CustomAlertPackage

struct PracticeView: View {
    @StateObject var ViewModel: PracticeViewModel
    @Environment(\.horizontalSizeClass) var HorizontalSizeClass
    @Environment(\.presentationMode) var PresentationMode
    
    var body: some View {
        Content
            .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .local)
                .onEnded { Value in
                    if Value.translation.width > 100 {
                        PresentationMode.wrappedValue.dismiss()
                    }
                }
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                CustomBackButton
                
                if !ViewModel.IsSelecting {
                    DefaultTopBar
                } else {
                    SelectionTopBar
                    SelectionBottomBar
                }
            }
            .disabled(ViewModel.ShowDeleteAlert)
            .navigationBarBackButtonHidden(true)
            .animation(.spring, value: [ViewModel.IsSelecting, ViewModel.OnlyShowFavorites])
            .onAppear {
                ViewModel.SetupColumnsToDevice(To: HorizontalSizeClass)
            }
            .sheet(isPresented: $ViewModel.ShowMoveAlert) {
                DestinationFolderView(ViewModel: DestinationFolderViewModel(PracticeViewModel: ViewModel))
            }
            .overlay {
                SessionTitle
                RenameAlert
                DeleteAlert
                ProgressHUD
            }
    }
}


// MARK: - Extension
extension PracticeView {
    private var Content: some View {
        Group {
            if ViewModel.Session.practiceCount == 0 {
                NoVideoContent
            } else {
                GridView
            }
        }
    }
    
    private var NoVideoContent: some View {
        ZStack {
            NoVideoView()
        }
    }
    
    private var GridView: some View {
        GeometryReader { Geometry in
            let ItemWidth = ViewModel.CalculateItemWidth(ScreenWidth: Geometry.size.width, Padding: 1, Amount: CGFloat(ViewModel.Columns.count))
            ScrollView {
                Section(header: DateHeader) {
                    LazyVGrid(columns: ViewModel.Columns, spacing: 1) {
                        ForEach(ViewModel.DisplayedPractices, id: \.id) { Practice in
                            NavigationLink(destination: VideoPlayerView(url: Practice.VideoPath)) {
                                PracticeItemView(ViewModel: ViewModel, Practice: Practice, ItemWidth: ItemWidth)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .padding(5)
            }
        }
    }
    
    private var DateHeader: some View {
        Text(Date.CurrentDate(From: ViewModel.Session.createdAt))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(.clear)
            .padding(.top)
    }
    
    // MARK: - Toolbars
    private var CustomBackButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                PresentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .fontWeight(.semibold)
                    Text("Videos")
                }
            }
            .foregroundStyle(.primary)
        }
    }
    
    private var DefaultTopBar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            HStack(spacing: 0) {
                Button {
                    ViewModel.FavoritesButtonAction()
                } label: {
                    Image(systemName: ViewModel.OnlyShowFavorites ? StringConstants.SystemImage.HeartFill : StringConstants.SystemImage.Heart)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                Button {
                    ViewModel.SelectCancelButtonAction()
                } label: {
                    Text(StringConstants.Select)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var SelectionTopBar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    ViewModel.SelectCancelButtonAction()
                } label: {
                    Text(StringConstants.Cancel)
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var SelectionBottomBar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                ViewModel.ShowMoveAlert = true
            } label: {
                Image(systemName: StringConstants.SystemImage.FolderBadgePlus)
                    .foregroundColor(ViewModel.SelectedPractices.isEmpty ? .gray : .primary)
            }
            .disabled(ViewModel.SelectedPractices.isEmpty)
            
            Spacer()
            
            Text(ViewModel.SelectionCount(For: ViewModel.SelectedPractices.count))
                .foregroundColor(ViewModel.SelectedPractices.isEmpty ? .gray : .primary)
            
            Spacer()
            
            Button {
                ViewModel.isActive = true
                ViewModel.ShowDeleteAlert = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    ViewModel.isActive = false
                }
            } label: {
                Image(systemName: StringConstants.SystemImage.Trash)
                    .foregroundColor(ViewModel.SelectedPractices.isEmpty ? .gray : .primary)
            }
            .disabled(ViewModel.SelectedPractices.isEmpty)
        }
    }
    
    // MARK: - Title
    private var SessionTitle: some View {
        VStack {
            HStack {
                Text(ViewModel.Session.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.title2)
                    .background(Color.clear)
                    .padding(10)
                    .frame(alignment: .leading)
                Spacer(minLength: 100)
            }
            Spacer()
        }
    }
    
    // MARK: - Alerts
    private var RenameAlert: some View {
        CustomAlert(
            IsPresented: $ViewModel.ShowRenameAlert,
            Title: Title(
                Text: StringConstants.Alert.Title.RenameVideo,
                SystemImage: StringConstants.Alert.SystemImage.Pencil
            ),
            TextField: TextFieldText(
                Placeholder: StringConstants.Alert.Title.VideoName,
                Text: $ViewModel.NewName
            ),
            LabelLeft: LabelButton(
                Text: StringConstants.ContextMenu.AddFavorite.Text,
                SystemImage: ViewModel.PracticeFavorite ? StringConstants.ContextMenu.RemoveFavorite.SystemImage : StringConstants.ContextMenu.AddFavorite.SystemImage,
                Binding: $ViewModel.PracticeFavorite,
                Action: {
                    ViewModel.PracticeFavorite.toggle()
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
                    if !ViewModel.NewName.isEmpty {
                        ViewModel.RenamePractice()
                    } else {
                        ViewModel.ErrorTTProgressHUD()
                    }
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
                    ViewModel.DeletePractices(ViewModel.SelectedPractices)
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

//struct PracticeView_Previews: PreviewProvider {
//    static var previews: some View {
//        PracticeView(ViewModel: PracticeViewModel(Folder: FolderModel(Name: "LVS")))
//    }
//}
