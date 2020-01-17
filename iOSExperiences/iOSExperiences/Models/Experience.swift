//
//  Experience.swift
//  iOSExperiences
//
//  Created by Niranjan Kumar on 1/17/20.
//  Copyright © 2020 Nar Kumar. All rights reserved.
//

import Foundation
import MapKit

enum MediaType: String {
    case image
    case video
}

class Experience {
    
    var memory: String
    var mediaURL: URL
    var mediaType: MediaType
    var audioURL: URL?
    var geotag: CLLocationCoordinate2D?

    
    init(memory: String, mediaURL: URL, mediaType: MediaType, audioURL: URL? = nil, geotag: CLLocationCoordinate2D?) {
        self.memory = memory
        self.mediaType = mediaType
        self.mediaURL = mediaURL
        self.audioURL = audioURL
        self.geotag = geotag
    }
}
 
//extension Experience: NSObject, MKAnnotation {
//    var coordinate: CLLocationCoordinate2D {
//        CLLocationCoordinate2D(latitude: 100, longitude: 100)
//    }
    

