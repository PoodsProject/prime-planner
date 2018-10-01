//
//  Date-Convenience.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/14/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation

func ==(lhs: DateRange, rhs: DateRange) -> Bool {
	return lhs.id == rhs.id
}

func <(lhs: DateRange, rhs: DateRange) -> Bool {
	return lhs.start < rhs.start
}

func >(lhs: DateRange, rhs: DateRange) -> Bool {
	return lhs.start > rhs.start
}


// a class that will hold a start date and an end date
class DateRange: Hashable, Equatable {
	var id = UUID()
	var start: Date
	var end: Date
	var string: String {
		return start.string
	}
	
	var hashValue: Int {
		get {
			return id.hashValue
		}
	}
	
	init(start: Date, end: Date) {
		
		if start > end {
			self.start = end
			self.end = start
		} else {
			self.start = start
			self.end = end
		}
		
	}
	
	init() {
		self.start = Date()
		self.end = Date()
	}
	
	func includes(date: Date) -> Bool {
		start = start.beginningOfDay
		end = end.endOfDay
		
		return date.contained(in: self)
	}
}


// here we extend the Date class
extension Date {
	
	
	// declare a getter that retrieves the current calendar
	private var calendar: Calendar! {
		return Calendar.current
	}
	
	
	//MARK: component getters
	static var veryShortWeekdaySymbols: [String] {
		return Calendar.current.veryShortStandaloneWeekdaySymbols
	}
	var components: DateComponents {
		return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
	}
	
	var year: Int {
		return calendar.dateComponents([.year], from: self).year!
	}
	
	var month: Int {
		return calendar.dateComponents([.month], from: self).month!
	}
	
	var day: Int {
		return calendar.dateComponents([.day], from: self).day!
	}
	
	var dayOfYear: Int {
		return calendar.ordinality(of: .day, in: .year, for: self)!
	}
	
	var weekday: Int {
		return calendar.ordinality(of: .weekday, in: .weekOfMonth, for: self)!
	}
	
	var weekOfYear: Int {
		return calendar.component(.weekOfYear, from: self)
	}
	
	var hour: Int {
		return calendar.dateComponents([.hour], from: self).hour!
	}
	
	var minute: Int {
		return calendar.dateComponents([.minute], from: self).minute!
	}
	
	var second: Int {
		return calendar.component(.second, from: self)
	}
	
	var nanosecond: Int {
		return calendar.component(.nanosecond, from: self)
	}
	
	var amPM: String {
		return hour <= 11 ? "AM" : "PM"
	}
	
	var numberOfWeeksInMonth: Int {
		let range = calendar.range(of: .weekOfMonth, in: .month, for: self)!
		return range.upperBound - range.lowerBound
	}
	
	
	// MARK: current dates
	static var currentYear: Int {
		return Date().year
	}
	static var currentMonth: Int {
		return Date().month
	}
	static var currentDay: Int {
		return Date().day
	}
	
	static var todayString: String {
		return Date().string(format: "EEEE, MMM d")
	}
	
	var flat: Date {
		return beginningOfDay
	}
	
	var beginningOfDay: Date {
		var date = self
		date.set(hour: 0)
		date.set(minute: 0)
		date.set(second: 0)
		return date
	}
	var endOfDay: Date {
		var components = calendar.dateComponents([.day, .month, .year], from: self)
		components.day! += 1
		components.hour = 0
		components.minute = 0
		components.second = -1
		return calendar.date(from: components)!
	}
	var beginningOfWeek: Date {
		let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
		return calendar.date(from: components)!
	}
	var endOfWeek: Date {
		var startOfWeek = Date()
		var interval: TimeInterval = 0
		_ = calendar.dateInterval(of: .weekOfYear, start: &startOfWeek, interval: &interval, for: self)
		
		var components = calendar.dateComponents([.day, .month, .year], from: startOfWeek)
		components.day! += 7
		components.hour = 0
		components.minute = 0
		components.second = -1
		return calendar.date(from: components)!
	}
	var beginningOfMonth: Date {
		var components = calendar.dateComponents([.day, .month, .year], from: self)
		components.day = 1
		components.hour = 0
		components.minute = 0
		components.second = 0
		return calendar.date(from: components)!
	}
	var endOfMonth: Date {
		var components = calendar.dateComponents([.day, .month, .year], from: self)
		components.month! += 1
		components.day = 1
		components.hour = 0
		components.minute = 0
		components.second = -1
		return calendar.date(from: components)!
	}
	var beginningOfYear: Date {
		var components = calendar.dateComponents([.day, .month, .year], from: self)
		components.month = 1
		components.day = 1
		components.hour = 0
		components.minute = 0
		components.second = 0
		return calendar.date(from: components)!
	}
	var endOfYear: Date {
		var components = calendar.dateComponents([.day, .month, .year], from: self)
		components.year! += 1
		components.month = 1
		components.day = 0
		components.hour = 0
		components.minute = 0
		components.second = -1
		return calendar.date(from: components)!
	}
	
	
	
