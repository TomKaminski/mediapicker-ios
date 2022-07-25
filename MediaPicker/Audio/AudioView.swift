import UIKit
import AVFoundation

class AudioView: UIView, UIGestureRecognizerDelegate {
  lazy var mainStackView: UIStackView = self.makeMainStackView()
  
  lazy var playStopButton: UIImageView = self.makePlayStopButton()
  lazy var liveView: WaveformLiveView = self.makeWaveformLiveView()
  lazy var infoLabel: UILabel = self.makeInfoLabel()
  
  lazy var elapsedAudioRecordingTimeLabel: UILabel = self.makeAudioRecordingElapsedTimeLabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  override func updateConstraints() {
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    playStopButton.translatesAutoresizingMaskIntoConstraints = false
    elapsedAudioRecordingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      mainStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -60),
      mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      infoLabel.heightAnchor.constraint(equalToConstant: 80),
      playStopButton.heightAnchor.constraint(equalToConstant: 120),
      playStopButton.widthAnchor.constraint(equalToConstant: 120),
      liveView.heightAnchor.constraint(equalToConstant: 50),
      liveView.widthAnchor.constraint(equalToConstant: 120),
    ])

    super.updateConstraints()
    
    mainStackView.spacing = 12
  }
  
  func setup() {
    [infoLabel, playStopButton, liveView, elapsedAudioRecordingTimeLabel].forEach { mainStackView.addArrangedSubview($0) }
    addSubview(mainStackView)
  }
  
  func makeAudioRecordingElapsedTimeLabel() -> UILabel {
    let label = UILabel(frame: CGRect.zero)
    label.text = self.audioRecordingLabelPlaceholder()
    label.textAlignment = .center
    label.textColor = MediaPickerConfig.shared.colors.lightGray
    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    label.alpha = 0
    return label
  }
  
  func setInfoLabelText(_ text: String) {
    self.infoLabel.text = text
  }
  
  func togglePlayStopButton(isRecording: Bool) {
    let icon = isRecording ? MediaPickerBundle.image("stopRecording") : MediaPickerBundle.image("startRecording")
    
    liveView.fade(visible: isRecording)
    elapsedAudioRecordingTimeLabel.fade(visible: isRecording)
    UIView.transition(with: self.playStopButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
      self.playStopButton.image = icon
    }, completion: nil)
  }
  
  func audioRecordingLabelPlaceholder() -> String {
    return "00:00:00"
  }
  
  private func makePlayStopButton() -> UIImageView {
    let view = UIImageView(image: MediaPickerBundle.image("startRecording"))
    view.contentMode = .scaleAspectFit
    view.isUserInteractionEnabled = true
    view.layer.cornerRadius = 60
    return view
  }
  
  private func makeMainStackView() -> UIStackView {
    let view = UIStackView()
    view.axis = .vertical
    view.distribution = .fill
    view.alignment = .center
    view.spacing = 0
    return view
  }
  
  private func makeInfoLabel() -> UILabel {
    let label = UILabel()
    label.textColor = MediaPickerConfig.shared.colors.black
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    return label
  }
  
  private func makeWaveformLiveView() -> WaveformLiveView {
    let liveView = WaveformLiveView()
    liveView.translatesAutoresizingMaskIntoConstraints = false
    liveView.configuration = Waveform.Configuration(size: CGSize(width: 120, height: 50), backgroundColor: .white, style: .striped(.init(color: MediaPickerConfig.shared.colors.lightGray, width: 3, spacing: 3, lineCap: .round)), dampening: nil, position: .middle, verticalScalingFactor: 1.5, shouldAntialias: true)
    return liveView
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
