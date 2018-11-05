//
//  JCalendarPageViewController.swift
//  JCalendarView
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

struct JCalendarColorScheme {
	var text: UIColor = .black
	var today: UIColor = .red
	var selection: UIColor = .black
	var selectionText: UIColor = .white
	
	init() { }
}

enum JDirection {
	case none, backwards, forwards
}

protocol JCalendarDelegate {
	func calendar(_ calendar: JCalendar, didSelectDate date: Date, selectedAutomatically: Bool, isReselecting: Bool)
	func calendar(_ calendar: JCalendar, willUpdateHeight height: CGFloat)
}

protocol JCalendarDataSource {
	func calendar(_ calendar: JCalendar, markerColorForDate date: Date) -> UIColor?
}

class JCalendar: UIView {
	
	var delegate: JCalendarDelegate?
	var dataSource: JCalendarDataSource?
	var collectionView: UICollectionView {
		return page2.collectionView
	}
	var dateFormat = "MMMM yyyy" {
		didSet {
			setDateViewLabelDate(date)
		}
	}
	
	private var date: Date {
		didSet {
			guard date != oldValue else { return }
			resetPageDates()
		}
	}
	
	
	private let colorScheme = JCalendarColorScheme()
	private let scrollView = UIScrollView()
	private let weekView = UIView()
	private let dateView = UIView()
	private let dateViewLabel = UILabel()
	private let todayButton = UIButton()
	private var selectingDate: Date?
	private var targetPage: Int?
	private var heightPrepared = false
	private var selectedPageAutomatically = true
	
	private let page1: JCalendarPage
	private let page2: JCalendarPage
	private let page3: JCalendarPage
	
	var headerHeight: CGFloat
	var isWeekly: Bool
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	init(date: Date = Date(), headerHeight: CGFloat = 88, isWeekly: Bool = false) {
		
		self.date = date
		self.headerHeight = headerHeight
		self.isWeekly = isWeekly
		
		var dateBefore: Date
		var dateAfter: Date
		
		if !isWeekly {
			// setup next month
			dateAfter = date.adding(month: 1)
			if dateAfter.hasSameMonth(asDate: Date()) {
				dateAfter = Date()
			} else {
				dateAfter = dateAfter.beginningOfMonth
			}
			
			
			// setup previous month
			dateBefore = date.adding(month: -1)
			if dateBefore.hasSameMonth(asDate: Date()) {
				dateBefore = Date()
			} else {
				dateBefore = dateBefore.beginningOfMonth
			}
		} else {
			
			// setup next n weeks
			dateAfter = date.adding(week: 1)
			if dateAfter.weekRange.includes(date: Date()) {
				dateAfter = Date()
			} else {
				dateAfter = dateAfter.beginningOfWeek
			}
			
			
			// setup previous n weeks
			dateBefore = date.adding(week: -1)
			if dateBefore.weekRange.includes(date: Date()) {
				dateBefore = Date()
			} else {
				dateBefore = dateBefore.beginningOfWeek
			}
			
		}
		
		
		
		// create pages
		page1 = JCalendarPage(date: dateBefore, isWeekly: isWeekly)
		page2 = JCalendarPage(date: date, isWeekly: isWeekly)
		page3 = JCalendarPage(date: dateAfter, isWeekly: isWeekly)
				
		
		super.init(frame: .zero)
		
		backgroundColor = .white
		
		
		// setup page delegates
		page1.delegate = self
		page2.delegate = self
		page3.delegate = self
		
		
		// setup page data sources
		page1.dataSource = self
		page2.dataSource = self
		page3.dataSource = self
		
		
		// layout our calendar and pages
		layoutDateView()
		layoutWeekView()
		layoutScrollView()
		addPages()
		
	}
	
	override func willMove(toWindow newWindow: UIWindow?) {
		super.willMove(toWindow: newWindow)
		
		if let _ = newWindow {
			
			scrollView.layoutIfNeeded()
			scrollView.contentSize = CGSize(width: scrollView.frame.size.width * (3), height: scrollView.frame.size.height)
			goToPage(1)
			
		}
		
	}
	
