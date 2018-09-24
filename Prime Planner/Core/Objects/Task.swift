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
}


// we are going to manually manage the Task object, thus requiring it to be manually created
class Task: NSManagedObject {
	
	// @NSManaged means this Task object is managed by the core database
	@NSManaged var name: String
	@NSManaged var creationDate: Date
	@NSManaged var dueDate: Date?
	@NSManaged var note: String
	
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
		self.name = name
		self.creationDate = Date()
		self.priority = .none
		self.note = ""
	}
	
	
}
