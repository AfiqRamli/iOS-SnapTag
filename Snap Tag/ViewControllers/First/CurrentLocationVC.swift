//
//  CurrentLocationVC.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 03/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationVC: UIViewController {
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func enableLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            disableLocationBasedFeatures()
            break
            
        case .authorizedAlways:
            break
        
        case .authorizedWhenInUse:
            checkForLocationServices()
            break
        }
    }
    
    //MARK: - Actions
    
    @IBAction func getLocationBtnPressed(_ sender: UIButton) {
        if updatingLocation {
            stopGetUserLocation()
        } else {
            enableLocationServices()
        }
    }
    
    @IBAction func tagLocationBtnPressed() {
        print("Tag Button pressed!")
    }
    
    //MARK: - Private methods
    
    func checkForLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            getUserLocation()
        } else {
            print("Sorry your phone sucks!")
        }
    }
    
    func disableLocationBasedFeatures() {
        //set alert for user to change locations permission
        let alert = UIAlertController(title: "Location Disabled", message: "Please change your location permission in Settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("Location services disabled :(")
    }
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        updatingLocation = true
        print("Fetching users location!")
    }
    
    func stopGetUserLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        updatingLocation = false
        print("Stop")
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            print(location.coordinate)
            print("Updating labels")
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
        }
    }
}

extension CurrentLocationVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating locations!")
        let newLocation = locations.last!
        location = newLocation
        updateLabels()
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopGetUserLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("FAIL to update locations!")
        print(error.localizedDescription)
    }
    
}