	//MARK: date manipulation
	func adding(year: Int) -> Date {
		var offsetComponents = DateComponents()
		offsetComponents.year = year
		return calendar.date(byAdding: offsetComponents, to: self)!
	}
	func adding(month: Int) -> Date {
		var offsetComponents = DateComponents()
		offsetComponents.month = month
		return calendar.date(byAdding: offsetComponents, to: self)!
	}
	func adding(week: Int) -> Date {
		return adding(day: week * 7)
	}
	func adding(day: Int) -> Date {
		var offsetComponents = DateComponents()
		offsetComponents.day = day
		return calendar.date(byAdding: offsetComponents, to: self)!
	}
	func adding(hour: Int) -> Date {
		var offsetComponents = DateComponents()
		offsetComponents.hour = hour
		return calendar.date(byAdding: offsetComponents, to: self)!
	}
	func adding(minute: Int) -> Date {
		var offsetComponents = DateComponents()
		offsetComponents.minute = minute
		return calendar.date(byAdding: offsetComponents, to: self)!
	}
	func adding(second: Int) -> Date {
		var offsetComponents = DateComponents()
		offsetComponents.second = second
		return calendar.date(byAdding: offsetComponents, to: self)!
	}
	
	mutating func set(year: Int) {
		var components = self.components
		components.year = year
		self = calendar.date(from: components)!
	}
	
	mutating func set(month: Int) {
		var components = self.components
		components.month = month
		self = calendar.date(from: components)!
	}
	
	mutating func set(day: Int) {
		var components = self.components
		components.day = day
		self = calendar.date(from: components)!
	}
	
	mutating func set(hour: Int) {
		var components = self.components
		components.hour = hour
		self = calendar.date(from: components)!
	}
	
	mutating func set(minute: Int) {
		var components = self.components
		components.minute = minute
		self = calendar.date(from: components)!
	}
	
	mutating func set(second: Int) {
		var components = self.components
		components.second = second
		self = calendar.date(from: components)!
	}
	
	
	// MARK: counting
	func count(daysToDate date: Date) -> Int {
		return calendar.dateComponents([.day], from: self, to: date).day!
	}
	
	func count(monthsToDate date: Date) -> Int {
		return calendar.dateComponents([.month], from: self, to: date).month!
	}
	
	func count(yearsToDate date: Date) -> Int {
		return calendar.dateComponents([.year], from: self, to: date).year!
	}
	
	var numberOfDaysInMonth: Int {
		let range = calendar.range(of: .day, in: .month, for: self)!
		return range.upperBound - range.lowerBound
	}
	
	func count(componentsToDate date: Date, unit: Calendar.Component) -> Int {
		var result = 0
		
		var _startDate = Date()
		var _endDate = Date()
		var _startInterval: TimeInterval = 0
		var _endInterval: TimeInterval = 0
		let startSuccess = calendar.dateInterval(of: unit, start: &_startDate, interval: &_startInterval, for: self)
		let endSuccess = calendar.dateInterval(of: unit, start: &_endDate, interval: &_endInterval, for: date)
		
		if startSuccess && endSuccess {
			let difference = calendar.dateComponents([unit], from: _startDate, to: _endDate)
			
			switch(unit) {
			case .year:
				result = difference.year!
			case .month:
				result = difference.month!
			case .weekOfMonth:
				result = difference.weekday!
			case .day:
				result = difference.day!
			default:
				result = 0
			}
		}
		
		return result
	}
	
	
	
	//MARK: ranges
	var dayRange: DateRange {
		return DateRange(start: beginningOfDay, end: endOfDay)
	}
	
	var weekRange: DateRange {
		return DateRange(start: beginningOfWeek, end: endOfWeek)
	}
	
	var monthRange: DateRange {
		return DateRange(start: beginningOfMonth, end: endOfMonth)
	}
	
	var yearRange: DateRange {
		return DateRange(start: beginningOfYear, end: endOfYear)
	}
	
	var dayAheadRange: DateRange {
		return DateRange(start: self, end: adding(day: 1).adding(second: -1))
	}
	
	var monthAheadRange: DateRange {
		return DateRange(start: self, end: adding(month: 1).adding(second: -1))
	}
	
