//
//  KeyboardService.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

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
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
	}
	
	deinit {
		if !observerRemoved {
			NotificationCenter.default.removeObserver(self)
		}
	}
	
	func setup(_ view: UIView) {
		
		if size == .zero {
			let tf = UITextField()
			view.addSubview(tf)
			tf.becomeFirstResponder()
			tf.resignFirstResponder()
			tf.removeFromSuperview()
		}
		
	}
	
	@objc func keyboardWillShow(_ note: Notification) {
		
		guard size == .zero, let info = note.userInfo, let value = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
		
		size = value.cgRectValue
		NotificationCenter.default.removeObserver(self)
		observerRemoved = true
		
	}
	
}
