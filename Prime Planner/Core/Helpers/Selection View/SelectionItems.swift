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
	var note: String?
	var title: String?
	var object: Any?
	var objects: [Any?]?
	var set: Set<AnyHashable>?
	var info: [AnyHashable: Any]?
	var titles: [String]?
	
	
	init(note: String?) {
		self.note = note
	}
	
	init(titles: [String]) {
		self.titles = titles
	}
	
	init() { }
	
	subscript(index: Int) -> String {
		return titles![index]
	}
	
	var count: Int {
		return titles?.count ?? 0
	}
	
}

class SelectionItems {
	var type: SelectionType
	var objects: [Any]?
	var priorityTypes: [TaskPriority] = [.none, .low, .medium, .high]
	
	
	init(type: SelectionType) {
		self.type = type
	}
	
	var count: Int {
		return type == .priority ? priorityTypes.count : 0
	}
	
	subscript(index: Int) -> SelectionItem {
		
		let item = SelectionItem()
		
		if type == .priority {
			item.title = priorityTypes[index].string
			item.object = priorityTypes[index]
		}
		
		return item
		
	}
	
}
