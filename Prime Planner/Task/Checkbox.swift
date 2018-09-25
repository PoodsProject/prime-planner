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
	
	var isChecked: Bool { return isSelected }
	
	private let imageOn = #imageLiteral(resourceName: "checked-1")
	private let imageOff = #imageLiteral(resourceName: "unchecked-1")
	
	convenience init() {
		self.init(frame: .zero)
		
		// set our images for normal and selected states
		setImage(imageOff, for: .normal)
		setImage(imageOn, for: .selected)
		
	}
	
	func checkBoxTapped() {
		
		// if selected then deselect else select
		// ! = not, so this is just toggling between selected state
		isSelected = !isSelected
		
	}
	
}
