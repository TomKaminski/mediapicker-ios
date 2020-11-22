class FileNameComposer {
  public static func getAudioFileName(date: Date = Date()) -> String {
    return formatString(firstPart: MediaPickerConfig.instance.translationKeys.audioFileTitleKey.g_localize(fallback: "VoiceNote"), date: date)
  }
  
  public static func getImageFileName(date: Date = Date()) -> String {
    return formatString(firstPart: MediaPickerConfig.instance.translationKeys.imageFileTitleKey.g_localize(fallback: "Image"), date: date)
  }
  
  public static func getVideoFileName(date: Date = Date()) -> String {
    return formatString(firstPart: MediaPickerConfig.instance.translationKeys.videoFileTitleKey.g_localize(fallback: "Video"), date: date)
  }
  
  private static func formatString(firstPart: String, date: Date = Date()) -> String {
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "dd.MM.yyyy HH_mm_ss"
    return "\(firstPart) \(dateTimeFormatter.string(from: date))"
  }
}
