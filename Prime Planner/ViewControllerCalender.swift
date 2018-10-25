//
//  ViewControllerCalender.swift
//  Prime Planner
//
//  Created by Christian Dudukovich on 10/4/18.
//  Copyright © 2018 Poods. All rights reserved.
//
import UIKit
import Foundation

class ViewControllerCalender: UIViewController, JCalendarDelegate, JCalendarDataSource {
	
	var calendar: JCalendar!
	
	let tasksView = CalendarTaskListView()
	var taskListTopConstraint: NSLayoutConstraint!
	var date = Date()
	var shouldFocusToday = true
	
	var tasks = [Task]()
	var dates = [Date: [Date]]()
	
	var statusBarHidden = false {
		didSet {
			guard oldValue != statusBarHidden else { return }
			UIView.animate(withDuration: 0.3) {
				self.setNeedsStatusBarAppearanceUpdate()
			}
		}
	}
	override var prefersStatusBarHidden: Bool {
		return statusBarHidden
	}
	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .slide
	}
	
	func loadData() {
		dates.removeAll()
		tasks = jcore.tasks.fetch()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(true, animated: false)
		automaticallyAdjustsScrollViewInsets = false
		
		view.backgroundColor = UIColor.white
		
		
		loadData()
		layoutCalendar()
		layoutTasksView()
		
		
		
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tasksView.finishFilterTaskOperation()
	}
	
	func layoutCalendar() {
		
		calendar = JCalendar(date: Date())
		calendar.delegate = self
		calendar.dataSource = self
		calendar.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(calendar)
		
		NSLayoutConstraint.activate([
			
			calendar.widthAnchor.constraint(equalTo: view.widthAnchor),
			calendar.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height),
			calendar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			calendar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
			
			])
		
	}
	
	func layoutTasksView() {
		tasksView.translatesAutoresizingMaskIntoConstraints = false
		tasksView.parent = self
		view.addSubview(tasksView)
		
		taskListTopConstraint = tasksView.topAnchor.constraint(equalTo: view.topAnchor)
		
		NSLayoutConstraint.activate([
			
			tasksView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			taskListTopConstraint,
			tasksView.widthAnchor.constraint(equalTo: view.widthAnchor),
			tasksView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
			
			])
		
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	
	// Calendar Delegate
	func calendar(_ calendar: JCalendar, didSelectDate date: Date, selectedAutomatically: Bool, isReselecting: Bool) {
		guard !isReselecting else { return }
		tasksView.filterTasksInDateRange(
			date.dayRange
		)
	}
	
	func calendar(_ calendar: JCalendar, markerColorForDate date: Date) -> UIColor? {
		
		var color: UIColor?
		
		// if a task exists in this date, mark the cell
		if jcore.tasks.match(range: date.dayRange).fetchOrNil() != nil {
			color =  UIColor(red: 1, green: 0.643, blue: 0.004, alpha: 1)
		}
		
		return color
		
	}
	
	func calendar(_ calendar: JCalendar, willUpdateHeight height: CGFloat) {
		
		let constant = UIApplication.shared.statusBarFrame.height + calendar.headerHeight + height
		guard taskListTopConstraint.constant != constant else { return }
		
		let animate = taskListTopConstraint.constant != 0
		
		self.view.layoutIfNeeded()
		taskListTopConstraint.constant = constant
		
		if animate {
			let anim = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {
				self.view.layoutIfNeeded()
			}
			anim.startAnimation()
		} else {
			self.view.layoutIfNeeded()
		}
		
	}
	
}
