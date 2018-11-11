//
//  CalendarTaskListView.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 10/25/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import UIKit


class CalendarTaskListView: UIView, UITableViewDelegate, UITableViewDataSource {
	
	private let rowHeight: CGFloat = 60
	
	var date = Date()
	
	let tableView = UITableView(frame: .zero, style: .plain)
	var parent: ViewControllerCalender!
	var range: (start: Date, end: Date)?
	var tasks = [Task]()
	
	
	init() {
		super.init(frame: .zero)
		backgroundColor = UIColor.clear
		
		layoutTableView()
		filterTasksInDateRange(Date().beginningOfDay.dayRange)
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func layoutTableView() {
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.backgroundColor = .white
		tableView.showsVerticalScrollIndicator = false
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = rowHeight
		tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
		addSubview(tableView)
		
		
		NSLayoutConstraint.activate([
			
			tableView.widthAnchor.constraint(equalTo: widthAnchor),
			tableView.heightAnchor.constraint(equalTo: heightAnchor),
			tableView.centerXAnchor.constraint(equalTo: centerXAnchor),
			tableView.centerYAnchor.constraint(equalTo: centerYAnchor)
			
			])
		
	}
	
	func deleteTaskAtIndexPath(_ indexPath: IndexPath) {

		// get and remove task
		let task = tasks[indexPath.row]
		jcore.remove(task)
		
		// delete the rows from the table
		finishFilterTaskOperation(false)
		tableView.deleteRows(at: [indexPath], with: .fade)
	}
	
	//MARK: actions
	var filterRange: DateRange?
	func filterTasksInDateRange(_ range: DateRange? = nil) {
		filterRange = range
		
		if tableView.contentOffset != .zero {
			self.tableView.setContentOffset(.zero, animated: true)
		} else {
			finishFilterTaskOperation()
		}
		
	}
	func finishFilterTaskOperation(_ reload: Bool = true) {
		
		if let range = filterRange {
			tasks = jcore.tasks.match(range: range).fetch()
			if reload {
				tableView.reloadData()
			}
		}
		
	}
	
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		
		DispatchQueue.main.asyncAfter(deadline: .now()) {
			self.finishFilterTaskOperation()
		}
		
	}
	
	//MARK: tableview delegate
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
		
		cell.setTask(task: tasks[indexPath.row])
		
		return cell;
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		
		// deselect our cell
		tableView.deselectRow(at: indexPath, animated: true)
		
		
		// create our detail controller
		let taskDetailViewController = TaskEditViewController()
		taskDetailViewController.task =  tasks[indexPath.row]
		
		
		// push vc onto the nav stack
		parent.navigationController?.pushViewController(taskDetailViewController, animated: true)
		
	}
	
}
