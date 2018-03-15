//
//  CurrentLocationVC.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 03/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationVC: UIViewController {
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false

    let geoCoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performReverseGeocoding = false
    var lastGeocodingError: Error?
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getLocationButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, let identifierCase = UIViewController.SegueHandlerType(rawValue: identifier) else {
            assertionFailure("Segue had no identifier")
            return
        }
        
        if identifierCase == .locationDetails {
            let navigationController = segue.destination as! UINavigationController
            let locationDetailsVC = navigationController.topViewController as! LocationDetailsVC
            locationDetailsVC.coordinate = self.location!.coordinate
            locationDetailsVC.placemark = self.placemark
            locationDetailsVC.managedObjectContext = self.managedObjectContext
        } else {
            assertionFailure("Did not recognized storyboard identifier")
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
        performSegue(withIdentifier: "locationDetails", sender: self)
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
        displayLocationDisabledAlert()
    }
    
    func getUserLocation() {
        // clear out previous address
        location = nil
        placemark = nil
        lastGeocodingError = nil
        // Start location tracking
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        updatingLocation = true
        getLocationButton.setTitle("Stop", for: .normal)
        print("Fetching users location!")
    }
    
    func stopGetUserLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        updatingLocation = false
        getLocationButton.setTitle("Get Location", for: .normal)
        print("Stop")
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            print("Updating labels")
            
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
                print(addressLabel.text!)
            } else if performReverseGeocoding {
                addressLabel.text = "Searching For Address"
            } else if lastGeocodingError != nil{
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
        }
    }
    
    func displayLocationDisabledAlert() {
        let alert = UIAlertController(title: "Location Disabled", message: "Please change your location permission in Settings", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print("Location services disabled :(")
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        
        if let s = placemark.subThoroughfare {
            line1 += s + ""
        }
        
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        
        if let s = placemark.locality {
            line2 += s + ""
        }
        
        if let s = placemark.administrativeArea {
            line2 += s + ""
        }
        
        if let s = placemark.postalCode {
            line2 += s
        }
        
        return line1 + "\n" + line2
    }
    
}

extension CurrentLocationVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Updating locations!")
        let newLocation = locations.last!
        print(newLocation)
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {
            location = newLocation
            updateLabels()
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                stopGetUserLocation()
                
                if distance > 0 {
                    performReverseGeocoding = false
                }
            }
            
            if !performReverseGeocoding {
                print("*** Going to geocode")
                performReverseGeocoding = true
                geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performReverseGeocoding = false
                    self.updateLabels()
                })
            }
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)
            
            if timeInterval > 10 {
                stopGetUserLocation()
                updateLabels()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("FAIL to update locations!")
        print(error.localizedDescription)
    }
    
}










