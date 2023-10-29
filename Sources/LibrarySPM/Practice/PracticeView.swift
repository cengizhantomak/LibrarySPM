//
//  PracticeView.swift
//  Folders
//
//  Created by Cengizhan Tomak on 11.09.2023.
//

import SwiftUI
import CustomAlertPackage
import LVRealmKit

struct PracticeView: View {
    @StateObject var ViewModel: PracticeViewModel
    @Environment(\.horizontalSizeClass) var HorizontalSizeClass
    @Environment(\.presentationMode) var PresentationMode
    
    var body: some View {
        Content
            .disabled(ViewModel.isActive)
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
            .disabled(ViewModel.ShowDeleteAlert || ViewModel.ShowRenameAlert)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                ViewModel.SetupColumnsToDevice(To: HorizontalSizeClass)
            }
            .sheet(isPresented: $ViewModel.ShowMove) {
                DestinationFolderView(ViewModel: DestinationFolderViewModel(PracticeViewModel: ViewModel))
            }
            .overlay(alignment: .top) {
                CustomNavBar
            }
            .overlay {
                SessionTitle
                RenameAlert
                DeleteAlert
                ProgressHUD
            }
            .animation(.linear(duration: 0.2), value: [ViewModel.IsSelecting, ViewModel.OnlyShowFavorites])
    }
}


// MARK: - Extension
extension PracticeView {
    private var Content: some View {
        Group {
            if ViewModel.Session.practiceCount == 0 {
                NoVideoView()
            } else {
                GridView
            }
        }
    }
    
    private var GridView: some View {
        GeometryReader { Geometry in
            let ItemWidth = ViewModel.CalculateItemWidth(ScreenWidth: Geometry.size.width, Padding: 1, Amount: CGFloat(ViewModel.Columns.count))
            ScrollView(showsIndicators: false) {
                Section(header: DateHeader) {
                    LazyVGrid(columns: ViewModel.Columns, spacing: 1) {
                        ForEach(ViewModel.DisplayedPractices, id: \.id) { Practice in
                            if !ViewModel.IsSelecting {
                                NavigationLink(destination: VideoPlayerView(url: Practice.VideoPath)) {
                                    PracticeItemView(ViewModel: ViewModel, Practice: Practice, ItemWidth: ItemWidth)
                                }
                                .buttonStyle(NoEffectButtonStyle())
                            } else {
                                PracticeItemView(ViewModel: ViewModel, Practice: Practice, ItemWidth: ItemWidth)
                                    .onTapGesture {
                                        ViewModel.ToggleSelection(Of: Practice)
                                    }
                                    .opacity(ViewModel.Opacity(For: Practice))
                            }
                        }
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 5)
                .padding(.bottom, 75)
                .overlay {
                    GeometryReader { ScrollGeometry in
                        Color.clear.preference(key: ScrollPreferenceKey.self, value: ScrollGeometry.frame(in: .named(StringConstants.Scroll)).minY)
                    }
                }
                
//                .background(GeometryReader { Proxy -> Color in
//                    DispatchQueue.main.async {
//                        ViewModel.UpdateClampedOpacity(With: Proxy, Name: StringConstants.Scroll)
//                    }
//                    return Color.clear
//                })
//            }
//            .coordinateSpace(name: StringConstants.Scroll)
//            LinearGradient(
//                gradient: Gradient(colors: [.black, .clear]),
//                startPoint: .top,
//                endPoint: .bottom)
//            .opacity(ViewModel.ClampedOpacity)
//            .edgesIgnoringSafeArea(.top)
//            .frame(height: 10)
            }
            .coordinateSpace(name: StringConstants.Scroll)
            .onPreferenceChange(ScrollPreferenceKey.self, perform: { Value in
                withAnimation(.linear) {
                    if Value < -16 {
                        ViewModel.IsScroll = true
                    } else {
                        ViewModel.IsScroll = false
                    }
                }
            })
        }
    }
    
    private var DateHeader: some View {
        Text(Date.CurrentDate(From: ViewModel.Session.createdAt))
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(.clear)
            .padding(.trailing, 5)
    }
    
    // MARK: - Title
    private var SessionTitle: some View {
        VStack {
            HStack {
                Text(ViewModel.Session.name)
                    .foregroundStyle(ViewModel.IsScroll ? .white : .primary)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(.title2)
                    .background(Color.clear)
                    .padding(.horizontal)
                    .frame(alignment: .leading)
                Spacer(minLength: 100)
            }
            Spacer()
        }
    }
    
    // MARK: - Custom Navigation Bar
    private var CustomNavBar: some View {
        LinearGradient(
            gradient: Gradient(colors: [.black, .clear]),
            startPoint: .top,
            endPoint: .bottom)
        .opacity(ViewModel.IsScroll ? 0.75 : 0)
        .edgesIgnoringSafeArea(.top)
        .frame(height: 100)
    }
    
    // MARK: - Toolbars
    private var CustomBackButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                PresentationMode.wrappedValue.dismiss()
            } label: {
                HStack {
                    Image(systemName: StringConstants.SystemImage.ChevronBackward)
                        .fontWeight(.semibold)
                    Text(StringConstants.Videos)
                }
                .foregroundStyle(ViewModel.IsScroll ? .white : .primary)
            }
        }
    }
    
    private var DefaultTopBar: some ToolbarContent {
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
    
    private var SelectionTopBar: some ToolbarContent {
        Group {
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
    }
    
    private var SelectionBottomBar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                ViewModel.ShowMove = true
            } label: {
                Image(systemName: StringConstants.SystemImage.FolderBadgePlus)
            }
            .disabled(ViewModel.SelectedPractices.isEmpty)
            
            Spacer()
            
            Text(ViewModel.SelectionCount(For: ViewModel.SelectedPractices.count))
                .foregroundStyle(ViewModel.SelectedPractices.isEmpty || ViewModel.ShowMove || ViewModel.ShowDeleteAlert || ViewModel.ShowDeleteAlert ? .secondary : .primary)
            
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
            .disabled(ViewModel.SelectedPractices.isEmpty)
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
                    ViewModel.RenamePractice()
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

struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeView(ViewModel: PracticeViewModel(Folder: SessionModel()))
    }
}
