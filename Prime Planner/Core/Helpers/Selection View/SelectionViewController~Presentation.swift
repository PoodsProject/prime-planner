//
//  SelectionViewController~Presentation.swift
//  Money
//
//  Created by Jacob Caraballo on 6/19/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

extension SelectionViewController {
	
	func dismiss(_ item: SelectionItem?, cancelled: Bool) {
		completion?(item, cancelled)
		dismiss(animated: true, completion: nil)
	}
	
	class func present(_ parent: UIViewController, type: SelectionType, item: SelectionItem, showsNoItemSection: Bool, completion: ((_ item: SelectionItem?, _ cancelled: Bool) -> ())? = nil) {
		
		let vc = SelectionViewController(type: type, item: item)
		vc.transitioningDelegate = vc
		vc.modalPresentationStyle = .custom
		
		vc.initHandler = {
			vc.completion = completion
			vc.showsNoItemSection = showsNoItemSection
			vc.loadData()
		}
		
		parent.present(vc, animated: true, completion: nil)
		DispatchQueue.main.async {}
		
	}
	
	class func present(_ parent: UIViewController, type: SelectionType, object: Any?, completion: ((_ item: SelectionItem?, _ cancelled: Bool) -> ())? = nil) {
		
		let item = SelectionItem()
		item.object = object
		present(parent, type: type, item: item, showsNoItemSection: false, completion: completion)
		
	}
	
}
