import UIKit
import AVFoundation

class AudioView: UIView, UIGestureRecognizerDelegate {
  lazy var mainStackView: UIStackView = self.makeMainStackView()
  
  lazy var playStopButton: UIImageView = self.makePlayStopButton()
  lazy var infoLabel: UILabel = self.makeInfoLabel()
  lazy var doneBigButton: UIImageView = self.makeBigDoneButton()
  
  lazy var resetButton: UIImageView = self.makeResetButton()
  lazy var resetInfolabel: UILabel = self.makeInfoLabel()
  lazy var elapsedAudioRecordingTimeLabel: UILabel = self.makeAudioRecordingElapsedTimeLabel()
  
  fileprivate lazy var bottomContainer: UIView = self.makeBottomContainer()
  fileprivate lazy var bottomView: UIView = self.makeBottomView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
    setup()
  }
  
  override func updateConstraints() {
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    playStopButton.translatesAutoresizingMaskIntoConstraints = false
    resetButton.translatesAutoresizingMaskIntoConstraints = false
    elapsedAudioRecordingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
    resetInfolabel.translatesAutoresizingMaskIntoConstraints = false
    doneBigButton.translatesAutoresizingMaskIntoConstraints = false
    
    bottomContainer.translatesAutoresizingMaskIntoConstraints = false
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.resetButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
      self.resetButton.centerXAnchor.constraint(equalTo: self.resetInfolabel.centerXAnchor),
      self.resetInfolabel.topAnchor.constraint(equalTo: self.resetButton.bottomAnchor, constant: 6),
      self.resetInfolabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
      self.mainStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -40),
      self.mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.playStopButton.heightAnchor.constraint(equalToConstant: 100),
      self.doneBigButton.heightAnchor.constraint(equalToConstant: 60),
      self.resetButton.heightAnchor.constraint(equalToConstant: 40)
    ])
    
    bottomContainer.g_pinDownward()
    bottomContainer.g_pin(height: 80)
    bottomView.g_pinEdges()
    
    super.updateConstraints()
    
    mainStackView.spacing = 12
  }
  
  func setup() {
    [playStopButton, infoLabel, elapsedAudioRecordingTimeLabel, doneBigButton].forEach { mainStackView.addArrangedSubview($0) }
    [resetButton, resetInfolabel, mainStackView, bottomContainer].forEach { addSubview($0) }
    [bottomView].forEach { bottomContainer.addSubview($0) }
    
    resetButton.isHidden = true
    resetInfolabel.isHidden = true
  }
  
  func makeAudioRecordingElapsedTimeLabel() -> UILabel {
    let label = UILabel(frame: CGRect.zero)
    label.text = self.audioRecordingLabelPlaceholder()
    label.textAlignment = .center
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    return label
  }
  
  func setInfoLabelText(_ text: String) {
    self.infoLabel.text = text
  }
  
  func setResetInfoLabelText(_ text: String?) {
    if let text = text {
      self.resetInfolabel.text = text
      UIView.animate(withDuration: 0.2) {
        self.resetInfolabel.isHidden = false
        self.resetButton.isHidden = false
      }
    } else {
      UIView.animate(withDuration: 0.2) {
        self.resetInfolabel.isHidden = true
        self.resetButton.isHidden = true
      }
    }
  }
  
  func togglePlayStopButton(isRecording: Bool, reset: Bool = false) {
    let icon: UIImage?
    if reset {
      icon = MediaPickerBundle.image("recordingIconWhite")
    } else {
      icon = isRecording ? MediaPickerBundle.image("recordingIcon") : MediaPickerBundle.image("recordingIconWhite")
    }
    
    UIView.transition(with: self.playStopButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
      self.playStopButton.image = icon
    }, completion: nil)
  }
  
  func toogleDoneButtonVisibility(isHidden: Bool) {
    UIView.animate(withDuration: 0.2) {
      self.doneBigButton.isHiddenInStackView = isHidden
    }
  }
  
  func audioRecordingLabelPlaceholder() -> String {
    return "00:00:00"
  }
  
  private func makePlayStopButton() -> UIImageView {
    let view = UIImageView(image: MediaPickerBundle.image("recordingIconWhite"))
    view.contentMode = .scaleAspectFit
    view.isUserInteractionEnabled = true
    return view
  }
  
  private func makeBigDoneButton() -> UIImageView {
    let view = UIImageView(image: MediaPickerBundle.image("stopRecordingIcon"))
    view.contentMode = .scaleAspectFit
    view.isHidden = true
    view.isUserInteractionEnabled = true
    return view
  }
  
  private func makeResetButton() -> UIImageView {
    let view = UIImageView(image: MediaPickerBundle.image("recordingResetIcon"))
    view.contentMode = .scaleAspectFit
    view.isUserInteractionEnabled = true
    return view
  }
  
  private func makeMainStackView() -> UIStackView {
    let view = UIStackView()
    
    view.axis = .vertical
    view.distribution = .fill
    view.alignment = .fill
    view.spacing = 0
    
    return view
  }
  
  private func makeBottomContainer() -> UIView {
    return UIView()
  }
  
  private func makeBottomView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.init(red: 140/255, green: 140/255, blue: 140/255, alpha: 1)
    return view
  }
  
  private func makeDoneButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitleColor(UIColor.white, for: .normal)
    button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
    button.setTitle("LandaxApp_Gallery_DoneAndSave".g_localize(fallback: "Done and save"), for: .normal)
    
    return button
  }
  
  private func makeInfoLabel() -> UILabel {
    let label = UILabel()
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 14, weight: .light)
    return label
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
