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
	
	let taskFields = [
		"Date",
		"Due",
		"Priority",
		"Note"
	]
	var task: Task?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .white
		
		layoutTextField()
		layoutTableView()
		
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	func layoutTextField() {
		
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.placeholder = "Task Name"
		nameTextField.text = task?.name
		nameTextField.textAlignment = .center
		nameTextField.font = UIFont.systemFont(ofSize: 24)
		view.addSubview(nameTextField)
		
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
		
		cell.textLabel?.text = taskFields[indexPath.row]
		
		return cell
	}
	
	// used to dismiss when presented as a modal
	@objc func dismissModal() {
		dismiss(animated: true, completion: nil)
	}
	
}
