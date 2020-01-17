//
//  MapViewController.swift
//  iOSExperiences
//
//  Created by Niranjan Kumar on 1/17/20.
//  Copyright © 2020 Nar Kumar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    let annotationReuseIdentifier = "PostAnnotation"

    let location = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        mapView.delegate = self
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: annotationReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotations = pos
        
        mapView.addAnnotations(annotations)
    }
    
    @IBAction func createExperience(_ sender: Any) {
    }
    
    func setupLocationManager() {
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = location.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
        case .denied:
            break
        case .notDetermined:
            location.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        default:
            break
        }
    }
    
    
}

extension MapViewController: CLLocationManagerDelegate {

}
extension MapViewController: MKMapViewDelegate {
    
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//    return MKAnnotationView
//    }
}
