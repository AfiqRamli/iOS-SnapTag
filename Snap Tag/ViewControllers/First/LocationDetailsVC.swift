//
//  LocationDetailsVC.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 06/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    print("Creating Date Formatter once!")
    return formatter
}()

class LocationDetailsVC: UITableViewController {
    
    var coordinate = CLLocationCoordinate2DMake(0, 0)
    var placemark: CLPlacemark?
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureLabels()
    }
    
    // MARK: - Actions
    @IBAction func done() {
        
    }
    
    @IBAction func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    func configureNavigationBar() {
    }
    
    func configureLabels() {
        descriptionTextView.text = ""
        categoryLabel.text = ""
        
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)
        
        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        } else {
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: Date())
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
}












