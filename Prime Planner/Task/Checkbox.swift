//
//  Checkbox.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/16/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import UIKit

class Checkbox: UIButton {
	
	var isChecked: Bool {
		get {
			return isSelected
		}
		set {
			isSelected = newValue
		}
	}
	
	private let imageOn = UIImage(named: "checked-1")
	
	convenience init() {
		self.init(frame: .zero)
		
		// set our images for normal and selected states
		setImage(nil, for: .normal)
		setImage(imageOn, for: .selected)
		
		
		// style the checkbox with a radius and border
		setRadius(3)
		setBorder(1, color: UIColor(white: 0.8, alpha: 1))
		
	}
	
	func checkBoxTapped() {
		
		// toggle between selected states
		isSelected = !isSelected
		
	}
	
}
