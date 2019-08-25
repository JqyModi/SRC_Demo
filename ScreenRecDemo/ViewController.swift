//
//  ViewController.swift
//  ScreenRecDemo
//
//  Created by Modi on 2019/8/14.
//  Copyright © 2019年 modi. All rights reserved.
//

import UIKit
import ReplayKit

class ViewController: UIViewController {
    
    var microInput: AVAssetWriterInput!
    
    var assetWriter: AVAssetWriter!
    var url: URL!
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    let screenRecorder = RPScreenRecorder.shared()
    
    var audioPlayer: AVAudioPlayer!
    
    let path = NSHomeDirectory().appending("/Documents/\(UUID().uuidString).mov")
    
    let audioPath = NSHomeDirectory().appending("/Documents/\(UUID().uuidString).m4a")
    
    var audioRecorder: AERecorder!
    var audioController: AEAudioController!
    var aeAudioPlayer: AEAudioFilePlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.url = URL(fileURLWithPath: path)
//        self.playMp3()
        setAudioController()
    }

    func setAudioController() {
        // Create an instance of the audio controller, set it up and start it running
        audioController = AEAudioController(audioDescription: AEAudioStreamBasicDescriptionNonInterleavedFloatStereo, inputEnabled: true)
        audioController.preferredBufferDuration = 0.005
        audioController.useMeasurementMode = true
        try? audioController.start()
    }
    
    @IBAction func start(_ sender: Any) {
        if #available(iOS 11.0, *) {
            do {
                
//                if FileManager.default.fileExists(atPath: path) {
//                    try? FileManager.default.removeItem(at: self.url)
//                }
                unlink((path as NSString).utf8String)
                
                assetWriter = try AVAssetWriter(outputURL: url, fileType: AVFileType.mov)
                // video
                let videoCompressionPropertys = [AVVideoAverageBitRateKey: NSNumber(value: 128.0 * 1024.0)]
                let videoOutputSettings = [
                    AVVideoCodecKey : AVVideoCodecType.h264,
                    AVVideoWidthKey : UIScreen.main.bounds.width * UIScreen.main.scale,
                    AVVideoHeightKey : UIScreen.main.bounds.height * UIScreen.main.scale,
                    AVVideoCompressionPropertiesKey : videoCompressionPropertys
                    ] as [String : Any]
                videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
                videoInput.expectsMediaDataInRealTime = true
                if assetWriter.canAdd(videoInput) {
                    assetWriter.add(videoInput)
                    NSLog("视频输入源添加成功")
                }else {
                    NSLog("视频输入源添加失败")
                }
                // audio
                var acl = AudioChannelLayout()
                bzero(&acl, MemoryLayout<AudioChannelLayout>.size)
                acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono
                let audioOutputSettings = [
                    AVFormatIDKey: kAudioFormatMPEG4AAC,
                    AVNumberOfChannelsKey: 1,
                    AVSampleRateKey: 44100.0,
                    AVEncoderBitRateKey: 64000,
                    AVChannelLayoutKey: NSData(bytes: &acl, length: MemoryLayout<AudioChannelLayout>.size)
                    ] as [String : Any]
                audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
                audioInput.expectsMediaDataInRealTime = true
                if assetWriter.canAdd(audioInput) {
                    assetWriter.add(audioInput)
                    NSLog("音频输入源添加成功")
                }else {
                    NSLog("音频输入源添加失败")
                }
            }
            catch {
                NSLog("Failed starting screen capture: \(error.localizedDescription)")
                // handle error
            }
            
            // start the screen capturing
            screenRecorder.isMicrophoneEnabled = true
//            screenRecorder.isCameraEnabled = true
            NSLog("iphone screen enable = [\(screenRecorder.isAvailable)]")
            screenRecorder.startCapture(handler: { (sample, bufferType, error) in
                if let error = error {
                    NSLog("Error capturing screen: \(error)")
                }
                
                // store the video/audio samples
                if bufferType == .video && self.assetWriter.status == .unknown {
                    self.assetWriter.startWriting()
                    self.assetWriter.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                    NSLog("asset writer started")
                }
                
                if self.assetWriter.status == .failed {
                    NSLog("Error writing screencast to file: \(self.assetWriter.status.rawValue)")
                }
                
                if self.assetWriter.status == .writing {
                    if bufferType == .video {
                        if self.videoInput.isReadyForMoreMediaData {
                            NSLog("视频写入中")
                            self.videoInput.append(sample)
                        }
                    }
                    if bufferType == .audioApp {
                        if self.audioInput.isReadyForMoreMediaData {
                            NSLog("APP音频写入中")
                            self.audioInput.append(sample)
                        }
                    }
                    if bufferType == .audioMic {
                        if self.audioInput.isReadyForMoreMediaData {
                            NSLog("Mic音频写入中")
                            self.audioInput.append(sample)
                        }
                    }
                }
                
                if self.assetWriter.status == .completed {
                    self.assetWriter.endSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sample))
                }
                
            }, completionHandler: { error in
                DispatchQueue.main.async {
                    if let error = error {
                        NSLog("Failed starting screen capture: \(error.localizedDescription)")
                        // handle error
                    }
                    else {
                        NSLog("Screen capture started successfully.")
                        // handle success
                    }
                }
            })
        } else {
            // Fallback on earlier versions
            if #available(iOS 9.0, *) {
                screenRecorder.startRecording(withMicrophoneEnabled: true) { error in
                    // ...
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func stop(_ sender: Any) {
        if #available(iOS 11.0, *) {
            screenRecorder.stopCapture { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        NSLog("Failed stop screen capture: \(error.localizedDescription)")
                        // handle error
                    }
                    else {
                        NSLog("Screen capture stop successfully.")
                        // handle success
                        while self.assetWriter.status == .completed {
                            self.videoInput.markAsFinished()
                            self.audioInput.markAsFinished()
                            self.assetWriter.finishWriting {
                                if self.assetWriter.status == .completed, FileManager.default.fileExists(atPath: self.path) {
                                    NSLog("录制成功：\(self.path)")
                                    self.clear()
                                }
                            }
                        }
                    }
                }
            }
        }else {
            screenRecorder.stopRecording { (previewController, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        NSLog("Failed stop screen capture: \(error.localizedDescription)")
                        // handle error
                    }
                    else {
                        NSLog("Screen capture stop successfully.")
                        // handle success
                        if FileManager.default.fileExists(atPath: self.path) {
                            NSLog("录制成功：\(self.path)")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func playVideo(_ sender: Any) {
        if FileManager.default.fileExists(atPath: self.path) {
            NSLog("视频播放地址：\(self.path)")
            self.audioPlayer.pause()
            self.playWithUrl(path: self.path)
        }
    }
    
    func clear() {
        self.videoInput = nil
        self.audioInput = nil
        self.assetWriter = nil
    }
    
    /** 播放方法 */
    func playWithUrl(path: String) {
        // 传入地址
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: path))
        // 播放器
        let player = AVPlayer(playerItem: playerItem)
        // 播放器layer
        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.backgroundColor = UIColor.lightGray.cgColor
        playerLayer.frame = self.view.frame;
        // 视频填充模式
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect;
        // 添加到imageview的layer上
        self.view.layer.addSublayer(playerLayer)
        // 播放
        player.play()
    }
    
    func playMp3() {
        let audioSession = AVAudioSession.sharedInstance()
        if #available(iOS 10.0, *) {
            try? audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
        } else {
            // Fallback on earlier versions
        }
        try? audioSession.setActive(true)
        let url = Bundle.main.url(forResource: "一个人的冬天", withExtension: "mp3")
        audioPlayer = try? AVAudioPlayer(contentsOf: url!)
        //设置音频对象播放的音量的大小
        audioPlayer.volume = 1.0
        //设置音频播放的次数，-1为无限循环播放
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }
    
    @IBAction func recordAudio(_ sender: UIButton) {
        if let recorder = audioRecorder {
            recorder.finishRecording()
            audioController.removeOutputReceiver(recorder) {
                print("移除输出流")
            }
            audioController.removeInputReceiver(recorder) {
                print("移除输入流")
            }
            self.audioRecorder = nil
            sender.isSelected = false
        }else {
            self.audioRecorder = AERecorder(audioController: audioController)
            do {
                try audioRecorder.beginRecordingToFile(atPath: audioPath, fileType: kAudioFileM4AType)
                sender.isSelected = true
                audioController.addOutputReceiver(audioRecorder) {
                    print("添加输出流")
                }
                audioController.addInputReceiver(audioRecorder) {
                    print("添加输入流")
                }
            }catch {
                self.audioRecorder = nil
                print(error)
                return
            }
        }
        
    }
    
    
    @IBAction func playAudio(_ sender: UIButton) {
//        self.playWithUrl(path: audioPath)
        if let player = self.aeAudioPlayer {
            audioController.removeChannels([player]) {
                print("移除播放器")
            }
            self.aeAudioPlayer = nil
            sender.isSelected = false
        }else {
            if !FileManager.default.fileExists(atPath: audioPath) {return}
            do {
                self.aeAudioPlayer = try AEAudioFilePlayer(url: URL(fileURLWithPath: audioPath))
                self.aeAudioPlayer.removeUponFinish = true
                self.aeAudioPlayer.completionBlock = {[weak self] in
                    sender.isSelected = false
                    self?.aeAudioPlayer = nil
                }
                audioController.addChannels([self.aeAudioPlayer]) {
                    print("添加频道")
                }
                sender.isSelected = true
            }catch {
                print(error)
                return
            }
        }
    }
}

