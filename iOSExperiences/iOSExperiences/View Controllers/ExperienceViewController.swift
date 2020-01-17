//
//  ExperienceViewController.swift
//  iOSExperiences
//
//  Created by Niranjan Kumar on 1/17/20.
//  Copyright © 2020 Nar Kumar. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import CoreImage
import CoreImage.CIFilterBuiltins

class ExperienceViewController: UIViewController {
    
    var originalImage: UIImage?
    let context = CIContext(options: nil)
    var imageData: Data?
    
    private let noirFilter = CIFilter.photoEffectNoir()
    private let sepiaFilter = CIFilter.sepiaTone()

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var memoryTextField: UITextField!
    @IBOutlet weak var addImageButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateViews() {
        
    }
    
    // MARK: - Image

    @IBAction func addImage(_ sender: UIButton) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
            
            switch authorizationStatus {
            case .authorized:
                presentImagePickerController()
            case .notDetermined:
                
                PHPhotoLibrary.requestAuthorization { (status) in
                    
                    guard status == .authorized else {
                        NSLog("User did not authorize access to the photo library")
                        self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                        return
                    }
                    
                    self.presentImagePickerController()
                }
                
            case .denied:
                self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
            case .restricted:
                self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
                
            @unknown default:
                NSLog("Problem occuring")
            }
            presentImagePickerController()
        }
    
    @IBAction func addFilter(_ sender: UIButton) {
    
    }
    
    private func displayFilterAction() {
        let alert = UIAlertController(title: "Filters", message: "Which kind of filter do you want to add?", preferredStyle: .actionSheet)
        
        let sepia = UIAlertAction(title: "Sepia", style: .default) { (_) in
            self.updateImage()
        }
        
//        let noir = UIAlertAction(title: "Noir", style: .default) { (_) in
//            self.updateImage()
//        }
        
        alert.addAction(sepia)
    }

        func updateImage() {
            if let originalImage = originalImage {
                let filteredImage = filterImage(originalImage)
                imageView.image = filteredImage
            } else {
                imageView.image = nil
            }
        }
        
    func filterImage(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        var ciImage = CIImage(cgImage: cgImage)
        
        var aFilter = CIFilter()
        
        aFilter = sepiaFilter
        
        aFilter.setValue(ciImage, forKey: kCIInputImageKey)
        if let outputCIImage = aFilter.outputImage {
            ciImage = outputCIImage
        }
        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        
        // Rendering Image Again
        guard let outputCGImage = context.createCGImage(ciImage, from: bounds) else { return image }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    
    
    private func presentImagePickerController() {
            
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
                return
            }
            
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            
            imagePicker.sourceType = .photoLibrary
            
            present(imagePicker, animated: true, completion: nil)
        }
    
    func presentInformationalAlertController(title: String?, message: String?, dismissActionCompletion: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: dismissActionCompletion)
        
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true, completion: completion)
    }
    
    // MARK: - Audio
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    var recordURL: URL?
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        playPause()
    }
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        recordToggle()
    }
    
    func record() {
        // Path to save in the Documents directory
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // Filename (ISO8601 format for time) .caf
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        
        // 2020-1-14.caf
        let file = documentsDirectory.appendingPathComponent(name).appendingPathExtension("caf")
        
        //        print("record URL: \(file)")
        
        // 44.1 Khz is CD quality audio
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        // Start a recording
        audioRecorder = try! AVAudioRecorder(url: file, format: format) // FIXME: error handling
        recordURL = file
        audioRecorder?.delegate = self
        audioRecorder?.record()
        updateViews()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        updateViews()
    }
    
    func recordToggle() {
        if isRecording {
            stopRecording()
        } else {
            record()
        }
    }
    
    func play() {
        audioPlayer?.play()
        updateViews()
    }
    
    func pause() {
        audioPlayer?.pause()
        updateViews()
    }
    
    func playPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    
    // MARK: - Video
    
    @IBAction func addVideo(_ sender: UIButton) {
        requestPermissionAndShowCamera()
    }
    
        private func requestPermissionAndShowCamera() {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
             
            switch status {
                
            case .notDetermined:
                // First time user - they haven't seen teh dialog to give permission
                requestPermission()
            case .restricted:
                // Parental controls disabled the camera
                fatalError("Video is dsaled for the user (parental controls)")
                // TODO: Add UI to inform the user (talk to parents)
            case .denied:
                //User did not give us access (maybe it was an accident)
                fatalError("Tell the user they need to enabe Privacy for videos")
            case .authorized:
                // we asked for permission (2nd time they've used the app)
                showCamera()
            @unknown default:
                fatalError("A new status was added that we need to handle")
            }
        }
        
        private func requestPermission() {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                guard granted else {
                    fatalError("Tell user they need to enable Privacy for Video")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.showCamera()
                }
            }
        }
        
        private func showCamera() {
            performSegue(withIdentifier: "AddVideoSegue", sender: self)
        }
}

// MARK: - Extensions
extension ExperienceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        addImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        originalImage = image
        
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ExperienceViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio playback error: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
}

extension ExperienceViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Record error: \(error)")
        }
    }
    
    func ExperienceViewController(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        // TODO: Create player with new file URL
        
        if let recordURL = recordURL {
            audioPlayer = try! AVAudioPlayer(contentsOf: recordURL) // FIXME: make safer
            updateViews()
        }
    }
}
