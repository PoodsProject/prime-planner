//
//  ViewControllerDashboard.swift
//  Prime Planner
//
//  Created by Christian Dudukovich on 10/4/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import UIKit
import Foundation


class ViewControllerDashboard: UIViewController {
	
	
	let tableView = UITableView(frame: .zero, style: .grouped)
	let calendarContainer = UIView()
	let calendar = JCalendar(date: Date(), headerHeight: 60, isWeekly: true)
	var calendarHeightConstraint: NSLayoutConstraint!
	var tasks = [[Task]]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationController?.setNavigationBarHidden(true, animated: false)
		layoutCalendarView()
		layoutTableView()
		
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// reload the data each time the view appears
		loadData()
		tableView.reloadData()
	}
	
	
	func loadData() {
		
		// clear out the previous data
		tasks.removeAll()
		
		
		// create ranges for day and week
		let dayRange = Date().dayRange
		let weekRange = DateRange(start: Date().adding(day: 1), end: Date().adding(day: 1).endOfWeek)
		
		
		// fetch our tasks based on the created date ranges
		let todayTasks = jcore.tasks.match(range: dayRange).sort("dueDate", ascending: true).fetch()
		let weekTasks = jcore.tasks.match(range: weekRange).sort("dueDate", ascending: true).fetch()
		let noDueDateTasks = jcore.tasks.filter("dueDate == nil").fetch()
		let upcomingTasks = jcore.tasks.fetch().filter({ !todayTasks.contains($0) && !weekTasks.contains($0) && !noDueDateTasks.contains($0) })
		
		
		// add the fetched tasks into the array
		tasks.append(noDueDateTasks)
		tasks.append(todayTasks)
		tasks.append(weekTasks)
		tasks.append(upcomingTasks)
		
	}
	
	
	func layoutTableView() {
		
		// set tableview delegates & row height
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 70
		
		
		// we are manually setting constraints so we turn autoconstraints off
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		
		// register this tableview with the task cell class
		tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
		
		
		// add the tableview to the main view of this view controller (self)
		view.addSubview(tableView)
		
		
		// constraint dimensions to match the view (fills the entire view)
		NSLayoutConstraint.activate([
			
			tableView.topAnchor.constraint(equalTo: calendarContainer.bottomAnchor),
			tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tableView.widthAnchor.constraint(equalTo: view.widthAnchor)
			
			])
		
		
		// create a separator
		let sep = UIView()
		sep.translatesAutoresizingMaskIntoConstraints = false
		sep.backgroundColor = UIColor(white: 0.95, alpha: 1)
		view.addSubview(sep)
		
		NSLayoutConstraint.activate([
			
			sep.heightAnchor.constraint(equalToConstant: 2),
			sep.widthAnchor.constraint(equalTo: view.widthAnchor),
			sep.topAnchor.constraint(equalTo: tableView.topAnchor),
			sep.centerXAnchor.constraint(equalTo: view.centerXAnchor)
			
			])
		
	}
	
	
	func layoutCalendarView() {
		
		
		// setup the calendar container
		calendarContainer.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(calendarContainer)
		
		
		// add container constraints
		calendarHeightConstraint = calendarContainer.heightAnchor.constraint(equalToConstant: 150)
		NSLayoutConstraint.activate([
			
			calendarContainer.widthAnchor.constraint(equalTo: view.widthAnchor),
			calendarContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height + 10),
			calendarHeightConstraint,
			calendarContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor)
			
			])
		
		
		// setup calendar
		calendar.delegate = self
		calendar.dataSource = self
		calendar.translatesAutoresizingMaskIntoConstraints = false
		calendarContainer.addSubview(calendar)
		
		
		// add calendar constraints
		NSLayoutConstraint.activate([
			
			calendar.widthAnchor.constraint(equalTo: calendarContainer.widthAnchor),
			calendar.heightAnchor.constraint(equalTo: calendarContainer.heightAnchor),
			calendar.centerXAnchor.constraint(equalTo: calendarContainer.centerXAnchor),
			calendar.centerYAnchor.constraint(equalTo: calendarContainer.centerYAnchor)
			
			])
		
	}
	
	
}


extension ViewControllerDashboard: UITableViewDelegate, UITableViewDataSource {
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return tasks.count
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks[section].count
	}
	
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
		cell.setTask(task: tasks[indexPath.section][indexPath.row])
		return cell
		
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		guard tasks[section].count != 0 else { return nil }
		
		switch section {
		case 1: return "Today"
		case 2: return "This Week"
		case 3: return "Upcoming"
		default: return "No Due Date"
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// let's deselect this row, so that it doesn't stay selected when we come back
		tableView.deselectRow(at: indexPath, animated: true)
		
		
		// guard function against empty data
		guard tasks[indexPath.section].count != 0 else { return }
		
		
		// get the task from the data array, using the row that was tapped
		let task = tasks[indexPath.section][indexPath.row]
		
		
		// create our detail controller
		let taskDetailViewController = TaskEditViewController()
		taskDetailViewController.task = task
		
		
		// push vc onto the nav stack
		navigationController?.pushViewController(taskDetailViewController, animated: true)
		
	}
	
	
}


extension ViewControllerDashboard: JCalendarDelegate, JCalendarDataSource {
	
	
	func calendar(_ calendar: JCalendar, didSelectDate date: Date, selectedAutomatically: Bool, isReselecting: Bool) {
		guard !isReselecting else { return }
		// scroll to row
	}
	
	func calendar(_ calendar: JCalendar, markerColorForDate date: Date) -> UIColor? {
		var color: UIColor?
		
		// if a task exists in this date, mark the cell
		if jcore.tasks.match(range: date.dayRange).fetchOrNil() != nil {
			color =  AppTheme.color()
		}
		
		return color
	}
	
	func calendar(_ calendar: JCalendar, willUpdateHeight height: CGFloat) {
		
		let constant = calendar.headerHeight + height
		guard calendarHeightConstraint.constant != constant else { return }
		
		let animate = calendarHeightConstraint.constant != 150
		
		view.layoutIfNeeded()
		calendarHeightConstraint.constant = constant
		
		if animate {
			let anim = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {
				self.view.layoutIfNeeded()
			}
			anim.startAnimation()
		} else {
			view.layoutIfNeeded()
		}
		
	}
	
	
	
	
}
