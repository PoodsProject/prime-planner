//
//  JCoreArray.swift
//  JCore
//
//  Created by Jacob Caraballo on 9/7/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import CoreData

struct JCoreArrayIterator: IteratorProtocol {

	let array: [[String: Any]]
	var index = 0

	init(_ array: [[String: Any]]) {
		self.array = array
	}
	
	mutating func next() -> [String: Any]? {

		let processingIndex = index
		guard processingIndex < array.count else { return nil }
		index += 1
		return array[processingIndex]
		
	}

}

class JCoreArray<T: NSManagedObject>: Sequence {
	
	
	private var data: [[String: Any]]
	private var context: NSManagedObjectContext {
		return JCore.shared.context
	}
	var count: Int {
		return data.count
	}
	
	subscript(index: Int) -> [String: Any] {
		return data[index]
	}
	
	
	
	init(data: [[String: Any]]) {
		self.data = data
	}
	
	init() {
		self.data = [[String: Any]]()
	}
	
	
	
	/// Returns the value of the given key and index of the core array.
	func value(forKey key: String, atIndex index: Int) -> Any? {
		guard index < data.count else { return nil }
		return data[index][key]
	}
	
	
	/// Sorts the core array using the given block.
	func sort(by areInIncreasingOrder: @escaping ([String: Any], [String: Any]) -> (Bool)) {
		data.sort(by: areInIncreasingOrder)
	}
	
	
	/// Returns the index of the first dictionary where the key matches the given property.
	func index<U: Equatable>(of object: Any, withKey key: String, type: U.Type) -> Int? {
		guard let object = object as? U else { return nil }
		return data.index { $0[key] as? U == object }
	}
	
	
	func makeIterator() -> JCoreArrayIterator {
		return JCoreArrayIterator(data)
	}
	
	
}


// object functions
extension JCoreArray {
	
	
	/// Returns the object in the core array at the given index, if found.
	func object(atIndex index: Int) -> T? {
		guard index < data.count, let id = data[index]["object"] as? NSManagedObjectID else { return nil }
		return context.object(with: id) as? T
	}
	
	
	/// Searches the dictionary for a JCoreArray object and returns it if found.
	func object(fromDictionary dict: [String: Any]) -> T? {
		guard let id = dict["object"] as? NSManagedObjectID else { return nil }
		return object(with: id) as? T
	}
	
	
	/// Returns the object in the context with the given id
	func object(with id: NSManagedObjectID) -> NSManagedObject {
		return context.object(with: id)
	}
	
	
	/// Returns an array of every object value for the given keyPath.
	func objectValues(forKeyPath keyPath: String) -> [Any] {
		return data.map { dict -> Any in
			let obj = self.object(fromDictionary: dict)!
			return obj.value(forKeyPath: keyPath)!
		}
	}
	
	
	/// Iterates through each object in the core array
	func forEachObject(_ body: (T) -> Void) {
		data.forEach { dict in
			guard let obj = self.object(fromDictionary: dict) else { return }
			body(obj)
		}
	}
	
	
	/// Returns the index of the first object where the key matches the given property.
	func indexOfObject<U: Equatable>(where key: String, equals property: Any, type: U.Type) -> Int? {
		guard let property = property as? U else { return nil }
		return data.index { dict -> Bool in
			let obj = self.object(fromDictionary: dict)!
			return obj.value(forKey: key) as? U == property
		}
	}
	
	
	/// Sorts the objects in the core array using the given block.
	func sortObjects(by areInIncreasingOrder: @escaping (T, T) -> (Bool)) {
		
		data.sort { (d1, d2) -> Bool in
			
			let o1 = context.object(with: d1["object"] as! NSManagedObjectID) as! T
			let o2 = context.object(with: d2["object"] as! NSManagedObjectID) as! T
			return areInIncreasingOrder(o1, o2)
			
		}
		
	}
	
	
}
