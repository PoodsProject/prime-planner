//
//  ButtonView.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

class ButtonViewButton {
	var title: String?
	var image: String?
	var width: CGFloat?
	var button: UIButton?
	var textColor: UIColor = .black {
		didSet {
			button?.setTitleColor(textColor, for: .normal)
			
			if let button = button, let image = button.currentImage {
				button.setImage(image.image(withColor: textColor), for: .normal)
			}
		}
	}
	
	init(title: String, width: CGFloat? = nil) {
		self.title = title
		self.width = width
	}
	
	init(image: String, width: CGFloat? = nil) {
		self.image = image
		self.width = width
	}
	
	
	
	init() {}
}

class ButtonView: UIView {
	enum ButtonTitleType {
		case `default`, image, button
	}
	fileprivate var heightConstraint: NSLayoutConstraint!
	var height: CGFloat = 50 {
		didSet {
			
			if height != oldValue {
				layoutIfNeeded()
				heightConstraint?.constant = height + bottomPadding
				layoutIfNeeded()
				for button in buttons {
					if let button = button.button {
						var fontSize = height * (2/5)
						if fontSize < 20 {
							fontSize = 20
						}
						button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
					}
				}
			}
			
		}
	}
	var bottomPadding: CGFloat = 0
	var action: ((_ button: UIButton) -> ())?
	var buttons: [ButtonViewButton]!
	var autoFixesToView = true
	var buttonView = UIView()
	var buttonColor = UIColor(white: 0.96, alpha: 1) {
		didSet {
			backgroundColor = buttonColor
			for button in buttons {
				button.button?.backgroundColor = buttonColor
			}
		}
	}
	var textColor = UIColor.black {
		didSet {
			for button in buttons {
				button.textColor = textColor
			}
		}
	}
	
	convenience init(action: ((_ button: UIButton) -> ())? = nil) {
		self.init(image: "calc_plus", action:action)
	}
	convenience init(title: String, action: ((_ button: UIButton) -> ())? = nil) {
		self.init(titles: [title], action: action)
	}
	convenience init(image: String, action: ((_ button: UIButton) -> ())? = nil) {
		self.init(images: [image], action: action)
	}
	convenience init(button: ButtonViewButton, action: ((_ button: UIButton) -> ())? = nil) {
		self.init(buttons: [button], action: action)
	}
	convenience init(titles: [String], action: ((_ button: UIButton) -> ())? = nil) {
		self.init(titles: titles, buttons: nil, type: .default, action: action)
	}
	convenience init(images: [String], action: ((_ button: UIButton) -> ())? = nil) {
		self.init(titles: images, buttons: nil, type: .image, action: action)
	}
	convenience init(buttons: [ButtonViewButton], action: ((_ button: UIButton) -> ())? = nil) {
		self.init(titles: nil, buttons: buttons, type: .button, action: action)
	}
	