	var yearAheadRange: DateRange {
		return DateRange(start: self, end: adding(year: 1).adding(second: -1))
	}
	
	func range(forUnit unit: Calendar.Component) -> DateRange {
		var endDate: Date
		
		if unit == .day {
			endDate = adding(day: 1)
		} else if unit == .month {
			endDate = adding(month: 1)
		} else if unit == .year {
			endDate = adding(year: 1)
		} else {
			endDate = Date()
		}
		
		return DateRange(start: self, end: endDate.adding(second: -1))
	}
	
	func contained(in range: DateRange) -> Bool {
		return self >= range.start && self <= range.end
	}
	
	
	
	//MARK: date testing
	func contained(within start: Date, to: Date) -> Bool {
		let interval = timeIntervalSinceReferenceDate
		let startInterval = start.timeIntervalSinceReferenceDate
		let endInterval = to.timeIntervalSinceReferenceDate
		return interval >= startInterval && interval <= endInterval
	}
	func hasSameDay(asDate date: Date) -> Bool {
		let unitFlags: Set<Calendar.Component> = [.year, .month, .day]
		let comp1 = calendar.dateComponents(unitFlags, from: self)
		let comp2 = calendar.dateComponents(unitFlags, from: date)
		
		return comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day
	}
	func hasSameMonth(asDate date: Date) -> Bool {
		let unitFlags: Set<Calendar.Component> = [.year, .month]
		let comp1 = calendar.dateComponents(unitFlags, from: self)
		let comp2 = calendar.dateComponents(unitFlags, from: date)
		return comp1.month == comp2.month && comp1.year == comp2.year
	}
	var isInToday: Bool {
		return calendar.isDateInToday(self)
	}
	var isInTomorrow: Bool {
		return calendar.isDateInTomorrow(self)
	}
	func isInSameDay(as date: Date) -> Bool {
		return calendar.isDate(self, inSameDayAs: date)
	}
	
	
	
	//MARK: date creation
	init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
		
		self.init()
		
		var components = DateComponents()
		components.year = year
		components.month = month
		components.day = day
		components.hour = hour
		components.minute = minute
		components.second = second
		self = calendar.date(from: components)!
	}
	
	init(year: Int, month: Int, day: Int) {
		self.init(year: year, month: month, day: day, hour: 0, minute: 0, second: 0)
	}
	
	
	
	//MARK: formatting
	var weekdayString: String {
		return string(format: "EEEE")
	}
	
	var string: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		return formatter.string(from: self)
	}
	
	func string(format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .none
		formatter.dateFormat = format
		return formatter.string(from: self)
	}
	
	func string(style: DateFormatter.Style) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = style
		return formatter.string(from: self)
	}
	
	init(string: String, format: String? = nil) {
		
		self.init()
		
		let formatter = DateFormatter()
		if let format = format {
			formatter.dateStyle = .none
			formatter.dateFormat = format
		} else {
			formatter.dateStyle = .long
		}
		
		self = formatter.date(from: string) ?? Date()
		
	}
	
	init?(string: String, formats: [String]) {
		
		self.init()
		
		var potentialMonth = string.trimmingCharacters(in: CharacterSet.decimalDigits).prefix(3)
		var potentialYear = string.trimmingCharacters(in: CharacterSet.letters)
		
		if potentialMonth.count != 3 {
			potentialMonth = ""
		}
		
		if potentialYear.count != 4 {
			potentialYear = ""
		}
		
		let potentialDate: String = potentialMonth + potentialYear
		guard potentialDate.count != 0 else { return nil }
		
		let formatter = DateFormatter()
		var temp: Date?
		var needsToSetYear = false
		var passingFormatIndex: Int?
		
		for (i, format) in formats.enumerated() {
			formatter.dateFormat = format
			if let date = formatter.date(from: potentialDate) {
				needsToSetYear = format.range(of: "y", options: .caseInsensitive) == nil
				temp = date
				passingFormatIndex = i
				break
			}
		}
		
		var result = temp
		if let _ = result {
			
			let today = Date()
			let calendar = Calendar.current
			if needsToSetYear {
				let todayComps = calendar.dateComponents([.year, .month], from: today)
				var resultComps = calendar.dateComponents([.month], from: result!)
				
				if resultComps.month! > todayComps.month! {
					resultComps.year = todayComps.year! - 1
				} else {
					resultComps.year = todayComps.year
				}
				
				result = calendar.date(from: resultComps)
			}
			
			if let pos = passingFormatIndex {
				result = calendar.date(bySetting: .second, value: pos, of: result!)
			}
			
		}
		
		if let result = result {
			self = result
		} else {
			return nil
		}
		
	}
	
}
