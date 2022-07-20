import UIKit
import AVFoundation

public enum GalleryTab: Int {
  case libraryTab = 0
  case cameraTab = 1
  case audioTab = 2
  
  var hasPermission: Bool {
    switch self {
    case .libraryTab:
      return (Permission.Photos.status == .authorized || Permission.Photos.status == .restricted)
    case .cameraTab:
      return Permission.Camera.status == .authorized
    case .audioTab:
      return Permission.Microphone.status == .authorized
    }
  }
}

public struct MediaPickerConfig {
  public init() {}
  
  public static var instance = MediaPickerConfig()
  
  public var tabsToShow: [GalleryTab] = [.libraryTab, .cameraTab, .audioTab]
  public var pageIndicator = PageIndicator()
  public var bottomView = BottomView()
  public var camera = Camera()
  public var audio = Audio()
  public var grid = Grid()
  public var colors = Colors()
  public var emptyView = EmptyView()
  public var translationKeys = TranslationKeys()
  public var videoRecording = VideoRecording()
  public var photoEditor = PhotoEditor()
  public var permission = Permission()
  public var currentLanguage: String = "en"
  
  public struct Colors {
    public var primary = UIColor(red: 97/255, green: 69/255, blue: 146/255, alpha: 1)
    public var black = UIColor(red: 19/255, green: 7/255, blue: 0/255, alpha: 1)
    public var lightGray = UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1)
    public var red = UIColor(red: 196/255, green: 60/255, blue: 53/255, alpha: 1)
  }
  
  public struct PageIndicator {
    public var initialTab = GalleryTab.cameraTab
  }
  
  public struct BottomView {
    public var height: CGFloat = 80
    public var backButton = BackButton()
    public var cart = Cart()
    public var saveButton = SaveButton()
    
    public struct BackButton {
      public var size: CGFloat = 40
      public var leftMargin: CGFloat = 16
      public var icon = MediaPickerBundle.image("arrowLeftIcon")
    }
    
    public struct Cart {
      public var maxItems: Int?
      public var selectedGuid: String?
    }
    
    public struct SaveButton {
      public var icon = MediaPickerBundle.image("Save")?.imageWithInsets(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    }
  }
  
  public struct Camera {
    public var allowVideoRecording = true
    public var allowVideoEdit = true
    public var allowPhotoEdit = true
    public var recordLocation = true
    
    public enum RecordMode { case photo, video }
    
    public var recordMode = RecordMode.photo
  }
  
  public struct Audio {
    public var allowAudioEdit = true
  }
  
  public struct Grid {
    public var dimension = Dimension()
    
    public struct Dimension {
      let columnCount: CGFloat = 4
      let cellSpacing: CGFloat = 2
    }
  }
  
  public struct EmptyView {
    public var image: UIImage? = MediaPickerBundle.image("gallery_empty_view_image")
    public var textColor: UIColor = UIColor(red: 102 / 255, green: 118 / 255, blue: 138 / 255, alpha: 1)
  }
  
  public struct TranslationKeys {
    public var permissionLabelKey = "LandaxApp_Gallery_GaleryAndCamera_Permission"
    public var goToSettingsKey = "LandaxApp_Gallery_Permission_Button"
    public var libraryTabTitleKey = "LandaxApp_Gallery_Library_Title"
    public var cameraTabTitleKey = "LandaxApp_Gallery_Camera_Title"
    public var audioTabTitleKey = "LandaxApp_Gallery_Audio_Title"
    
    public var imageFileTitleKey = "LandaxApp_Gallery_Media_Type_Image"
    public var videoFileTitleKey = "LandaxApp_Gallery_Media_Type_Video"
    public var audioFileTitleKey = "LandaxApp_Gallery_Media_Type_VoiceNote"
    
    public var tapToStopLabelKey = "LandaxApp_Media_Gallery_Audio_StopRecording"
    public var tapToStartLabelKey = "LandaxApp_Media_Gallery_Audio_StartRecording"
    
    public var filenameInputPlaceholderKey = "LandaxApp_Gallery_FilenamePlaceholder"
    
    public var cancelKey = "LandaxApp_Common_NavButton_Cancel"
    public var deleteKey = "LandaxApp_Common_Delete"
    public var discardKey = "LandaxApp_Common_NavButton_Discard"
    
    public var discardElementKey = "LandaxApp_Media_Discard_Element"
    public var discardElementDescriptionKey = "LandaxApp_Media_Discard_Element_Description"
    
    public var discardCartItemsKey = "LandaxApp_Media_Discard_Cart_Items"
    public var discardCartItemsDescriptionKey = "LandaxApp_Media_Discard_Cart_Items_Description"
    
    public var deleteElementKey = "LandaxApp_Media_Delete_Element"
    public var deleteElementDescriptionKey = "LandaxApp_Media_Delete_Element_Description"
    
    public var discardChangesKey = "LandaxApp_Media_Discard_Changes"
    public var discardChangesDescriptionKey = "LandaxApp_Media_Discard_Changes_Description"
    
    public var tapForImageHoldForVideoKey = "LandaxApp_Media_TapForImageHoldForVideo"
    
    public var missingPermissionKey = "LandaxApp_Permissions_NoAccess_GenericDescription"
  }
  
  public struct Permission {
    public var shouldCheckPermission = true
    public var image: UIImage? = MediaPickerBundle.image("gallery_permission_view_camera")
    public var textColor: UIColor = UIColor(red: 102 / 255, green: 118 / 255, blue: 138 / 255, alpha: 1)
    
    public var closeImage: UIImage? = MediaPickerBundle.image("gallery_close")
    public var closeImageTint: UIColor = UIColor(red: 109 / 255, green: 107 / 255, blue: 132 / 255, alpha: 1)
    
    public var button = Button()

    public struct Button {
      public var textColor: UIColor = UIColor.white
      public var highlightedTextColor: UIColor = UIColor.lightGray
      public var backgroundColor = UIColor(red: 40 / 255, green: 170 / 255, blue: 236 / 255, alpha: 1)
    }
  }
  
  public struct VideoRecording {
    public var allow = true
    public var maxBytesCount: Int64?
    public var maxLengthInSeconds: Int?
  }
  
  public struct PhotoEditor {
    public var topToolbarHeight: CGFloat = 60
    public var bottomToolbarHeight: CGFloat = 110
    public var editorCircularButtonSize: CGFloat = 40
    public var textFont = UIFont(name: "Helvetica", size: 24)
    public var lineWidth: CGFloat = 4.0
  }
}
