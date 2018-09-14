//
//  Task.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/11/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation


// because 'Task' is automagically created and declared by our data model, we can extend it as follows, adding any new functions and getters that may be needed.
extension Task {
	
	// here we create an convenience initializer that will insert a new Task with the given name into the database
	convenience init(name: String) {
		self.init(context: jcore.context)
		self.name = name
	}
	
	
}
