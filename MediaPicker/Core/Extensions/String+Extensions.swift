import Foundation

extension String {
  func g_localize(fallback: String) -> String {
    let language = MediaPickerConfig.shared.currentLanguage
    if let path = Bundle.main.path(forResource: language, ofType: "lproj"), let bundle = Bundle(path: path) {
      let localizedString = NSLocalizedString(self, bundle: bundle, comment: "")
      return localizedString == self ? fallback : localizedString
    }
    return fallback
  }
}
