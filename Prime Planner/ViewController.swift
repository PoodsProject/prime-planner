//
//  ViewController.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/6/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	
	// create and declare our tableview and dateLabel objects
	private let tableView = UITableView(frame: .zero, style: .grouped)
	private let dateLabel = UILabel()
	
	
    // add UI button
	private let taskAddButton = UIButton(type: .system)
	
	
	// create our static data
	// this will change into a 'var' once we have task adding/removing set up,
	// because the data will need to change when users add/remove tasks
	private var data = jcore.tasks.fetch()
	
	
	// this function is a notification that is called when the view
	// of this controller is loaded into the controller. This function
	// is only called one time after initialization of the controller.
	override func viewDidLoad() {
		
		
		// hide our navigation bar in the home screen
		navigationController?.setNavigationBarHidden(true, animated: false)
		
		
		// because this function is an override, make sure to call
		// the super function first, to ensure that the parent does
		// what it needs to do when the view loads.
		super.viewDidLoad()
		
		
		// now that the view is loaded, lets layout our tableview
		layoutTableView()
		
		
		// layout our date view after the tableview is set up
		// because we will place the date in the header of the tableview,
		// so that it can scroll along with the table
		layoutDateLabel()
		
		
        // layout for task button
        layoutTaskAddButton()
        
		
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
		// if our navigation bar isn't hidden, hide it
		if navigationController?.isNavigationBarHidden == false {
			navigationController?.setNavigationBarHidden(true, animated: animated)
		}
		
		
		// when this view appears, check for a date change
		// if date has changed, update our date label
		if dateLabel.text != Date.todayString {
			dateLabel.text = Date.todayString
			dateLabel.sizeToFit()
		}
		
	}
	
	
	func layoutTableView() {
		
		
		// tell the tableview that we want to setup our own constraints
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		
		// set the height for each row
		tableView.rowHeight = 70
		
		
		// tableview will source its data from self (UIViewController) and notify self of any actions
		tableView.dataSource = self
		tableView.delegate = self
		
		
		// register TaskCell with the tableView
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
	
	
	func layoutDateLabel() {
		
		
		// create a container to hold our date label
		// we create it with a hard-coded frame, because it's going into
		// the header of the tableView, which should have a predefined height
		let dateContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 100))
		
		
		// setup our date label
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		dateLabel.text = Date.todayString
		dateLabel.textColor = .red
		
		// size the label view to fit the text inside
		dateLabel.sizeToFit()
		
		
		// add our date label to the container view
		dateContainerView.addSubview(dateLabel)
		
		
		// set our container view as the tableview header
		tableView.tableHeaderView = dateContainerView
		
		
		// constrain the dateLabel center (size is set above) to the container
		NSLayoutConstraint.activate([
			
			dateLabel.centerXAnchor.constraint(equalTo: dateContainerView.centerXAnchor),
			dateLabel.centerYAnchor.constraint(equalTo: dateContainerView.centerYAnchor),
			
			])
		
		
	}
    
    func layoutTaskAddButton() {
        
        // container for task button
		// when using a container that goes into the header or footer of a tableview
		// set the x and y to 0 and the width can be any number > 0, because the
		// tableview will resize it to match the width of itself.
		// the only thing we have to customize here would be the height, as
		// the tableview will not resize that for us.
        let taskButContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 100))
		
        
		// when using constraints, always remember to disable this option
		// this essential tells the program that we are going
		// to set our constraints manually
		taskAddButton.translatesAutoresizingMaskIntoConstraints = false
		
		
		// format and constraints for taskbutton
        taskAddButton.setTitle("+", for: UIControlState.normal)
        taskAddButton.titleLabel?.font = UIFont(name: "GeezaPro", size: 30)
        taskAddButton.tintColor = .black
        taskAddButton.backgroundRect(forBounds: CGRect(x: self.view.center.x, y:  self.view.center.y, width: 60, height: 50))
        taskAddButton.backgroundColor = .white
        taskAddButton.layer.cornerRadius = 4
        taskAddButton.sizeToFit()
		taskAddButton.addTarget(self, action: #selector(taskAddButtonPressed), for: .touchUpInside)
        
        taskButContainerView.addSubview(taskAddButton)
        
        tableView.tableFooterView = taskButContainerView
		
		
        // set container size to be below the container
        NSLayoutConstraint.activate([
            
            taskAddButton.centerXAnchor.constraint(equalTo: taskButContainerView.centerXAnchor),
            taskAddButton.centerYAnchor.constraint(equalTo: taskButContainerView.centerYAnchor),
            
            ])
        
        
    }
	
	@objc func taskAddButtonPressed() {
		
		
		// create our detail controller
		let taskDetailViewController = TaskEditViewController()
		
		
		// add a done button for navigating back
		// we target the taskDetailViewController itself, because that's
		// where the action 'dismissModal' resides
		taskDetailViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .done,
			target: taskDetailViewController,
			action: #selector(TaskEditViewController.dismissModal)
		)
		
		
		// create new nav controller for a modal presentation
		let navigation = UINavigationController(rootViewController: taskDetailViewController)

		
		// push vc onto the nav stack
		present(navigation, animated: true, completion: nil)
		
		
	}
	
	
}



// this extends the ViewController to implement the UITableViewDelegate/DataSource
// this extension is not necessary and can be implemented above, straight into the controller,
// but this promotes better code readability and organization
extension ViewController: UITableViewDelegate, UITableViewDataSource {
	
	
	// datasource function that tells the tableview how many rows to display
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		// we pass the number of objects in our data array,
		// since we need one row per data object
		return data.count != 0 ? data.count : 1
		
	}
	
	
	// datasource function that tells the tableview which cell to display for the current row
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		
		// we dequeue a cell view from the tableview
		// tableviews reuse cells, to increase performance,
		// especially for large numbers of rows
		let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
		
		
		// set the cell's task to the data object from the
		// data array at the specified index. indexPath.row returns the
		// current tableview row in which this cell will reside
		if data.count != 0 {
			cell.setTask(task: data[indexPath.row])
		} else {
			cell.textLabel?.text = "Create a New Task"
		}
		
		
		
		// return our cell to the tableview datasource
		return cell
		
		
	}
	
	
	// delegate function that is called when a user taps on a cell
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		guard data.count != 0 else { return }
		
		// let's deselect this row, so that it doesn't stay selected when we come back
		tableView.deselectRow(at: indexPath, animated: true)
		
		
		// get the task from the data array, using the row that was tapped
		let task = data[indexPath.row]
		
		
		// create our detail controller and pass the task string into its detail text variable
		let taskDetailViewController = TaskDetailViewController()
		taskDetailViewController.detailTextPassedFromPreviousController = task.name
		
		
		// push our detail controller onto the navigation stack
		// navigationController has a '?' after it, just to follow
		// the protocol that there is a possibility for a navcontroller
		// to be nil (not exist), although we do know that it does exist
		navigationController?.pushViewController(taskDetailViewController, animated: true)
		
	}
	
	
}

