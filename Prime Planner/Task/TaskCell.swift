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
	
	
	// this is a block handler that we will use for the checkbox button action
	// the first pair of parenthesis hold the parameters from the call being passed to the block.
	// the second pair of parenthesis is the return from the block being passed back to the call.
	// Both are empty because we are not passing / returning anything as of yet.
	var checkboxAction: (() -> ())?
	
	
	required init?(coder aDecoder: NSCoder) { fatalError() }
	
	// layout the checkbox when the cell is initialized
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		// set an indentation, just to move over all the default content of the cell to fit our checkbox
		indentationLevel = 5
		
		
		layoutCheckbox()
		
	}
	
	
	// layout and set proper constraints for the checkbox
	private func layoutCheckbox() {
		
		let checkboxSize: CGFloat = 35
		
		checkbox.translatesAutoresizingMaskIntoConstraints = false
		checkbox.addTarget(checkbox, action: #selector(Checkbox.checkBoxTapped), for: .touchUpInside)
		contentView.addSubview(checkbox)
		
		NSLayoutConstraint.activate([
			
			checkbox.widthAnchor.constraint(equalToConstant: checkboxSize),
			checkbox.heightAnchor.constraint(equalToConstant: checkboxSize),
			checkbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: separatorInset.left),
			checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
			
			])
		
		
	}
	
	
	// For now task is a String. This will change to take in a Task object
    func setTask(task: Task){
        textLabel?.text = task.name
    }
	
    
}
