//
//  CalendarDataTests.swift
//  Prime PlannerTests
//
//  Created by Jacob Caraballo on 10/26/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import XCTest
@testable import Prime_Planner


class CalendarDataTests: XCTestCase {
	
	
	func testTaskInDateRangeRetrieval() {
		
		// create our date
		let date = Date(year: 2018, month: 12, day: 25)
		
		
		// create the task given the due date
		let task = insertTask(dueDate: date)
		
		
		// get the day range (beginning of day to end of day)
		let dateRange = date.dayRange
		
		
		// test if database returns the inserted task at the given range
		XCTAssertNotNil(jcore.tasks.match(range: dateRange).fetchOrNil())
		
		
		// remove the task
		removeTask(task)
		
	}
	
	
	func insertTask(dueDate: Date) -> Task {
		
		// create a test task
		let task = Task(name: "Hello, World!")
		task.creationDate = Date()
		task.dueDate = dueDate
		task.note = "This is a note."
		task.priority = .low
		
		
		// insert the task into the database
		jcore.save()
		
		
		// save the id
		let id = task.id
		
		
		// get task from database
		let getTask = jcore.tasks.match(id: id).fetchFirst()
		
		
		// check if the task exists with the specified name
		XCTAssertNotNil(getTask)
		
		return getTask!
		
	}
	
	
	func removeTask(_ task: Task) {
		
		// get task id
		let id = task.id
		
		
		// get task from database
		let task = jcore.tasks.match(id: id).fetchFirst()
		
		
		// check if the task exists with the specified name
		XCTAssertNotNil(task)
		
		
		// remove the task from the database
		jcore.remove(task)
		
		
		// check if the task is nil (was removed properly)
		XCTAssertNil(jcore.tasks.match(id: id).fetchFirst())
		
	}
	
}
