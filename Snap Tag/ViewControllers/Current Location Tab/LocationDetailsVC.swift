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
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.isHidden = false
            imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
            addPhotoLabel.isHidden = true
        }
    }
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
    var observer: Any!
    var placemark: CLPlacemark?
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
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
    
    deinit {
        print("Deinit \(self)")
        NotificationCenter.default.removeObserver(observer)
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
            location.photoID = nil
        }
        
        // Setting values to Data Model - to be saved in CoreData
        location.category = categoryName
        location.date = self.date
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.locationDescription = descriptionTextView.text
        location.placemark = self.placemark
        
        // This code is performed if image is not nil or when user has picked a photo
        if let image = self.image {
            // determine to set or replace existing photoID
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }
            // converts UIImage to JPEG format and returns a Data object
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                // Save the data object to the path given  bt the photoURL property
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                } catch {
                    print("Error writing file: \(error)")
                }
            }
        }
        
        
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
    
    func show(image: UIImage) {
        imageView.image = image
        imageView.isHidden = false
        imageView.frame = CGRect(x: 10, y: 10, width: 260, height: 260)
        addPhotoLabel.isHidden = true
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
    
    func listenForBackgroundNotification() {
        observer = NotificationCenter.default.addObserver(
            forName: Notification.Name.UIApplicationDidEnterBackground,
            object: nil, queue: OperationQueue.main) {
                [weak self] _ in
                if let strongSelf = self {
                    if strongSelf.presentedViewController != nil {
                        strongSelf.dismiss(animated: false, completion: nil)
                    }
                    strongSelf.descriptionTextView.resignFirstResponder()
                }
        } }
}

// MARK: - UITableViewDelegate

extension LocationDetailsVC {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            // Description TextView Cell Height
            return 88
            
        } else if indexPath.section == 1{
            
            // Height of the photo cell
            if imageView.isHidden {
                return 44
            } else {
                return 280
            }
            
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
        } else if indexPath.section == 1 && indexPath.row == 0 {
            setLocationPhoto()
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

// MARK: - ImagePickerDelegate

extension LocationDetailsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setLocationPhoto() {
        let alert = UIAlertController(title: "Add Photo", message: "Choose photo source:", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.openCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            self.openPhotoLibrary()
        }
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        
        // Check if a camera exists
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            openPhotoLibrary()
        }
    }
    
    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}









