//
//  CameraPreviewView.swift
//  iOSExperiences
//
//  Created by Niranjan Kumar on 1/17/20.
//  Copyright © 2020 Nar Kumar. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    
      override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var videoPlayerView: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
        
        var session: AVCaptureSession? {
            get { return videoPlayerView.session }
            set { videoPlayerView.session = newValue }
        }
    }

