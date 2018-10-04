//
//  CoreDataTests.swift
//  Prime PlannerTests
//
//  Created by Jacob Caraballo on 9/19/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import XCTest
@testable import Prime_Planner

class CoreDataTests: XCTestCase {
	
	
	func testInsertionRemoval() {
		
		let task = testInsertTask()
		testRemoveTask(task)
		
	}
	
	
	func testInsertTask() -> Task {
		
		// create a test task
		let task = Task(name: "Hello, World!")
		task.creationDate = Date()
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
	
	
	func testRemoveTask(_ task: Task) {
		
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
	
	
	func testPerformanceInsertionRemoval() {
		
		measure {
			self.testInsertionRemoval()
		}
		
	}
	
	
}
