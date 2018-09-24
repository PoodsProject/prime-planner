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
		
		// create a test task
		let task = Task(name: "Hello, World!")
		task.creationDate = Date()
		task.note = "This is a note."
		task.priority = 2
		
		
		// check if the task exists with the specified name
		XCTAssert(jcore.tasks.fetchFirst()?.name == "Hello, World!")
		
		
		// remove the task from the database
		jcore.remove(task)
		
		
		// check if the task is nil (was removed properly)
		XCTAssert(jcore.tasks.fetchOrNil() == nil)
		
	}
	
	func testPerformanceInsertionRemoval() {
		
		measure {
			self.testInsertionRemoval()
		}
		
	}
	
	
}
