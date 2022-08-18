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
  var fileName: String!
  
  var recordTimer: Timer?
  var waveformTimer: Timer?

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
    view.backgroundColor = MediaPickerConfig.shared.colors.black
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
    audioView.backgroundColor = .white
    audioView.translatesAutoresizingMaskIntoConstraints = false
    audioView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    audioView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    audioView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    audioView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
    
    let playStopButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButtonTouched))
    audioView.playStopButton.addGestureRecognizer(playStopButtonGestureRecognizer)
    audioView.setInfoLabelText(startRecordingLabelText)
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
      if pagesController.cartOpened {
        self.pagesController.cartButtonTapped()
      }
      
      startRecording()
    } else  {
      pagesController.bottomView.cartButton.startLoading()

      audioRecorder?.stop()

      if let url = audioRecorder?.url, let audio = try? Audio(audioFile: AVAudioFile(forReading: url), customFileName: FileNameComposer.getFileName(), guid: UUID().uuidString, dateAdded: Date()) {
        self.cart.add(audio)
        
        audioRecorder = nil
        
        recordTimer?.invalidate()
        recordTimer = nil
        waveformTimer?.invalidate()
        waveformTimer = nil
        audioView.liveView.reset()
                
        self.audioView.togglePlayStopButton(isRecording: false)
        self.audioView.elapsedAudioRecordingTimeLabel.text = self.audioView.audioRecordingLabelPlaceholder()
        self.audioView.setInfoLabelText(startRecordingLabelText)
        EventHub.shared.changeMediaPickerState?(.Audio)
      } else {
        clearData()
      }
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
      audioRecorder.isMeteringEnabled = true
  
      audioView.setInfoLabelText(pauseRecordingLabelText)
      recordTimer = Timer.scheduledTimer(
        timeInterval: 0.5, target: self, selector: #selector(audioRecordingTimerFired), userInfo: nil, repeats: true)
      waveformTimer = Timer.scheduledTimer(
        timeInterval: 0.015, target: self, selector: #selector(waveformTimerFired), userInfo: nil, repeats: true)
      
      audioView.togglePlayStopButton(isRecording: true)
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
  
  @objc private func audioRecordingTimerFired() {
    guard let recorder = audioRecorder else {
      return
    }
    
    let ti = NSInteger(recorder.currentTime)
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
    
    audioView.elapsedAudioRecordingTimeLabel.text = String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
  }
  
  @objc private func waveformTimerFired() {
    guard let recorder = audioRecorder else {
      return
    }
    
    recorder.updateMeters()
    let currentAmplitude = 1 - pow(10, recorder.averagePower(forChannel: 0) / 20)
    audioView.liveView.add(sample: currentAmplitude)
  }
  
  
  //------
  //Clear button behavior
  //------
  
  @objc private func clearData() {
    clearDataFunc()
    EventHub.shared.changeMediaPickerState?(.Audio)
  }
  
  internal func clearDataFunc() {
    audioRecorder?.deleteRecording()
    audioRecorder = nil
    recordTimer?.invalidate()
    recordTimer = nil
    
    waveformTimer?.invalidate()
    waveformTimer = nil
    audioView.liveView.reset()
    
    audioView.togglePlayStopButton(isRecording: false)
    audioView.elapsedAudioRecordingTimeLabel.text = audioView.audioRecordingLabelPlaceholder()
    audioView.setInfoLabelText(startRecordingLabelText)
  }
  
  
  //------
  //Done button behavior
  //------
  
  var startRecordingLabelText: String {
    return MediaPickerConfig.shared.translationKeys.tapToStartLabelKey.g_localize(fallback: "Tap to start recording")
  }
  
  var pauseRecordingLabelText: String {
    return MediaPickerConfig.shared.translationKeys.tapToStopLabelKey.g_localize(fallback: "Tap to stop recording")
  }
  
  var pagesController: PagesController {
    return self.parent as! PagesController
  }
}

