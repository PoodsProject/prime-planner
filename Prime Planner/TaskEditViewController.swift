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
	
	private enum TaskFieldKey: String {
		case date = "Due Date"
		case priority = "Priority"
		case note = "Note"
	}
	
	private let tableView = UITableView(frame: .zero, style: .grouped)
	private let nameTextField = UITextField()
	
	var task: Task?
	private var dueDate: Date?
	private var priority = TaskPriority.none
	private var note = ""
	
	// use a tuple of a property and value, for our taskFields
	private var taskFields = [TaskFieldKey: String]()
	private var taskFieldKeys: [TaskFieldKey] = [ .date, .priority, .note ]
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		loadData()
		loadTaskFields()
		layoutTextField()
		layoutTableView()
		layoutDismissButtons()
		
		// hide our navigation bar for this controller
		// we will use our own navigation to get back
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	func loadData() {
		
		
		// check if task exists, else return (this means we're in creation mode)
		guard let task = task else { return }
		
		
		// load our data from the task (this means we're in view / edit mode)
		nameTextField.text = task.name
		dueDate = task.dueDate
		priority = task.priority
		note = task.note
		
	}
	
	func loadTaskFields() {
		
		taskFields[.date] = dueDate?.string ?? "None"
		taskFields[.priority] = priority.string
		taskFields[.note] = note != "" ? note : "None"
		
	}
	
	func layoutTextField() {
		
		
		// setup the name text field
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.placeholder = "Task Name"
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
	
	func layoutDismissButtons() {
		
		let buttonsViewPadding: CGFloat = 15
		
		// create the button container view
		let buttonsView = UIView()
		buttonsView.translatesAutoresizingMaskIntoConstraints = false
		buttonsView.layer.cornerRadius = 10
		buttonsView.layer.masksToBounds = true
		buttonsView.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
		buttonsView.layer.borderWidth = 2
		view.addSubview(buttonsView)
		
		
		// setup the constraints for the container
		NSLayoutConstraint.activate([
			
			buttonsView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -(buttonsViewPadding * 2)),
			buttonsView.heightAnchor.constraint(equalToConstant: 50),
			buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			buttonsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -buttonsViewPadding)
			
			])
		
		
		// setup the cancel button
		let cancelButton = UIButton()
		cancelButton.translatesAutoresizingMaskIntoConstraints = false
		cancelButton.setTitle("Cancel", for: .normal)
		cancelButton.setTitleColor(.black, for: .normal)
		cancelButton.setTitleColor(UIColor(white: 0, alpha: 0.5), for: .highlighted)
		cancelButton.backgroundColor = UIColor(white: 0.93, alpha: 1)
		cancelButton.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
		buttonsView.addSubview(cancelButton)
		
		
		// setup the constraints for the cancel button
		NSLayoutConstraint.activate([
			
			cancelButton.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, multiplier: 0.5),
			cancelButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor),
			cancelButton.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor),
			cancelButton.leadingAnchor.constraint(equalTo: buttonsView.leadingAnchor)
			
			])
		
		
		// setup the done button
		let doneButton = UIButton()
		doneButton.translatesAutoresizingMaskIntoConstraints = false
		doneButton.setTitle("Done", for: .normal)
		doneButton.setTitleColor(.black, for: .normal)
		doneButton.setTitleColor(UIColor(white: 0, alpha: 0.5), for: .highlighted)
		doneButton.backgroundColor = UIColor(white: 0.88, alpha: 1)
		doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
		buttonsView.addSubview(doneButton)
		
		
		// setup the constraints for the done button
		NSLayoutConstraint.activate([
			
			doneButton.widthAnchor.constraint(equalTo: buttonsView.widthAnchor, multiplier: 0.5),
			doneButton.heightAnchor.constraint(equalTo: buttonsView.heightAnchor),
			doneButton.centerYAnchor.constraint(equalTo: buttonsView.centerYAnchor),
			doneButton.trailingAnchor.constraint(equalTo: buttonsView.trailingAnchor)
			
			])
		
		
	}
	
	func layoutTableView() {
		
		
		// setup our tableview
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.delegate = self
		tableView.dataSource = self
		tableView.rowHeight = 60
		view.addSubview(tableView)
		
		
		// anchor tableview to the bounds of the main view
		NSLayoutConstraint.activate([
			
			tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
			tableView.heightAnchor.constraint(equalTo: view.heightAnchor),
			tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor)
			
			])
		
		
		// create a seperator view that will seperate the name field and the tableview
		let sep = UIView()
		sep.translatesAutoresizingMaskIntoConstraints = false
		sep.backgroundColor = UIColor(white: 0.4, alpha: 1)
		view.addSubview(sep)
		
		NSLayoutConstraint.activate([
			
			sep.widthAnchor.constraint(equalTo: view.widthAnchor),
			sep.heightAnchor.constraint(equalToConstant: 2),
			sep.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			sep.topAnchor.constraint(equalTo: tableView.topAnchor)
			
			])
		
		
	}
	
}



// tableView delegate and datasource
extension TaskEditViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return taskFieldKeys.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "EditCell")
		
		if cell == nil {
			cell = UITableViewCell(style: .value1, reuseIdentifier: "EditCell")
		}
		
		let key = taskFieldKeys[indexPath.row]
		cell.textLabel?.text = key.rawValue
		cell.detailTextLabel?.text = taskFields[key]
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		guard let cell = tableView.cellForRow(at: indexPath) else { return }
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		let key = taskFieldKeys[indexPath.row]
		
		switch key {
		case .date:
			let date: Date
			if let detail = cell.detailTextLabel?.text {
				date = Date(string: detail)
			} else {
				date = dueDate ?? Date()
			}
			
			SelectionViewController.present(self, type: .calendar, object: date) { item, cancel in
				
				guard !cancel else { return }
				
				let date = item?.object as? Date
				self.dueDate = date
				self.taskFields[key] = date?.string ?? "None"
				self.tableView.reloadData()
				
			}
			
		case .priority:
			SelectionViewController.present(self, type: .priority, object: priority) { item, cancel in
				
				guard !cancel, let priority = item?.object as? TaskPriority else { return }
				
				self.priority = priority
				self.taskFields[key] = priority.string
				self.tableView.reloadData()
				
			}
			
		case .note:
			SelectionViewController.present(self, type: .note, object: note) { item, cancel in
				
				guard !cancel, let note = item?.object as? String else { return }
				
				self.note = note
				self.taskFields[key] = note
				self.tableView.reloadData()
				
			}
			
		}
		
		
		
	}
	
	// used to dismiss when presented as a modal
	@objc func dismissController() {
		if task == nil {
			dismiss(animated: true, completion: nil)
		} else {
			navigationController?.popViewController(animated: true)
		}
	}
	
}



// cancel, done button actions (must objc tag for button actions)
@objc extension TaskEditViewController {
	
	func cancelButtonPressed() {
		dismissController()
	}
	
	func doneButtonPressed() {
		
		// guard against empty name field
		// if field is empty, focus it and do not dismiss
		guard let name = nameTextField.text, name != "" else {
			nameTextField.becomeFirstResponder()
			return
		}
		
		
		// get the original task, if it exists
		// if not, create a new task
		let task = self.task ?? Task(name: name)
		
		
		// set all task values
		task.name = name
		task.dueDate = dueDate
		task.priority = priority
		task.note = note
		
		
		// save the database; the task will be inserted/updated automatically
		jcore.save()
		
		
		// dismiss the edit controller
		dismissController()
		
	}
	
}