	private func layoutScrollView() {
		
		scrollView.delegate = self
		scrollView.panGestureRecognizer.maximumNumberOfTouches = 1
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.isPagingEnabled = true
		scrollView.bounces = false
		scrollView.showsHorizontalScrollIndicator = false
		addSubview(scrollView)
		
		NSLayoutConstraint.activate([
			
			scrollView.widthAnchor.constraint(equalTo: widthAnchor),
			scrollView.topAnchor.constraint(equalTo: weekView.bottomAnchor),
			scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
			
			])
		
	}
	
	private func layoutDateView() {
		
		// layout dateview
		dateView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(dateView)
		
		NSLayoutConstraint.activate([
			
			dateView.widthAnchor.constraint(equalTo: widthAnchor),
			dateView.heightAnchor.constraint(equalToConstant: headerHeight / 2),
			dateView.topAnchor.constraint(equalTo: topAnchor),
			dateView.centerXAnchor.constraint(equalTo: centerXAnchor)
			
			])
		
		
		// layout label
		dateViewLabel.translatesAutoresizingMaskIntoConstraints = false
		setDateViewLabelDate(date)
		dateViewLabel.font = UIFont.systemFont(ofSize: 22)
		dateViewLabel.textAlignment = .center
		dateView.addSubview(dateViewLabel)
		
		NSLayoutConstraint.activate([
			
			dateViewLabel.widthAnchor.constraint(equalTo: dateView.widthAnchor),
			dateViewLabel.heightAnchor.constraint(equalTo: dateView.heightAnchor),
			dateViewLabel.centerXAnchor.constraint(equalTo: dateView.centerXAnchor),
			dateViewLabel.centerYAnchor.constraint(equalTo: dateView.centerYAnchor)
			
			])
		
		
		todayButton.translatesAutoresizingMaskIntoConstraints = false
		todayButton.setTitle("Today", for: .normal)
		todayButton.setTitleColor(colorScheme.today, for: .normal)
		todayButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
		todayButton.sizeToFit()
		
		todayButton.addTarget(self, action: #selector(todayButtonPressed(_:)), for: [.touchUpInside])
		todayButton.addTarget(self, action: #selector(todayButtonExit(_:)), for: [.touchDragExit, .touchCancel])
		todayButton.addTarget(self, action: #selector(todayButtonDown(_:)), for: [.touchDown, .touchDragEnter])
		
		dateView.addSubview(todayButton)
		
		NSLayoutConstraint.activate([
			
			todayButton.trailingAnchor.constraint(equalTo: dateView.trailingAnchor, constant: -20),
			todayButton.centerYAnchor.constraint(equalTo: dateView.centerYAnchor)
			
			])
		
		
	}
	
	private func layoutWeekView() {
		
		weekView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(weekView)
		
		NSLayoutConstraint.activate([
			
			weekView.widthAnchor.constraint(equalTo: widthAnchor),
			weekView.heightAnchor.constraint(equalToConstant: headerHeight / 2),
			weekView.centerXAnchor.constraint(equalTo: centerXAnchor),
			weekView.topAnchor.constraint(equalTo: dateView.bottomAnchor)
			
			])
		
		var previousWeekdayView: UIView?
		for i in 0..<7 {
			
			let weekdayView = UIView()
			weekdayView.translatesAutoresizingMaskIntoConstraints = false
			weekView.addSubview(weekdayView)
			
			NSLayoutConstraint.activate([
				
				weekdayView.widthAnchor.constraint(equalTo: weekView.widthAnchor, multiplier: 1 / 7),
				weekdayView.heightAnchor.constraint(equalTo: weekView.heightAnchor),
				weekdayView.leadingAnchor.constraint(equalTo: previousWeekdayView?.trailingAnchor ?? weekView.leadingAnchor),
				weekdayView.bottomAnchor.constraint(equalTo: weekView.bottomAnchor)
				
				])
			
			previousWeekdayView = weekdayView
			
			
			// setup label for weekday view
			let textLabel = UILabel()
			textLabel.translatesAutoresizingMaskIntoConstraints = false
			textLabel.textAlignment = .center
			textLabel.text = Date.veryShortWeekdaySymbols[i]
			
			
			
			// set text color for weekends
			if i == 0 || i == 6 {
				textLabel.textColor = UIColor(white: 0, alpha: 0.5)
			}
			
			
			// add to weekday view
			weekdayView.addSubview(textLabel)
			
			
			// setup constraints
			NSLayoutConstraint.activate([
				
				textLabel.widthAnchor.constraint(equalTo: weekdayView.widthAnchor),
				textLabel.heightAnchor.constraint(equalTo: weekdayView.heightAnchor),
				textLabel.centerXAnchor.constraint(equalTo: weekdayView.centerXAnchor),
				textLabel.centerYAnchor.constraint(equalTo: weekdayView.centerYAnchor)
				
				])
			
		}
		
	}
	
	private func addPages() {
		
		// page 1
		page1.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(page1)
		
		NSLayoutConstraint.activate([
			
			page1.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			page1.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
			page1.topAnchor.constraint(equalTo: scrollView.topAnchor),
			page1.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			
			])
		
		
		// page 2
		page2.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(page2)
		
		NSLayoutConstraint.activate([
			
			page2.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			page2.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
			page2.topAnchor.constraint(equalTo: scrollView.topAnchor),
			page2.leadingAnchor.constraint(equalTo: page1.trailingAnchor),
			
			])
		
		
		// page 3
		page3.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(page3)
		
		NSLayoutConstraint.activate([
			
			page3.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			page3.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
			page3.topAnchor.constraint(equalTo: scrollView.topAnchor),
			page3.leadingAnchor.constraint(equalTo: page2.trailingAnchor),
			
			])
		
	}
	
	private func resetPageDates() {
		page1.setDate(toSectionBeforeDate: date)
		page2.setDate(date)
		page3.setDate(toSectionAfterDate: date)
		
		page2.delegate?.calendarPage(page2, didSelectDate: date, selectedAutomatically: selectedPageAutomatically, isReselecting: false)
		selectedPageAutomatically = true
		
		setDateViewLabelDate(page2.date)
	}
	
	private func prepareForPageChange(direction: JDirection) {
		let offset = direction == .backwards ? -1 : 1
		
		var date: Date
		if isWeekly {
			date = self.date.adding(week: offset)
			if date.weekRange.includes(date: Date()) {
				date = Date()
			} else {
				date = date.beginningOfWeek
			}
		} else {
			date = self.date.adding(month: offset)
			if date.hasSameMonth(asDate: Date()) {
				date = Date()
			} else {
				date = date.beginningOfMonth
			}
		}
		
		self.date = date
		updateContentOffsetForMovement(inDirection: direction)
	}
	
	private func prepareHeightForPageChange(direction: JDirection, forceDate: Date?) {
		
		let numWeeks: Int
		if isWeekly {
			numWeeks = 1
		} else {
			let offset = direction == .backwards ? -1 : 1
			var date = forceDate ?? self.date.adding(month: offset)
			if date.hasSameMonth(asDate: Date()) {
				date = Date()
			} else {
				date = date.beginningOfMonth
			}
			numWeeks = date.numberOfWeeksInMonth
		}
		
		scrollView.contentSize = CGSize(width: scrollView.frame.size.width * (3), height: scrollView.frame.size.height)
		delegate?.calendar(self, willUpdateHeight: (frame.width / 7).rounded(.down) * CGFloat(numWeeks))
		
	}
	
	private func goToPage(_ page: Int, animated: Bool = false) {
		
		scrollView.isUserInteractionEnabled = !animated
		
		var offset = scrollView.contentOffset
		let x = scrollView.frame.size.width * CGFloat(page)
		
		if offset.x != x {
			offset.x = x
			scrollView.setContentOffset(offset, animated: animated)
		}
		
	}
	
	private func pageAtOffset(_ offset: CGPoint) -> Int {
		return Int(offset.x / scrollView.frame.size.width)
	}
	
	
	private func updateContentOffsetForMovement(inDirection direction: JDirection) {
		
		switch direction {
			
		case .backwards:
			scrollView.contentOffset.x += scrollView.frame.size.width
			
		case .forwards:
			scrollView.contentOffset.x -= scrollView.frame.size.width
			
		default:
			break
			
		}
		
	}
	
	func selectDate(_ date: Date) {
		
		selectingDate = date
		
		if (!isWeekly && date.hasSameMonth(asDate: self.date)) ||
			(isWeekly && date.contained(in: self.date.weekRange)) {
			page2.setDate(date)
		} else {
			
			let i = date < self.date ? 0 : 2
			let page = i == 0 ? page1 : page3
			
			page.setDate(date, forceUpdateLayout: true)
			
			goToPage(i, animated: true)
			scrollViewWillEndAtPage(i, forceDate: date)
			
		}
		
	}
	
	private func setDateViewLabelDate(_ date: Date) {
		dateViewLabel.text = date.string(format: dateFormat)
		
		if (!isWeekly && date.hasSameMonth(asDate: Date())) ||
			(isWeekly && date.contained(in: Date().weekRange)) {
			dateViewLabel.textColor = colorScheme.today
			todayButton.isHidden = true
		} else {
			dateViewLabel.textColor = colorScheme.text
			todayButton.isHidden = false
		}
		
	}
	
	@objc private func todayButtonDown(_ sender: UIButton) {
		sender.alpha = 0.4
	}
	@objc private func todayButtonExit(_ sender: UIButton) {
		sender.alpha = 1
	}
	@objc private func todayButtonPressed(_ sender: UIButton) {
		sender.alpha = 1
		
		let today = Date()
		selectDate(today)
	}
	
}



extension JCalendar: UIScrollViewDelegate, JCalendarPageDelegate, JCalendarPageDataSource {
	
	
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		scrollView.isUserInteractionEnabled = false
		targetPage = Int(targetContentOffset.pointee.x / scrollView.frame.size.width)
		
		if targetPage == 1 {
			targetPage = nil
			scrollView.isUserInteractionEnabled = true
		} else {
			scrollViewWillEndAtPage(targetPage!, forceDate: nil)
		}
		
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard let targetPage = targetPage else { return }
		scrollViewDidEndAtPage(targetPage)
		scrollView.isUserInteractionEnabled = true
		self.targetPage = nil
	}
	
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		
		guard let date = selectingDate else { return }
		
		goToPage(1)
		self.date = date
		
		selectingDate = nil
		scrollView.isUserInteractionEnabled = true
		
	}
	
	private func scrollViewDidEndAtPage(_ page: Int) {
		prepareForPageChange(direction: page < 1 ? .backwards : .forwards)
	}
	
	private func scrollViewWillEndAtPage(_ page: Int, forceDate: Date?) {
		prepareHeightForPageChange(direction: page < 1 ? .backwards : .forwards, forceDate: forceDate)
	}
	
	func calendarPage(_ page: JCalendarPage, didSelectDate date: Date, selectedAutomatically: Bool, isReselecting: Bool) {
		
		if self.date.hasSameMonth(asDate: date) {
			delegate?.calendar(self, didSelectDate: date, selectedAutomatically: selectedAutomatically, isReselecting: isReselecting)
		} else {
			selectedPageAutomatically = selectedAutomatically
			selectDate(date)
		}
		
	}
	
	func calendarPage(_ calendarPage: JCalendarPage, markerColorForDate date: Date) -> UIColor? {
		return dataSource?.calendar(self, markerColorForDate: date)
	}
	
	func calendarPage(_ page: JCalendarPage, willUpdateHeight height: CGFloat) {
		guard !heightPrepared else { return }
		if page == page2 {
			delegate?.calendar(self, willUpdateHeight: height)
			heightPrepared = true
		}
	}
	
}
