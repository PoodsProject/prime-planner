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
	var tasks = [[Task]]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
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
		let todayTasks = jcore.tasks.match(range: dayRange).sort("dueDate", ascending: false).fetch()
		let weekTasks = jcore.tasks.match(range: weekRange).sort("dueDate", ascending: false).fetch()
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
			
			tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
			tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
			tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			
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
		switch section {
		case 1: return "Today"
		case 2: return "This Week"
		case 3: return "Upcoming"
		default: return "No Due Date"
		}
	}
	
	
}
