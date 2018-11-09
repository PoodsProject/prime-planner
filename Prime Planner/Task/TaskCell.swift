//
//  TaskCell.swift
//  Prime Planner
//
//  Created by Mac User on 9/12/18.
//  Copyright © 2018 Mac User. All rights reserved.
//

import UIKit
import Foundation

class TaskCell: UITableViewCell {
	
	
	// declare our checkbox class
	let checkbox = Checkbox()
	
	
	// keep track of the task connected to this cell
	var task: Task!
	
	
	// this is a block handler that we will use for the checkbox button action
	// the first pair of parenthesis hold the parameters from the call being passed to the block.
	// the second pair of parenthesis is the return from the block being passed back to the call.
	// Both are empty because we are not passing / returning anything as of yet.
	var checkboxAction: ((Task, Bool) -> ())?
	
	
	// attribute labels
	var leftView = UIView()
	var nameLabel = UILabel()
	var dueDateLabel = UILabel()
	
	
	required init?(coder aDecoder: NSCoder) { fatalError() }
	
	// layout the checkbox when the cell is initialized
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)
		
		// set an indentation, just to move over all the default content of the cell to fit our checkbox
		indentationLevel = 5
		
		
		layoutCheckbox()
		layoutNameLabel()
		layoutDueDateLabel()
		layoutLeftView()
		
	}
	
	private func layoutLeftView() {
		
		leftView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(leftView)
		
		NSLayoutConstraint.activate([
			
			leftView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
			leftView.heightAnchor.constraint(equalToConstant: nameLabel.frame.size.height + dueDateLabel.frame.size.height),
			leftView.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: separatorInset.left),
			leftView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
			
			])
		
	}
	
	private func layoutNameLabel() {
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.text = "Sizing Height Text"
		nameLabel.sizeToFit()
		nameLabel.text = nil
		leftView.addSubview(nameLabel)
		
		NSLayoutConstraint.activate([
			
			nameLabel.widthAnchor.constraint(equalTo: leftView.widthAnchor),
			nameLabel.leadingAnchor.constraint(equalTo: leftView.leadingAnchor),
			nameLabel.topAnchor.constraint(equalTo: leftView.topAnchor)
			
			])
	}
	
	private func layoutDueDateLabel() {
		
		dueDateLabel.translatesAutoresizingMaskIntoConstraints = false
		dueDateLabel.textColor = UIColor(white: 0.4, alpha: 1.0)
		dueDateLabel.font = UIFont.systemFont(ofSize: 15)
		dueDateLabel.text = "Sizing Height Text"
		dueDateLabel.sizeToFit()
		dueDateLabel.text = nil
		leftView.addSubview(dueDateLabel)
		
		NSLayoutConstraint.activate([
			
			dueDateLabel.widthAnchor.constraint(equalTo: leftView.widthAnchor),
			dueDateLabel.leadingAnchor.constraint(equalTo: leftView.leadingAnchor),
			dueDateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor)
			
			])
		
	}
	
	
	// layout and set proper constraints for the checkbox
	private func layoutCheckbox() {
		
		let checkboxSize: CGFloat = 35
		
		checkbox.translatesAutoresizingMaskIntoConstraints = false
		checkbox.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
		contentView.addSubview(checkbox)
		
		NSLayoutConstraint.activate([
			
			checkbox.widthAnchor.constraint(equalToConstant: checkboxSize),
			checkbox.heightAnchor.constraint(equalToConstant: checkboxSize),
			checkbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: separatorInset.left),
			checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
			
			])
		
		
	}
	
	
	// toggles the check image and calls the action
	@objc func checkBoxTapped() {
		checkbox.checkBoxTapped()
		checkboxAction?(task, checkbox.isChecked)
	}
	
	
	// sets the task property of this cell as well as the name
	func setTask(task: Task){
		
		// set the task for this cell
		self.task = task
		
		
		// set task name and priority
		if let date = task.dueDate {
			textLabel?.text = nil
			nameLabel.text = task.name
			dueDateLabel.text = date.string
		} else {
			textLabel?.text = task.name
			nameLabel.text = nil
			dueDateLabel.text = nil
		}
		
		detailTextLabel?.text = task.priority.symbol
		detailTextLabel?.textColor = task.priority.color
		
		
		// set checkbox options
		checkbox.isChecked = task.isChecked
		checkboxAction = { task, isChecked in
			task.isChecked = isChecked
			jcore.save()
		}
    }
	
    
}
