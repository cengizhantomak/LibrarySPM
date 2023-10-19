//
//  DestinationFolderViewModel.swift
//  Folders
//
//  Created by Cengizhan Tomak on 29.09.2023.
//

import SwiftUI
import LVRealmKit

class DestinationFolderViewModel: ObservableObject {
    weak var PracticeViewModel: PracticeViewModel?
    @Published var Columns: [GridItem] = []
    @Published var Sessions: [SessionModel] = []
    @Published var SelectedFolder: SessionModel?
    @Published var ShowMoveAlert = false
    @Published var ShowCreatedAlert = false
    @Published var IsSuccessTTProgressHUDVisible = false
    @Published var IsErrorTTProgressHUDVisible = false
    @Published var FolderName = ""
    @Published var FolderFavorite = false
    @Published var FolderPinned = false
    @Published var SearchText: String = ""
    @Published var ShowFavorited = false
    @Published var ShowPinned = false
    @Published var isActive = false
    var FolderCreationDate: Date?
    var FilteredSessions: [SessionModel] {
        Sessions.filter {
            (SearchText.isEmpty || $0.name.localizedStandardContains(SearchText)) &&
            (!ShowFavorited || $0.isFavorite) &&
            (!ShowPinned || $0.isPinned)
        }
    }
    
    init(PracticeViewModel: PracticeViewModel) {
        self.PracticeViewModel = PracticeViewModel
        LoadFolders()
    }
    
    func LoadFolders() {
        Task {
            do {
                let AllSessions = try await FolderRepository.shared.getFolders()
                UpdateSessionModel(SessionModel: AllSessions)
            } catch {
                print("Error loading sessions: \(error)")
            }
        }
    }
    
    private func UpdateSessionModel(SessionModel: [SessionModel]) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                guard let self else { return }
                if let sessionID = self.PracticeViewModel?.Session.id {
                    let updatedSessions = SessionModel.filter { session in
                        sessionID != session.id
                    }
                    self.Sessions = updatedSessions
                }
            }
        }
    }
    
    func isSelected(session: SessionModel) -> Bool {
        return SelectedFolder?.id == session.id
    }
    
    func MovePractice() {
        Task {
            do {
                var UpdatedPracticesArray: [PracticeModel] = []
                
                PracticeViewModel?.SelectedPractices.forEach { Practice in
                    var UpdatedPractice = Practice
                    UpdatedPractice.Session = SelectedFolder
                    UpdatedPracticesArray.append(UpdatedPractice)
                }
                
                try await PracticeRepository.shared.edit(UpdatedPracticesArray)
                try await UpdateDestinationFolder()
                UpdateUI()
            } catch {
                print("Error updating practice status: \(error)")
            }
        }
    }
    
    private func UpdateDestinationFolder() async throws {
        if var DestinationFolder = SelectedFolder {
            let Practices = try await PracticeRepository.shared.getPractices(DestinationFolder)
            // DestinationFolder içindeki Practice sayısını güncelle
            DestinationFolder.practiceCount = Practices.count
            // DestinationFolder'ın thumbnail'ını güncelle
            if let LastPractice = Practices.first {
                DestinationFolder.thumbnail = LastPractice.ThumbPath
            }
            try await FolderRepository.shared.edit(DestinationFolder)
        }
    }
    
    private func UpdateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.PracticeViewModel?.LoadPractices()
            self.PracticeViewModel?.IsSelecting = false
            self.PracticeViewModel?.ShowMoveAlert = false
            self.PracticeViewModel?.SuccessTTProgressHUD()
        }
    }
    
    func AddButtonAction() {
        FolderCreationDate = Date()
        FolderName = FolderCreationDate?.dateFormat(StringConstants.DateTimeFormatFolder) ?? StringConstants.LVS
        FolderFavorite = false
        FolderPinned = false
        isActive = true
        ShowCreatedAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.isActive = false
        }
    }
    
    func AddFolder() {
        Task {
            do {
                var Folder = SessionModel()
                Folder.name = FolderName
                Folder.isFavorite = FolderFavorite
                Folder.isPinned = FolderPinned
                Folder.createdAt = FolderCreationDate ?? Date()
                try await FolderRepository.shared.addFolder(Folder)
                LoadFolders()
                SuccessTTProgressHUD()
            } catch {
                print("Error adding session: \(error)")
            }
        }
    }
    
    private func SuccessTTProgressHUD() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.IsSuccessTTProgressHUDVisible = true
        }
    }
    
    func ErrorTTProgressHUD() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.IsErrorTTProgressHUDVisible = true
        }
    }
    
    func CalculateItemWidth(ScreenWidth: CGFloat, Padding: CGFloat, Amount: CGFloat) -> CGFloat {
        return (ScreenWidth - (Padding * (Amount + 1))) / Amount
    }
    
    func CircleOffset(For ItemWidth: CGFloat, XOffsetValue: CGFloat = 20, YOffsetValue: CGFloat = 20) -> (X: CGFloat, Y: CGFloat) {
        let X = (ItemWidth / 2) - XOffsetValue
        let Y = -(ItemWidth * (1970 / 1080) / 2) + YOffsetValue
        return (X, Y)
    }
    
    func SetupColumnsToDevice(To SizeClass: UserInterfaceSizeClass?) {
        let ItemCount: Int
        if SizeClass == .compact {
            ItemCount = 2 //iPhone
        } else {
            ItemCount = 4 //iPad
        }
        Columns = Array(repeating: GridItem(.flexible()), count: ItemCount)
    }
}
