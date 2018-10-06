//
//  Task.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/11/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: Int16 {
	case none, low, medium, high
	
	var string: String {
		switch self {
		case .low:		return "Low"
		case .medium:	return "Medium"
		case .high:		return "High"
		default:		return "None"
		}
	}
	
	var symbol: String {
		switch self {
		case .low:		return "!"
		case .medium:	return "!!"
		case .high:		return "!!!"
		default:		return ""
		}
	}
	
}


// we are going to manually manage the Task object, thus requiring it to be manually created
class Task: NSManagedObject {
	
	// @NSManaged means this Task object is managed by the core database
	@NSManaged var id: UUID
	@NSManaged var name: String
	@NSManaged var creationDate: Date
	@NSManaged var dueDate: Date?
	@NSManaged var note: String
	@NSManaged var isChecked: Bool
	
	
	// we disabled automatic management here, because we want
	// to manage this specific property ourselves
	var priority: TaskPriority {
		set {
			JManaged.set(newValue.rawValue, forKey: "priority", inObject: self)
		}
		get {
			let value = JManaged.get("priority", inObject: self) as! Int16
			return TaskPriority(rawValue: value)!
		}
	}
	
	// here we create an convenience initializer that will insert a new Task with the given name into the database
	convenience init(name: String) {
		self.init(context: jcore.context)
		self.id = UUID()
		self.name = name
		self.creationDate = Date()
		self.priority = .none
		self.note = ""
		self.isChecked = false
	}
	
	
}
