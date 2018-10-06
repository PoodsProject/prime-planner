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
	
	
	required init?(coder aDecoder: NSCoder) { fatalError() }
	
	// layout the checkbox when the cell is initialized
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .value1, reuseIdentifier: reuseIdentifier)
		
		// set an indentation, just to move over all the default content of the cell to fit our checkbox
		indentationLevel = 5
		
		
		layoutCheckbox()
		
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
		textLabel?.text = task.name
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
