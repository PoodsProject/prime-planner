//
//  JCalendarViewCell.swift
//  JCalendarView
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

class JCalendarViewCell: UICollectionViewCell {
	
	
	var date = Date()
	var colorScheme = JCalendarColorScheme()
	let textLabel = UILabel()
	var markerColor = UIColor.clear {
		didSet {
			marker.backgroundColor = markerColor
		}
	}
	
	
	private var marker = UIView()
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		textLabel.translatesAutoresizingMaskIntoConstraints = false
		textLabel.backgroundColor = .clear
		textLabel.layer.cornerRadius = 20
		textLabel.textAlignment = .center
		textLabel.layer.cornerRadius = 15
		textLabel.layer.masksToBounds = true
		contentView.addSubview(textLabel)
		
		NSLayoutConstraint.activate([
			
			textLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
			textLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
			textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
			
			])
		
		marker.translatesAutoresizingMaskIntoConstraints = false
		marker.backgroundColor = .clear
		marker.layer.cornerRadius = 2
		marker.layer.masksToBounds = false
		contentView.addSubview(marker)
		
		NSLayoutConstraint.activate([
			
			marker.widthAnchor.constraint(equalTo: textLabel.widthAnchor, multiplier: 0.5),
			marker.heightAnchor.constraint(equalToConstant: 4),
			marker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			marker.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 1)
			
			])
		
	}
	
	func disableFade() {
		
		marker.isHidden = false
		alpha = 1
		
	}
	
	func enableFade() {
		
		marker.isHidden = true
		alpha = 0.3
		
	}
	
	func select() {
		
		guard textLabel.backgroundColor == .clear else { return }
		
		textLabel.backgroundColor = date.hasSameDay(asDate: Date()) ? colorScheme.today : colorScheme.selection
		
		textLabel.textColor = colorScheme.selectionText
		
	}
	
	func deselect() {
		
		guard textLabel.backgroundColor != .clear else { return }
		
		textLabel.backgroundColor = .clear
		textLabel.textColor = date.hasSameDay(asDate: Date()) ? colorScheme.today : colorScheme.text
		
	}
	
}
