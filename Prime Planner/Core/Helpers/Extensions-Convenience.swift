//
//  Extensions-Convenience.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
	
	// sets the scale of this view
	func setScale(_ scale: CGFloat, center: Bool = true) {
		transform = CGAffineTransform(scaleX: scale, y: scale)
	}
	
	
	// sets the rotation of this view
	func setRotation(angle: CGFloat) {
		transform = CGAffineTransform(rotationAngle: angle)
	}
	
	// sets the corner radius of this view
	func setRadius(_ radius: CGFloat) {
		self.layer.masksToBounds = true
		self.layer.cornerRadius = radius
	}
	
	// adds a border to the view
	func setBorder(_ width: CGFloat, color: UIColor) {
		self.layer.borderWidth = width
		self.layer.borderColor = color.cgColor
	}
}


extension UIImage {
	
	// returns the image filled with the given color
	func image(withColor color: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
		color.setFill()
		
		let context = UIGraphicsGetCurrentContext()
		context?.translateBy(x: 0, y: self.size.height)
		context?.scaleBy(x: 1.0, y: -1.0)
		context?.setBlendMode(CGBlendMode.normal)
		
		let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		context?.clip(to: rect, mask: self.cgImage!)
		context?.fill(rect)
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}