	fileprivate init(titles: [String]?, buttons: [ButtonViewButton]?, type: ButtonTitleType, action: ((_ button: UIButton) -> ())? = nil) {
		
		self.action = action
		
		if type == .button {
			self.buttons = buttons
		}
		
		super.init(frame: CGRect.zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		if let titles = titles , type != .button {
			setupButtonsForTitles(titles, titlesAreImages: type == .image)
		}
		
		setup()
	}
	override func didMoveToSuperview() {
		super.didMoveToSuperview()
		
		if let view = superview, autoFixesToView {
			heightConstraint = heightAnchor.constraint(equalToConstant: height + bottomPadding)
			NSLayoutConstraint.activate([
				centerXAnchor.constraint(equalTo: view.centerXAnchor),
				bottomAnchor.constraint(equalTo: view.bottomAnchor),
				widthAnchor.constraint(equalTo: view.widthAnchor),
				heightConstraint
				])
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupButtonsForTitles(_ titles: [String], titlesAreImages: Bool = false) {
		buttons = [ButtonViewButton]()
		for title in titles {
			let button = ButtonViewButton()
			if titlesAreImages {
				button.image = title
			} else {
				button.title = title
			}
			buttons.append(button)
		}
	}
	func setup() {
		backgroundColor = buttonColor
		
		buttonView.backgroundColor = .black
		buttonView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(buttonView)
		
		NSLayoutConstraint.activate([
			
			buttonView.heightAnchor.constraint(equalToConstant: height),
			buttonView.widthAnchor.constraint(equalTo: widthAnchor),
			buttonView.topAnchor.constraint(equalTo: topAnchor),
			buttonView.centerXAnchor.constraint(equalTo: centerXAnchor)
			
			])
		
		let distance: CGFloat = buttons.count > 1 ? 2 : 0
		
		var fixedButtons = [ButtonViewButton]()
		
		var fixedButtonsWidth: CGFloat = 0
		for button in buttons! {
			if let width = button.width {
				fixedButtons.append(button)
				fixedButtonsWidth += width
			}
		}
		
		//calculate fixed buttons width
		var fixedWidth: CGFloat = 0
		if fixedButtons.count != 0 {
			fixedWidth = (fixedButtonsWidth / CGFloat(fixedButtons.count)) - (distance / CGFloat(fixedButtons.count))
		}
		
		var previousVariableButton: UIButton?
		var previousConstantButton: UIButton?
		for (i, button) in buttons.enumerated() {
			var newButtonWidth: CGFloat?
			
			if let _ = button.width { //fixed button
				newButtonWidth = fixedWidth
			}
			
			button.button = addButton(button.title ?? button.image ?? "", textColor: button.textColor, isImage: button.image != nil, previousVariableButton: previousVariableButton, previousConstantButton: previousConstantButton, constantWidth: newButtonWidth, isLast: i == buttons.count - 1)
			if newButtonWidth == nil {
				previousConstantButton = nil
				previousVariableButton = button.button
			} else {
				previousConstantButton = button.button
			}
		}
	}
	
	fileprivate func addButton(
		_ name: String,
		textColor: UIColor,
		isImage: Bool,
		previousVariableButton: UIButton?,
		previousConstantButton: UIButton?,
		constantWidth: CGFloat?,
		isLast: Bool
		) -> UIButton	{
		
		let distance: CGFloat = buttons.count > 1 ? 2 : 0
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.backgroundColor = buttonColor
		button.setTitleColor(textColor, for: .normal)
		button.addTarget(self, action: #selector(ButtonView.down(_:)), for: [.touchDown, .touchDragEnter])
		button.addTarget(self, action: #selector(ButtonView.exit(_:)), for: [.touchDragExit, .touchCancel])
		button.addTarget(self, action: #selector(ButtonView.up(_:)), for: [.touchUpInside])
		button.adjustsImageWhenHighlighted = false
		
		if isImage {
			button.setImage(UIImage(named: name)?.image(withColor: textColor), for: .normal)
		} else {
			button.setTitle(name, for: UIControlState())
			var fontSize = height * (2/5)
			if fontSize < 20 {
				fontSize = 20
			}
			button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
		}
		buttonView.addSubview(button)
		
		var constraints = [NSLayoutConstraint]()
		if let previousVariableButton = previousVariableButton {
			if let previousConstantButton = previousConstantButton {
				constraints.append(contentsOf: [
					button.leadingAnchor.constraint(equalTo: previousConstantButton.trailingAnchor, constant: distance / 2),
					])
				if isLast && constantWidth != nil {
					constraints.append(contentsOf: [
						button.trailingAnchor.constraint(equalTo: trailingAnchor)
						])
				}
			} else {
				if isLast && constantWidth != nil {
					constraints.append(contentsOf: [
						button.trailingAnchor.constraint(equalTo: trailingAnchor),
						previousVariableButton.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -(distance / 2))
						])
				} else {
					constraints.append(contentsOf: [
						button.leadingAnchor.constraint(equalTo: previousVariableButton.trailingAnchor, constant: distance / 2),
						])
				}
			}
			if constantWidth == nil {
				constraints.append(contentsOf: [
					button.widthAnchor.constraint(equalTo: previousVariableButton.widthAnchor),
					previousVariableButton.widthAnchor.constraint(equalTo: button.widthAnchor)
					])
			}
		} else if let previousConstantButton = previousConstantButton {
			constraints.append(contentsOf: [
				button.leadingAnchor.constraint(equalTo: previousConstantButton.trailingAnchor, constant: distance / 2),
				])
		} else {
			constraints.append(
				button.leadingAnchor.constraint(equalTo: leadingAnchor)
			)
		}
		
		if let constantWidth = constantWidth {
			constraints.append(contentsOf: [
				button.widthAnchor.constraint(equalToConstant: constantWidth)
				])
		} else if isLast {
			constraints.append(
				button.trailingAnchor.constraint(equalTo: trailingAnchor)
			)
		}
		
		constraints.append(contentsOf: [
			button.heightAnchor.constraint(equalToConstant: height),
			button.topAnchor.constraint(equalTo: topAnchor)
		])
		
		NSLayoutConstraint.activate(constraints)
		
		return button
	}
	@objc func down(_ sender: UIButton) {
		sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(0.8)
	}
	@objc func exit(_ sender: UIButton) {
		sender.backgroundColor = sender.backgroundColor?.withAlphaComponent(1.0)
	}
	@objc func up(_ sender: UIButton) {
		self.exit(sender)
		action?(sender)
	}
	
}
