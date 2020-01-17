//
//  CameraViewController.swift
//  iOSExperiences
//
//  Created by Niranjan Kumar on 1/17/20.
//  Copyright © 2020 Nar Kumar. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer?
    
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tapGesture:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer) {
        print("play movie")
        if tapGesture.state == .ended {
            playRecording()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func videoRecordTapped(_ sender: Any) {
        toggleRecording()
    }
    
    
    // MARK: - Methods
    
    func playRecording() {
        if let player = player {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
    
    func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    
    func toggleRecording() {
        if fileOutput.isRecording {
            // stop
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    func setUpCamera() {
        let camera = bestCamera()
        
        captureSession.beginConfiguration()
        
        // Make changes to the devices connected
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Cannot create camera input")
        }
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.canSetSessionPreset(.hd1920x1080)
        }
        
        // Audio input
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)
        
        
        // Video output (movie)
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Can't setup the file output for the movie")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    
    /// WideAngle Lens is on every iPhone that's been shipped through 2019
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        // Fallback camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        fatalError("No cameras on the device. Or you are running on the Simulator (not supported)")
    }
    
    
    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        
        var topRect = view.bounds
        
        topRect.size.height = topRect.height / 4
        topRect.size.width = topRect.width / 4
        topRect.origin.y = view.layoutMargins.top
        
        playerLayer.frame = topRect
        
        view.layer.addSublayer(playerLayer)
        player?.play()
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // update UI
        updateViews()
    }
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        print("Video: \(outputFileURL.path)")
        updateViews()
        
        playMovie(url: outputFileURL)
        
    }
}
