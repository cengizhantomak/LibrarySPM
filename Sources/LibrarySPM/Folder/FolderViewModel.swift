//
//  FolderViewModel.swift
//  Folders
//
//  Created by Cengizhan Tomak on 4.09.2023.
//

import SwiftUI
import LVRealmKit
import AVFoundation

class FolderViewModel: ObservableObject {
    @Published var Columns: [GridItem] = []
    @Published var IsSelecting = false
    @Published var OnlyShowFavorites = false
    @Published var ShowCreatedAlert = false
    @Published var ShowRenameAlert = false
    @Published var ShowDeleteAlert = false
    @Published var IsSuccessTTProgressHUDVisible = false
    @Published var IsErrorTTProgressHUDVisible = false
    @Published var SelectedSessions: [SessionModel] = []
    @Published var Session: SessionModel?
    @Published var FolderName = ""
    @Published var FolderFavorite = false
    @Published var FolderPinned = false
    @Published var NewName = ""
    @Published var ClampedOpacity: CGFloat = 0.0
    @Published var isActive = false
    @Published var IsScroll = false
    var FolderCreationDate: Date?
    var TodaySection: [SessionModel] = []
    var SessionSection: [SessionModel] = []
    var PinnedSection: [SessionModel] = []
    var DisplayedSessions: [SessionModel] = [] {
        didSet {
            self.TodaySection = DisplayedSessions.filter {
                Calendar.current.isDate($0.createdAt, inSameDayAs: Date()) && !$0.isPinned
            }
            self.SessionSection = DisplayedSessions.filter {
                !Calendar.current.isDate($0.createdAt, inSameDayAs: Date()) && !$0.isPinned
            }
            self.PinnedSection = DisplayedSessions.filter { $0.isPinned }
        }
    }
    
    var Sessions: [SessionModel] = [] {
        didSet {
            self.DisplayedSessions = OnlyShowFavorites ? Sessions.filter { $0.isFavorite } : Sessions
        }
    }
    
    func LoadFolders() {
        Task {
            do {
                let AllSessions = try await FolderRepository.shared.getFolders()
                UpdateSessionModel(SessionModel: AllSessions)
            } catch {
                print("Error loading sessions: \(error)")
                ErrorTTProgressHUD()
            }
        }
    }
    
