//
//  JCalendarView.swift
//  JCalendarView
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

protocol JCalendarPageDelegate {
	func calendarPage(_ page: JCalendarPage, didSelectDate date: Date, selectedAutomatically: Bool, isReselecting: Bool)
	func calendarPage(_ page: JCalendarPage, willUpdateHeight height: CGFloat)
}

protocol JCalendarPageDataSource {
	func calendarPage(_ calendarPage: JCalendarPage, markerColorForDate date: Date) -> UIColor?
}

class JCalendarPage: UIView {
	
	
	var date: Date
	var colorScheme = JCalendarColorScheme()
	var delegate: JCalendarPageDelegate?
	var dataSource: JCalendarPageDataSource?
	let collectionView: UICollectionView
	
	private let numColumns = 7
	private var days = [Int]()
	private var numberOfDays: (prepend: Int, add: Int, append: Int) = (0, 0, 0)
	private var horizontalGridLines = [UIView]()
	private var heightConstraint: NSLayoutConstraint!
	private var numberOfWeeks: Int {
		return isWeekly ? 1 : date.numberOfWeeksInMonth
	}
	private var selectedCell: JCalendarViewCell?
	private var isWeekly: Bool
	
	var pageHeight: CGFloat {
		return (collectionView.bounds.size.width / CGFloat(numColumns)).rounded(.down) * CGFloat(numberOfWeeks)
	}
	
	
	func setDate(_ date: Date, forceUpdateLayout: Bool = false) {
		let oldValue = self.date
		self.date = date
		if forceUpdateLayout || (!isWeekly && !date.hasSameMonth(asDate: oldValue) || (isWeekly && !date.contained(in: oldValue.weekRange))) {
			updateLayout()
		}
	}
	
	init(date: Date, isWeekly: Bool) {
		self.isWeekly = isWeekly
		self.date = date
		
		let flow = UICollectionViewFlowLayout()
		flow.scrollDirection = .vertical
		flow.minimumLineSpacing = 0
		flow.minimumInteritemSpacing = 0
		
		collectionView = UICollectionView(frame: .zero, collectionViewLayout: flow)
		
		super.init(frame: .zero)
		
		loadData()
		layoutCollectionView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func layoutCollectionView() {
		
		collectionView.backgroundColor = UIColor.clear
		collectionView.register(JCalendarViewCell.self, forCellWithReuseIdentifier: "Cell")
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(collectionView)
		
		heightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
		
		NSLayoutConstraint.activate([
			
			collectionView.widthAnchor.constraint(equalTo: widthAnchor),
			collectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
			heightConstraint,
			collectionView.topAnchor.constraint(equalTo: topAnchor)
			
			])
		
	}
	
	private func updateLayout() {
		
		loadData()
		updateHeightConstraint()
		collectionView.reloadData()
		
	}
	
	override func willMove(toWindow newWindow: UIWindow?) {
		if let _ = newWindow {
			updateHeightConstraint()
		}
	}
	
	private func updateHeightConstraint() {
		
		let size = pageHeight
		guard heightConstraint.constant != size else { return }
		
		// activate height constraint if necessary
		heightConstraint.constant = size
		
		delegate?.calendarPage(self, willUpdateHeight: size)
		
	}
	
	private func loadData() {
		
		selectedCell = nil
		days.removeAll()
		
		if isWeekly {
			
			// add days before week if necessary
			if (!date.beginningOfWeek.contained(in: date.monthRange)) {
				let firstDayInMonth = date.beginningOfMonth
				let firstWeekdayInMonth = firstDayInMonth.weekday
				let lastMonth = date.adding(month: -1)
				let numberOfDaysLastMonth = lastMonth.numberOfDaysInMonth
				numberOfDays.prepend = firstWeekdayInMonth - Calendar.current.firstWeekday
				
				for i in 0..<numberOfDays.prepend {
					days.insert(numberOfDaysLastMonth - i, at: 0)
				}
			}
			
			
			// add days in week
			var currentDateInWeek = date.beginningOfWeek
			for _ in 0..<7 {
				guard currentDateInWeek.contained(in: date.monthRange) else {
					currentDateInWeek = currentDateInWeek.adding(day: 1)
					continue
				}
				
				numberOfDays.add += 1
				days.append(currentDateInWeek.day)
				currentDateInWeek = currentDateInWeek.adding(day: 1)
				
			}
			
			
			// add days after month if necessary
			if (!date.endOfWeek.contained(in: date.monthRange)) {
				let lastDayInMonth = date.endOfMonth
				let lastWeekdayInMonth = lastDayInMonth.weekday
				numberOfDays.append = Calendar.current.firstWeekday + Calendar.current.weekdaySymbols.count - 1 - lastWeekdayInMonth
				
				for i in 0..<numberOfDays.append {
					days.append(i + 1)
				}
			}
			
			
		} else {
			// add days of month
			numberOfDays.add = date.numberOfDaysInMonth
			for i in 1...numberOfDays.add {
				days.append(i)
			}
			
			
			// add days before month if necessary
			let firstDayInMonth = date.beginningOfMonth
			let firstWeekdayInMonth = firstDayInMonth.weekday
			let lastMonth = date.adding(month: -1)
			let numberOfDaysLastMonth = lastMonth.numberOfDaysInMonth
			numberOfDays.prepend = firstWeekdayInMonth - Calendar.current.firstWeekday
			
			for i in 0..<numberOfDays.prepend {
				days.insert(numberOfDaysLastMonth - i, at: 0)
			}
			
			
			// add days after month if necessary
			let lastDayInMonth = date.endOfMonth
			let lastWeekdayInMonth = lastDayInMonth.weekday
			numberOfDays.append = Calendar.current.firstWeekday + Calendar.current.weekdaySymbols.count - 1 - lastWeekdayInMonth
			
			for i in 0..<numberOfDays.append {
				days.append(i + 1)
			}
		}
		
		
		
		
	}
	
	func select(day: Int) {
		var date = self.date
		date.set(day: day)
		select(cell: collectionView.cellForItem(at: IndexPath(item: numberOfDays.prepend + day - 1, section: 0)) as? JCalendarViewCell, alertDelegate: false)
	}
	
	func select(date: Date) {
		select(day: date.day)
	}
	
	func setDate(toSectionAfterDate date: Date) {
		
		var dateAfter: Date
		
		if !isWeekly {
			// setup next month
			dateAfter = date.adding(month: 1)
			if dateAfter.hasSameMonth(asDate: Date()) {
				dateAfter = Date()
			} else {
				dateAfter = dateAfter.beginningOfMonth
			}
		} else {
			
			// setup next n weeks
			dateAfter = date.adding(week: 1)
			if dateAfter.weekRange.includes(date: Date()) {
				dateAfter = Date()
			} else {
				dateAfter = dateAfter.beginningOfWeek
			}
			
		}
		
		setDate(dateAfter)
		
	}
	
	func setDate(toSectionBeforeDate date: Date) {
		
		var dateBefore: Date
		
		if !isWeekly {
			
			// setup previous month
			dateBefore = date.adding(month: -1)
			if dateBefore.hasSameMonth(asDate: Date()) {
				dateBefore = Date()
			} else {
				dateBefore = dateBefore.beginningOfMonth
			}
			
		} else {
			
			
			// setup previous n weeks
			dateBefore = date.adding(week: -1)
			if dateBefore.weekRange.includes(date: Date()) {
				dateBefore = Date()
			} else {
				dateBefore = dateBefore.beginningOfWeek
			}
			
		}
		
		setDate(dateBefore)
		
	}
	
	
}



extension JCalendarPage: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return days.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! JCalendarViewCell
		let i = indexPath.item
		let day = days[i]
		
