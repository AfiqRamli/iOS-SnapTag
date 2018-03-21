//
//  UIImage+Resize.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 20/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit

extension UIImage {
    
    // methods to resize large image to fit thumbnails
    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        
        // Calculate the ratio of the thumbnail bounds to the actual image
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio  = min(horizontalRatio, verticalRatio)
        
        // Determine the new size of thumbnail image based on the aspectFit ratio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        // Creates new image context and draws the image into that
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
