//
//  DashboardDataTests.swift
//  Prime PlannerTests
//
//  Created by Jacob Caraballo on 11/9/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import XCTest
@testable import Prime_Planner


class DashboardDataTests: XCTestCase {
	
	
	func testTaskSectionRetrieval() {
		
		// create dates for tasks
		let today = Date()
		let tomorrow = today.adding(day: 1)
		let nextMonth = today.adding(month: 1)
		
		
		// create the task given the due date
		let todayTask = insertTask(dueDate: today)
		let tomorrowTask = insertTask(dueDate: tomorrow)
		let nextMonthTask = insertTask(dueDate: nextMonth)
		
		
		// create ranges for day and week
		let dayRange = Date().dayRange
		let weekRange = DateRange(start: Date().adding(day: 1), end: Date().adding(day: 1).endOfWeek)
		
		
		// fetch our tasks based on the created date ranges
		let todayTasks = jcore.tasks.match(range: dayRange).sort("dueDate", ascending: true).fetch()
		let weekTasks = jcore.tasks.match(range: weekRange).sort("dueDate", ascending: true).fetch()
		let noDueDateTasks = jcore.tasks.filter("dueDate == nil").fetch()
		let upcomingTasks = jcore.tasks.fetch().filter({ !todayTasks.contains($0) && !weekTasks.contains($0) && !noDueDateTasks.contains($0) })
		
		
		// if all sectioning passes, this will remain true
		var isTasksSectioned = true
		
		
		// check each section, if any fails, 'isTasksSectioned' will return false
		for task in todayTasks {
			guard let due = task.dueDate else {
				isTasksSectioned = false
				break
			}
			
			if !due.isInToday {
				isTasksSectioned = false
				break
			}
		}
		
		for task in weekTasks {
			guard let due = task.dueDate else {
				isTasksSectioned = false
				break
			}
			
			if !due.contained(in: today.weekRange) {
				isTasksSectioned = false
				break
			}
		}
		
		for task in upcomingTasks {
			guard let due = task.dueDate else {
				isTasksSectioned = false
				break
			}
			
			if due.isInToday || due.contained(in: today.weekRange) || due < today {
				isTasksSectioned = false
				break
			}
		}
		
		for task in noDueDateTasks {
			if let _ = task.dueDate {
				isTasksSectioned = false
				break
			}
		}
		
		
		// test if database returns the sectioned data as true
		XCTAssert(isTasksSectioned)
		
		
		// remove the task
		removeTask(todayTask)
		removeTask(tomorrowTask)
		removeTask(nextMonthTask)
		
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