		cell.clipsToBounds = false
		cell.markerColor = .clear
		
		cell.textLabel.text = "\(day)"
		
		if i % 7 == 0 || (i + 1) % 7 == 0 {
			cell.contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
		} else {
			cell.contentView.backgroundColor = .clear
		}
		
		var monthDate = date
		if i < numberOfDays.prepend || i >= numberOfDays.prepend + numberOfDays.add {
			
			cell.enableFade()
			monthDate = date.adding(
				month: i < numberOfDays.prepend ? -1 : 1
			)
			
		} else {
			cell.disableFade()
		}
		
		monthDate.set(day: day)
		cell.date = monthDate
		cell.textLabel.textColor = cell.date.hasSameDay(asDate: Date()) ? colorScheme.today : colorScheme.text
		cell.deselect()
		
		let flatDate = cell.date.beginningOfDay
		if flatDate == date.beginningOfDay {
			select(cell: cell, alertDelegate: false)
		}

		if let color = self.dataSource?.calendarPage(self, markerColorForDate: flatDate) {
			cell.markerColor = color
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		select(cell: collectionView.cellForItem(at: indexPath) as? JCalendarViewCell, alertDelegate: true)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let itemWidth = (collectionView.bounds.size.width / CGFloat(numColumns)).rounded(.down)
		return CGSize(width: itemWidth, height: itemWidth)
	}
	
	func select(cell: JCalendarViewCell?, alertDelegate: Bool) {
		guard let cell = cell else { return }
		
		let isReselecting = selectedCell == cell
		
		if !isReselecting {
			cell.select()
			selectedCell?.deselect()
			selectedCell = cell
		}
		
		if alertDelegate {
			delegate?.calendarPage(self, didSelectDate: cell.date, selectedAutomatically: false, isReselecting: isReselecting)
		}
		
	}
	
}
