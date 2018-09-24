//
//  TaskEditViewController.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/19/18.
//  Copyright © 2018 Poods. All rights reserved.
//

/*

create name field
add date calendar: for creation and due

*/

import Foundation
import UIKit

class TaskEditViewController: UIViewController {
	
	let tableView = UITableView(frame: .zero, style: .grouped)
	let nameTextField = UITextField()
	
	var task: Task?
	var name = ""
	var creationDate = Date()
	var dueDate: Date?
	var priority = TaskPriority.none
	var note = ""
	
	// use a tuple of a property and value, for our taskFields
	var taskFields = [(property: String, value: String)]()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		loadData()
		loadTaskFields()
		layoutTextField()
		layoutTableView()
		
		// hide our navigation bar for this controller
		// we will use our own navigation to get back
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// when this view controller is dismissing
		// show the navigation bar again
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	func loadData() {
		
		
		// check if task exists, else return (this means we're in creation mode)
		guard let task = task else { return }
		
		
		// load our data from the task (this means we're in view / edit mode)
		name = task.name
		creationDate = task.creationDate
		dueDate = task.dueDate
		priority = task.priority
		note = task.note
		
	}
	
	func loadTaskFields() {
		
		taskFields.append(("Date", creationDate.string))
		taskFields.append(("Due", dueDate?.string ?? "None"))
		taskFields.append(("Priority", priority.string))
		taskFields.append(("Note", note != "" ? note : "None"))
		
	}
	
	func layoutTextField() {
		
		
		// setup the name text field
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.placeholder = "Task Name"
		nameTextField.text = name
		nameTextField.textAlignment = .center
		nameTextField.font = UIFont.systemFont(ofSize: 24)
		view.addSubview(nameTextField)
		
		
		// setup nameTF constraints (constrained to the top of the view)
		NSLayoutConstraint.activate([
			
			nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor),
			nameTextField.heightAnchor.constraint(equalToConstant: 80),
			nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			nameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height)
			
			])
		
	}
	
	func layoutTableView() {
		
		
		// setup our tableview
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 50
		view.addSubview(tableView)
		
		
		// anchor tableview to the bounds of the main view
		NSLayoutConstraint.activate([
			
			tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
			tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
			tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor)
			
			])
		
		
	}
	
}



extension TaskEditViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return taskFields.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "EditCell")
		
		if cell == nil {
			cell = UITableViewCell(style: .value1, reuseIdentifier: "EditCell")
		}
		
		cell.textLabel?.text = taskFields[indexPath.row].property
		cell.detailTextLabel?.text = taskFields[indexPath.row].value
		
		return cell
	}
	
	// used to dismiss when presented as a modal
	@objc func dismissModal() {
		dismiss(animated: true, completion: nil)
	}
	
}
