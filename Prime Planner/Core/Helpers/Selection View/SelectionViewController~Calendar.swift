//
//  SelectionViewController~Calendar.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

extension SelectionViewController: JCalendarDelegate {
	
	func layoutCalendarView() {
		
		let calendar = JCalendar(date: selected.object as? Date ?? Date())
		calendar.dateFormat = "MMM yyyy"
		calendar.delegate = self
		calendar.translatesAutoresizingMaskIntoConstraints = false
		tableContainer.insertSubview(calendar, belowSubview: buttonView)
		
		NSLayoutConstraint.activate([
			
			calendar.widthAnchor.constraint(equalTo: tableContainer.widthAnchor),
			calendar.centerXAnchor.constraint(equalTo: tableContainer.centerXAnchor),
			calendar.topAnchor.constraint(equalTo: tableContainer.topAnchor),
			calendar.bottomAnchor.constraint(equalTo: buttonView.topAnchor)
			
			])
		
	}
	
	func calendar(_ calendar: JCalendar, didSelectDate date: Date, selectedAutomatically: Bool, isReselecting: Bool) {
		if !selectedAutomatically {
			selected.object = date
			dismiss(selected, cancelled: false)
		}
	}
	
	func calendar(_ calendar: JCalendar, willUpdateHeight height: CGFloat) {
		
		let constant = calendar.headerHeight + height + buttonView.height
		guard heightConstraint.constant != constant else { return }
		
		let animate = heightConstraint.constant != 150
		
		self.view.layoutIfNeeded()
		heightConstraint.constant = constant
		
		if animate {
			let anim = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {
				self.view.layoutIfNeeded()
			}
			anim.startAnimation()
		} else {
			self.view.layoutIfNeeded()
		}
		
	}
	
}
