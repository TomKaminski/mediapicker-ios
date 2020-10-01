import AVFoundation
import UIKit

extension UIView {
  var isHiddenInStackView: Bool {
    get {
      return isHidden
    }
    set {
      if isHidden != newValue {
        isHidden = newValue
      }
    }
  }
}

class AudioController: UIViewController, AVAudioRecorderDelegate {
  lazy var audioView: AudioView = self.makeAudioView()
  let cart: Cart

  var audioRecorder: AVAudioRecorder!
  var recordingSession: AVAudioSession!
  var isPaused: Bool = false
  var recordTimer: Timer?
  var fileName: String!
  
  public required init(cart: Cart) {
    self.cart = cart
    super.init(nibName: nil, bundle: nil)
    cart.delegates.add(self)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    recordingSession = AVAudioSession.sharedInstance()
    do {
      try recordingSession.setCategory(.playAndRecord, mode: .default)
      try recordingSession.setActive(true)
      setup()
    } catch {
      
    }
  }
  
  private func setup() {
    view.addSubview(audioView)
    
    audioView.translatesAutoresizingMaskIntoConstraints = false
    audioView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    audioView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    audioView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    
    if #available(iOS 11, *) {
      audioView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      audioView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
    
    
    let playStopButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButtonTouched))
    audioView.playStopButton.addGestureRecognizer(playStopButtonGestureRecognizer)
    
    let doneBigButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doneButtonTouched))
    audioView.doneBigButton.addGestureRecognizer(doneBigButtonGestureRecognizer)
    
    let resetButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clearData))
    audioView.resetButton.addGestureRecognizer(resetButtonGestureRecognizer)
    
    self.audioView.toogleDoneButtonVisibility(isHidden: true)
    self.audioView.setInfoLabelText(startRecordingLabelText)
  }
  
  private func makeAudioView() -> AudioView {
    return AudioView(frame: CGRect.zero)
  }
  
  //------
  //Play button behavior
  //------
  
  @objc private func playButtonTouched() {
    if audioRecorder == nil {
      EventHub.shared.changeMediaPickerState?(.AudioRecording)
      if pagesController.cartButton.cartOpened {
        self.pagesController.cartButtonTapped()
      }
      
      startRecording()
    } else if isPaused {
      resumeRecording()
    } else {
      pauseRecording()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    clearDataFunc()
  }
  
  private func startRecording() {
    let tempPath = getTempPathUrl()
    
    let settings:[String : Any] = [ AVFormatIDKey : kAudioFormatMPEG4AAC,
                                    AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                    AVEncoderBitRateKey: 320000,
                                    AVNumberOfChannelsKey : 2,
                                    AVSampleRateKey : 44100.0 ] as [String : Any]
    
    do {
      audioRecorder = try AVAudioRecorder(url: tempPath, settings: settings)
      audioRecorder.delegate = self
      audioRecorder.record()
      
      self.audioView.toogleDoneButtonVisibility(isHidden: false)
      self.audioView.setInfoLabelText(pauseRecordingLabelText)
      
      self.audioView.setResetInfoLabelText(MediaPickerConfig.instance.translationKeys.tapToResetLabelKey.g_localize(fallback: "Tap to reset"))
      
      self.recordTimer = Timer.scheduledTimer(
        timeInterval: 0.5, target: self, selector: #selector(audioRecodringTimerFired), userInfo: nil, repeats: true)
      self.audioView.togglePlayStopButton(isRecording: true)
    } catch {
      debugPrint(error)
    }
  }
  
  private func getTempPathUrl() -> URL {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    let dateTimeFormatter = DateFormatter()
    dateTimeFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
    self.fileName = "Voice Note \(dateTimeFormatter.string(from: Date()))"
    
    return URL.init(fileURLWithPath: "\(path)/\(fileName!).m4a")
  }
  
  private func pauseRecording() {
    isPaused = true
    self.audioView.togglePlayStopButton(isRecording: false)
    audioRecorder?.pause()
    self.audioView.setInfoLabelText(MediaPickerConfig.instance.translationKeys.tapToContinueLabelKey.g_localize(fallback: "Tap to continue recording"))
    
    self.recordTimer?.invalidate()
    self.recordTimer = nil
  }
  
  private func resumeRecording() {
    isPaused = false
    
    self.audioView.togglePlayStopButton(isRecording: true)
    audioRecorder?.record()
    self.audioView.setInfoLabelText(pauseRecordingLabelText)
    self.recordTimer = Timer.scheduledTimer(
      timeInterval: 0.5, target: self, selector: #selector(audioRecodringTimerFired), userInfo: nil, repeats: true)
  }
  
  @objc private func audioRecodringTimerFired() {
    guard let timeInterval = audioRecorder?.currentTime else {
      return
    }
    let ti = NSInteger(timeInterval)
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
    self.audioView.elapsedAudioRecordingTimeLabel.text = String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
  }
  
  
  //------
  //Clear button behavior
  //------
  
  @objc private func clearData() {
    clearDataFunc()
    EventHub.shared.changeMediaPickerState?(.Audio)
  }
  
  private func clearDataFunc() {
    audioRecorder?.deleteRecording()
    audioRecorder = nil
    self.recordTimer?.invalidate()
    self.recordTimer = nil
    isPaused = false
    
    self.audioView.setResetInfoLabelText(nil)
    self.audioView.togglePlayStopButton(isRecording: false, reset: true)
    self.audioView.elapsedAudioRecordingTimeLabel.text = self.audioView.audioRecordingLabelPlaceholder()
    self.audioView.toogleDoneButtonVisibility(isHidden: true)
    self.audioView.setInfoLabelText(startRecordingLabelText)
  }
  
  
  //------
  //Done button behavior
  //------
  
  @objc func doneButtonTouched() {
    pauseRecording()
    audioRecorder?.stop()

    if let url = audioRecorder?.url, let audio = try? Audio(audioFile: AVAudioFile(forReading: url), customFileName: FileNameComposer.getAudioFileName(), guid: UUID().uuidString, dateAdded: Date()) {
      self.cart.add(audio)
      MediaPickerConfig.instance.bottomView.cart.selectedGuid = audio.guid

      audioRecorder = nil
      self.recordTimer?.invalidate()
      self.recordTimer = nil
      isPaused = false
      
      self.audioView.setResetInfoLabelText(nil)
      self.audioView.togglePlayStopButton(isRecording: false, reset: true)
      self.audioView.elapsedAudioRecordingTimeLabel.text = self.audioView.audioRecordingLabelPlaceholder()
      self.audioView.toogleDoneButtonVisibility(isHidden: true)
      self.audioView.setInfoLabelText(startRecordingLabelText)
      EventHub.shared.changeMediaPickerState?(.Audio)

      self.addAudioTakenChildrenController(audio: audio)
    } else {
      clearData()
    }
  }
  
  var startRecordingLabelText: String {
    return MediaPickerConfig.instance.translationKeys.tapToStartLabelKey.g_localize(fallback: "Tap to start recording")
  }
  
  var pauseRecordingLabelText: String {
    return MediaPickerConfig.instance.translationKeys.tapToPauseLabelKey.g_localize(fallback: "Tap to pause recording")
  }
  
  private func addAudioTakenChildrenController(audio: Audio) {
    EventHub.shared.executeCustomAction?(audio.guid)
  }
  
  var pagesController: PagesController {
    return self.parent as! PagesController
  }
}

