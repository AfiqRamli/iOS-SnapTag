//
//  LocationDetailsVC.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 06/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    print("Creating Date Formatter once!")
    return formatter
}()

class LocationDetailsVC: UITableViewController {

    var categoryName = "No Category"
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var date = Date()
    var descriptionText = ""
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                categoryName = location.category
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                date = location.date
                descriptionText = location.locationDescription
                placemark = location.placemark
            }
        }
    }
    var managedObjectContext: NSManagedObjectContext!
    var placemark: CLPlacemark?
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let location = locationToEdit {
            self.title = "Edit Location"
        }
        configureLabels()

    
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerVC
            controller.selectedCategoryName = categoryName
            controller.delegate = self
        }
    }
    
    // MARK: - Actions
    @IBAction func done() {
        let hudView = HUDView.hud(inView: navigationController!.view, animated: true)
        
        // Create Location Data Model Object
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        } else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
        }
        
        // Setting values to Data Model - to be saved in CoreData
        location.category = categoryName
        location.date = self.date
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.locationDescription = descriptionTextView.text
        location.placemark = self.placemark
        
        // Save to the data store with error catching handler
        do {
            try managedObjectContext.save()
            afterDelay(0.6) {
                self.dismiss(animated: true, completion: nil)
            }
        } catch {
            fatalCoreDataError(error)
        }
    }

    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    func configureLabels() {
        
        descriptionTextView.text = descriptionText
        categoryLabel.text = categoryName
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: self.date)
    }
    
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " " }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " " }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s }
        return text
    }
    
    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        // Set the location of the gesture
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // If touch at the Description cell, nothing happen and return
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 {
            return
        }
        // if gesture occured at other places other than above, remove keyboard
        descriptionTextView.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate

extension LocationDetailsVC {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            // Description TextView Cell Height
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 {
            // Address Cell's height
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 115, height: 10000)
            addressLabel.sizeToFit()
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 15
            
            return addressLabel.frame.size.height + 20
        } else {
            // Default cell's height
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 && indexPath.row == 1 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
    }
}

// MARK: - CategoryPickerDelegate

extension LocationDetailsVC: CategoryPickerVCDelegate {
    func didFinishSelecting(_ category: String) {
        categoryName = category
        // MARK: - Check Below Implmentation of reloading just this one cell!
        configureLabels()
        navigationController?.popViewController(animated: true)
    }
}











