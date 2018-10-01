//
//  CategorySelectionView.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

class SelectionViewController: UIViewController, UIViewControllerTransitioningDelegate {
	
	fileprivate let animationController = SelectionAnimationController()
	
	let tableView = UITableView(frame: .zero, style: .plain)
	let noteTextView = UITextView()
	var selectionType: SelectionType
	var items: SelectionItems
	var blur = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
	var padding: CGFloat = 30
	let tableContainer = UIView()
	var buttonView: ButtonView!
	var completion: ((_ item: SelectionItem?, _ cancelled: Bool) -> ())?
	var initHandler: (() -> ())?
	var heightConstraint: NSLayoutConstraint!
	let selected: SelectionItem
	
	var showsNoItemSection: Bool = false {
		didSet {
			tableView.reloadData()
		}
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
	
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		animationController.presenting = true
		animationController.scalingView = tableContainer
		return animationController
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		animationController.presenting = false
		animationController.scalingView = tableContainer
		return animationController
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard initHandler != nil else { return }
		
		initHandler?()
		initHandler = nil
		
		if selectionType == .note {
			noteTextView.becomeFirstResponder()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if selectionType == .note {
			view.endEditing(true)
		}
		
	}
	
	func loadData() {
		var index: Int?
		
		switch selectionType {
		case .priority:
			let types = items.priorityTypes
			if let selected = selected.object as? TaskPriority, let i = types.firstIndex(of: selected) {
				index = i
			}
			
		case .note:
			noteTextView.text = selected.note
			
		case .calendar:
			break;
			
		}
		
		
		if let i = index {
			self.tableView.scrollToRow(at: IndexPath(row: i, section: self.showsNoItemSection ? 1 : 0), at: .middle, animated: false)
		}
	}
	
	init(type: SelectionType, item: SelectionItem) {
		selectionType = type
		items = SelectionItems(type: selectionType)
		selected = item
		
		super.init(nibName: nil, bundle: nil)
		layout()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func layout() {
		
		// setup blur
		blur.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(blur)
		
		NSLayoutConstraint.activate([
			
			blur.widthAnchor.constraint(equalTo: view.widthAnchor),
			blur.heightAnchor.constraint(equalTo: view.heightAnchor),
			blur.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			blur.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			
			])
		
		
		// setup container
		tableContainer.translatesAutoresizingMaskIntoConstraints = false
		tableContainer.clipsToBounds = true
		tableContainer.setRadius(20.0)
		tableContainer.setBorder(1, color: UIColor(white: 0, alpha: 0.6))
		tableContainer.setScale(0.9)
		blur.contentView.addSubview(tableContainer)
		
		let widthConstraint = tableContainer.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(padding * 2))
		let buttonHeight: CGFloat = 50
		
		let yConstraint: NSLayoutConstraint
		var heightConstant = safeInsets.top + safeInsets.bottom
		let rowHeight: CGFloat = 60
		
		switch selectionType {
		case .note:
			let pad: CGFloat = 60
			heightConstant -= safeInsets.bottom
			heightConstant += KeyboardService.height
			heightConstant += pad * 2
			yConstraint = tableContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: safeInsets.top + pad)
			heightConstraint = tableContainer.heightAnchor.constraint(equalTo: view.heightAnchor, constant: -heightConstant)
			
		case .priority:
			let height: CGFloat = rowHeight * CGFloat(items.count) + buttonHeight
			yConstraint = tableContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			heightConstraint = tableContainer.heightAnchor.constraint(equalToConstant: height)
			
		case .calendar:
			yConstraint = tableContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			heightConstraint = tableContainer.heightAnchor.constraint(equalToConstant: 150)
			
		}
		
		
		NSLayoutConstraint.activate([
			
			widthConstraint,
			heightConstraint,
			tableContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			yConstraint
			
			])
		
		
		// setup buttons
		let sep = UIView()
		sep.translatesAutoresizingMaskIntoConstraints = false
		sep.backgroundColor = UIColor(white: 0, alpha: 0.6)
		
		var buttons = [ButtonViewButton]()
		buttons.append(ButtonViewButton(title: "Cancel"))
		
		if selectionType == .note {
			buttons.append(ButtonViewButton(title: "Done"))
		} else if selectionType == .calendar {
			let button = ButtonViewButton(title: "Remove")
			button.textColor = .red
			buttons.append(button)
		}
		
		buttonView = ButtonView(buttons: buttons) { button in
			if button.currentTitle == "Cancel" {
				self.dismiss(nil, cancelled: true)
			} else if button.currentTitle == "Done" {
				self.doneButtonPressed()
			} else if button.currentTitle == "Remove" {
				self.dismiss(nil, cancelled: false)
			}
		}
		buttonView.height = buttonHeight
		buttonView.buttonColor = UIColor(white: 0.96, alpha: 1)
		tableContainer.addSubview(buttonView)
		tableContainer.addSubview(sep)
		
		NSLayoutConstraint.activate([
			
			sep.widthAnchor.constraint(equalTo: tableContainer.widthAnchor),
			sep.heightAnchor.constraint(equalToConstant: 1),
			sep.centerXAnchor.constraint(equalTo: tableContainer.centerXAnchor),
			sep.bottomAnchor.constraint(equalTo: buttonView.topAnchor)
			
			])
		
		
		// setup tableview
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.rowHeight = rowHeight
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundColor = .white
		tableView.separatorColor = UIColor(white: 0, alpha: 0.4)
		tableView.delaysContentTouches = false
		tableView.keyboardDismissMode = .onDrag
		tableView.reloadData()
		
		for view in tableView.subviews {
			if let scroll = view as? UIScrollView {
				scroll.delaysContentTouches = false
				break
			}
		}
		
		tableContainer.insertSubview(tableView, belowSubview: buttonView)
		
		NSLayoutConstraint.activate([
			
			tableView.widthAnchor.constraint(equalTo: tableContainer.widthAnchor),
			tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: buttonView.topAnchor),
			tableView.centerXAnchor.constraint(equalTo: tableContainer.centerXAnchor)
			
			])
		
		
		switch selectionType {
		
		case .note:
			layoutNoteTextView()
			
		case .priority:
			tableView.isScrollEnabled = false
			
		case .calendar:
			layoutCalendarView()
			
		}
		
	}
	
	func layoutNoteTextView() {
		
		noteTextView.translatesAutoresizingMaskIntoConstraints = false
		noteTextView.backgroundColor = .white
		noteTextView.delegate = self
		noteTextView.textColor = .black
		noteTextView.autocapitalizationType = .sentences
		noteTextView.keyboardAppearance = .dark
		noteTextView.font = UIFont.systemFont(ofSize: 22)
		noteTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
		noteTextView.tintColor = .black
		tableContainer.insertSubview(noteTextView, belowSubview: buttonView)
		
		NSLayoutConstraint.activate([
			
			noteTextView.widthAnchor.constraint(equalTo: tableContainer.widthAnchor),
			noteTextView.centerXAnchor.constraint(equalTo: tableContainer.centerXAnchor),
			noteTextView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
			noteTextView.bottomAnchor.constraint(equalTo: buttonView.topAnchor)
			
			])
		
	}
	
	func doneButtonPressed() {
		
		switch selectionType {
		
		case .note:
			var item: SelectionItem?
			
			if let note = noteTextView.text, note.replacingOccurrences(of: " ", with: "") != "" {
				item = SelectionItem(note: note)
			}
			
			dismiss(item, cancelled: false)
			
		default:
			break
			
		}
		
	}
	
}
