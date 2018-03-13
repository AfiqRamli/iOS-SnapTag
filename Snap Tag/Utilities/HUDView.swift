//
//  HUDView.swift
//  Snap Tag
//
//  Created by Afiq Ramli on 08/03/2018.
//  Copyright © 2018 Afiq Ramli. All rights reserved.
//

import UIKit

class HUDView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HUDView {
        let hudView = HUDView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    // Creating the HUD Box
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // HUD Image
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.width / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        // Text attributes dictionary
        let attribs = [ NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16),
                           NSAttributedStringKey.foregroundColor : UIColor.white]
        let textSize = text.size(withAttributes: attribs)
        
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.width / 2) + boxHeight / 2.5)
        
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    func show(animated: Bool) {
        if animated {
            // initial state
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            // Animation state
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
    
}










