//
//  KeyboardService.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit


// simple utility class that will help return the height of the system keyboard
class KeyboardService {
	
	static var shared = KeyboardService()
	static var height: CGFloat {
		return shared.size.height
	}
	static var width: CGFloat {
		return shared.size.width
	}
	
	private var size = CGRect.zero
	private var observerRemoved = false
	
	init() {
		// observe the system keyboard show notification
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
	}
	
	deinit {
		
		// remove the observer, if not already removed
		if !observerRemoved {
			NotificationCenter.default.removeObserver(self)
		}
		
	}
	
	func setup(_ view: UIView) {
		
		// creates an empty textfield, sets it as a responder and then resigns it
		// this forces a call to the observer and retrieves the keyboard size
		if size == .zero {
			let tf = UITextField()
			view.addSubview(tf)
			tf.becomeFirstResponder()
			tf.resignFirstResponder()
			tf.removeFromSuperview()
		}
		
	}
	
	@objc func keyboardWillShow(_ note: Notification) {
		
		// gets the end frame of the keyboard from the notification info
		// only runs if size is .zero, meaning it hasn't already been set
		guard size == .zero, let info = note.userInfo, let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
		
		size = value.cgRectValue
		NotificationCenter.default.removeObserver(self)
		observerRemoved = true
		
	}
	
}
