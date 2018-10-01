//
//  SelectionViewController~TextView.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

extension SelectionViewController: UITextViewDelegate, UITextFieldDelegate {
	
	func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
		return true
	}
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		return true
	}
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return true
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		view.endEditing(true)
	}
	
}
