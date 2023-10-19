//
//  StringConstants.swift
//  Folders
//
//  Created by Kerem Tuna Tomak on 8.09.2023.
//

import Foundation

enum StringConstants {
    static let DateTimeFormatFolder = "yyyyMMdd-HHmmssSSS"
    static let DateTimeFormatPractice = "yyyyMMddHHmmssSSS"
    static let DateFormat = "yyyy.MM.dd"
    static let TimeFormat = "HH:mm:ss.SSS"
    static let Folders = "Folders"
    static let FolderName = "Folder Name"
    static let Videos = "Videos"
    static let SelectItems = "Select Items"
    static let OneFolderSelected = "1 Folder Selected"
    static let MultipleFoldersSelected = "%d Folders Selected"
    static let OneVideoSelected = "1 Video Selected"
    static let MultipleVideosSelected = "%d Videos Selected"
    static let Select = "Select"
    static let Cancel = "Cancel"
    static let NoVideo = "No Video"
    static let LVS = "LVS"
    static let Move = "Move"
    static let Scroll = "Scroll"
    static let SearchFolder = "Search Folder..."
    static let SearchPractice = "Search Practice..."
    
    enum SectionTitle {
        static let Pinned = "Pinned"
        static let Todays = "Todays"
        static let Session = "Session"
    }
    
    enum SystemImage {
        static let Plus = "plus"
        static let Heart = "heart"
        static let Trash = "trash"
        static let HeartFill = "heart.fill"
        static let RectangleStackBadgePlay = "rectangle.stack.badge.play"
        static let NoVideo = "video.slash"
        static let FolderBadgePlus = "folder.badge.plus"
        static let Magnifyingglass = "magnifyingglass"
        static let MultiplyCircleFill = "multiply.circle.fill"
    }
    
    
    enum Alert {
        enum ButtonText {
            static let Create = "Create"
            static let Save = "Save"
            static let Cancel = "Cancel"
            static let Delete = "Delete"
            static let Move = "Move"
        }
        enum Title {
            static let CreateFolder = "Create Folder"
            static let FolderName = "Folder Name"
            static let RenameFolder = "Rename Folder"
            static let VideoName = "Video Name"
            static let RenameVideo = "Rename Video"
            static let Deleting = "Deleting!"
            static let MoveVideo = "Move Video"
        }
        enum Message {
            static let DeleteConfirmationMessage = "Are you sure you want to delete the selected folders?"
            static let MoveConfirmationMessage = "Are you sure you want to move the selected folders?"
        }
        
        enum SystemImage {
            static let Trash = "trash"
            static let FolderFillBadgePlus = "folder.fill.badge.plus"
            static let Pencil = "pencil"
        }
    }
    
    enum ContextMenu {
        case Pin
        case Unpin
        case AddFavorite
        case RemoveFavorite
        case Rename
        case Delete
        case SaveToPhone
        case Move
        
        var SystemImage: String {
            switch self {
            case .Pin:
                return "pin"
            case .Unpin:
                return "pin.slash"
            case .AddFavorite:
                return "heart"
            case .RemoveFavorite:
                return "heart.fill"
            case .Rename:
                return "pencil"
            case .Delete:
                return "trash"
            case .SaveToPhone:
                return "square.and.arrow.down"
            case .Move:
                return "folder.badge.plus"
            }
            
        }
        
        var Text: String {
            switch self {
            case .Pin:
                return "Pin"
            case .Unpin:
                return "Unpin"
            case .AddFavorite:
                return "Add Favorite"
            case .RemoveFavorite:
                return "Remove Favorite"
            case .Rename:
                return "Rename"
            case .Delete:
                return "Delete"
            case .SaveToPhone:
                return "Save to Phone"
            case .Move:
                return "Move"
            }
        }
    }
}
