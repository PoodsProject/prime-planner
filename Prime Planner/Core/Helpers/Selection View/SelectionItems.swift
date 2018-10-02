//
//  SelectionItems.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation

enum SelectionType {
	case note, calendar, priority
}

class SelectionItem {
	
	// gets the object-related title
	var title: String? {
		
		if let priority = object as? TaskPriority {
			return priority.string
		}
		
		return nil
		
	}
	
	
	// object that is 'selected'
	var object: Any?
	
	
	// init with a selected object
	init(object: Any?) {
		self.object = object
	}
	
	
	// default init
	init() { }
	
}

class SelectionItems {
	var type: SelectionType
	var priorityTypes: [TaskPriority] = [.none, .low, .medium, .high]
	
	
	// init with selection type (note, calendar, priority)
	init(type: SelectionType) {
		self.type = type
	}
	
	
	// returns the number of items represented in this selection
	// or returns 0 if the selection doesn't represent an array of items
	var count: Int {
		return type == .priority ? priorityTypes.count : 0
	}
	
	
	// returns the selection item at the given index
	subscript(index: Int) -> SelectionItem {
		
		let item = SelectionItem()
		
		if type == .priority {
			item.object = priorityTypes[index]
		}
		
		return item
		
	}
	
}