    private func UpdateSessionModel(SessionModel: [SessionModel]) {
        DispatchQueue.main.async { [weak self] in
            withAnimation(.linear(duration: 0.2)) {
                guard let self else { return }
                self.Sessions = SessionModel
                self.Session = nil
            }
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
                ErrorTTProgressHUD()
            }
        }
    }
    
    func AddPractice() {
        do {
            guard let Container = try SaveRandomVideoToContainer() else { return }
            let VideoPath = Container.VideoPath
            let ThumbnailPath = Container.ThumbnailPath
            let Date = Container.Date
            let Duration = Container.Duration
            let FileSize = Container.Size
            
            Task {
                do {
                    if var LastFolder = try? await FolderRepository.shared.getLastFolder() {
                        var NewPractice = PracticeModel(
                            id: "",
                            Name: Date.dateFormat(StringConstants.DateTimeFormatPractice),
                            ThumbPath: ThumbnailPath,
                            VideoPath: VideoPath,
                            Duration: Duration,
                            FileSize: FileSize,
                            CreatedAt: Date
                        )
                        
                        LastFolder.thumbnail = ThumbnailPath
                        NewPractice.Session = LastFolder
                        _ = try await PracticeRepository.shared.addPractice(&NewPractice)
                    }
                    LoadFolders()
                    SuccessTTProgressHUD()
                } catch {
                    print("Failed to add practice: \(error)")
                    ErrorTTProgressHUD()
                }
            }
        } catch {
            print("An error occurred: \(error)")
            ErrorTTProgressHUD()
        }
    }
    
    func SaveRandomVideoToContainer() throws -> (Date: Date, VideoPath: String, ThumbnailPath: String, Duration: Int64, Size: Int64)? {
        guard let Path = Bundle.main.resourcePath else { return nil }
        
        let FolderURL = URL(fileURLWithPath: Path).appendingPathComponent("GolfSwing")
        let FileURLs = try FileManager.default.contentsOfDirectory(at: FolderURL, includingPropertiesForKeys: nil)
        let VideoURLs = FileURLs.filter { $0.pathExtension.lowercased() == "mp4" }
        
        if let RandomURL = VideoURLs.randomElement() {
            let Data = try Data(contentsOf: RandomURL)
            
            let DocumentsPath = URL.documentsDirectory
            let FolderPath = "Practices/Videos"
            let PracticesPath = DocumentsPath.appendingPathComponent(FolderPath)
            
            try FileManager.default.createDirectory(at: PracticesPath, withIntermediateDirectories: true, attributes: nil)
            
            let Date = Date()
            let DateString = Date.dateFormat("yyyyMMddHHmmssSSS")
            
            let NewFileName = "\(DateString).mp4"
            let VideoPath = FolderPath + "/" + NewFileName
            let VideoDestinationPath = PracticesPath.appendingPathComponent(NewFileName)
            
            try Data.write(to: VideoDestinationPath)
            
            let Asset = AVAsset(url: RandomURL)
            
            // Thumbnail oluştur.
            let AssetImgGenerate = AVAssetImageGenerator(asset: Asset)
            AssetImgGenerate.appliesPreferredTrackTransform = true
            let Time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
            let Img = try AssetImgGenerate.copyCGImage(at: Time, actualTime: nil)
            
            // Thumbnail'i kaydet.
            let Thumbnail = UIImage(cgImage: Img)
            let ThumbnailData = Thumbnail.jpegData(compressionQuality: 0.7)
            let ThumbnailFileName = "\(DateString).jpg"
            let ThumbnailPath = FolderPath + "/" + ThumbnailFileName
            let ThumbnailDestinationPath = PracticesPath.appendingPathComponent(ThumbnailFileName)
            try ThumbnailData?.write(to: ThumbnailDestinationPath)
            
            // Video Süresini Alma
            let DurationInSeconds = CMTimeGetSeconds(Asset.duration)
            let DurationInInt64: Int64 = Int64(DurationInSeconds.rounded())
            
            // Video Boyutunu Alma
            let fileSizeAttributes = try FileManager.default.attributesOfItem(atPath: VideoDestinationPath.path)
            guard let fileSize = fileSizeAttributes[FileAttributeKey.size] as? Int64 else {
                throw NSError(domain: "com.example.yourapp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get file size"])
            }
            
            return (Date, VideoPath, ThumbnailPath, DurationInInt64, fileSize)
        }
        
        return nil
    }
    
    func RenameFolder(NewName: String) {
        Task {
            do {
                if var Folder = Session {
                    Folder.name = NewName
                    Folder.isFavorite = FolderFavorite
                    Folder.isPinned = FolderPinned
                    try await FolderRepository.shared.edit(Folder)
                }
                LoadFolders()
                SuccessTTProgressHUD()
            } catch {
                print("Error updating rename status: \(error)")
                ErrorTTProgressHUD()
            }
        }
    }
    
    func DeleteFolders(_ Folder: [SessionModel]) {
        Task {
            do {
                try await FolderRepository.shared.deleteFolders(Folder)
                LoadFolders()
                SuccessTTProgressHUD()
            } catch {
                print("Error deleting session: \(error)")
                ErrorTTProgressHUD()
            }
        }
        SelectedSessions.removeAll()
    }
    
    func TogglePin() {
        Task {
            do {
                if var Folder = Session {
                    Folder.isPinned.toggle()
                    try await FolderRepository.shared.edit(Folder)
                }
                LoadFolders()
                SuccessTTProgressHUD()
            } catch {
                print("Error updating pin status: \(error)")
                ErrorTTProgressHUD()
            }
        }
    }
    
    func FavoritesButtonAction() {
        isActive = true
        OnlyShowFavorites.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.isActive = false
        }
        DisplayedSessions = OnlyShowFavorites ? Sessions.filter { $0.isFavorite } : Sessions
    }
    
    func ToggleFavorite() {
        Task {
            do {
                if var Folder = Session {
                    Folder.isFavorite.toggle()
                    try await FolderRepository.shared.edit(Folder)
                }
                LoadFolders()
                SuccessTTProgressHUD()
            } catch {
                print("Error updating favorite status: \(error)")
                ErrorTTProgressHUD()
            }
        }
    }
    
    func SelectCancelButtonAction() {
        isActive = true
        IsSelecting.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            self.isActive = false
        }
        if !IsSelecting {
            SelectedSessions.removeAll()
        }
    }
    
    func ToggleSelection(Of Folder: SessionModel) {
        if let Index = SelectedSessions.firstIndex(where: { $0.id == Folder.id }) {
            SelectedSessions.remove(at: Index)
        } else {
            SelectedSessions.append(Folder)
        }
    }
    
    func SelectionCountText(For Count: Int) -> String {
        switch Count {
        case 0:
            return StringConstants.SelectItems
        case 1:
            return StringConstants.OneFolderSelected
        default:
            return String(format: StringConstants.MultipleFoldersSelected, Count)
        }
    }
    
    private func SuccessTTProgressHUD() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.IsSuccessTTProgressHUDVisible = true
        }
    }
    
    private func ErrorTTProgressHUD() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.IsErrorTTProgressHUDVisible = true
        }
    }
    
    func CalculateItemWidth(ScreenWidth: CGFloat, Padding: CGFloat, Amount: CGFloat) -> CGFloat {
        return (ScreenWidth - (Padding * (Amount + 1))) / Amount
    }
    
    func CircleOffset(For ItemWidth: CGFloat, XOffsetValue: CGFloat, YOffsetValue: CGFloat) -> (X: CGFloat, Y: CGFloat) {
        let X = (ItemWidth / 2) - XOffsetValue
        let Y = -(ItemWidth * (1970 / 1080) / 2) + YOffsetValue
        return (X, Y)
    }
    
    func Opacity(For Folder: SessionModel) -> Double {
        return IsSelecting && !SelectedSessions.contains(where: { $0.id == Folder.id }) ? 0.5 : 1.0
    }
    
    func UpdateClampedOpacity(With Proxy: GeometryProxy, Name: String) {
        let Offset = -Proxy.frame(in: .named(Name)).origin.y
        let NormalizedOpacity = (Offset - 10) / (110 - 10)
        ClampedOpacity = min(max(NormalizedOpacity, 0), 1) * 0.75
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
