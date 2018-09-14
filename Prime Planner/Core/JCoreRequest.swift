//
//  JCore+Fetch.swift
//  JCore
//
//  Created by Jacob Caraballo on 8/6/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import CoreData

struct JCoreRequestKey {
	fileprivate var key: String
	fileprivate let groupBy: Bool
	
	fileprivate var keyPath: String?
	fileprivate var type: NSAttributeType?
	
	init(key: String) {
		self.key = key
		self.groupBy = true
	}
	
	init(key: String, keyPath: String, type: NSAttributeType) {
		self.key = key
		self.keyPath = keyPath
		self.type = type
		self.groupBy = false
	}
}

class JCoreRequest<T: NSManagedObject> {
	
	private var request: NSFetchRequest<T>
	private var sortHandler: ((T, T) -> (Bool))?
	private var filterHandler: ((T) -> (Bool))?
	
	
	/// Returns the count of objects represented by the current request.
	var count: Int {
		return fetch(keyPath: "@count") as! Int
	}
	
	
	init(request: NSFetchRequest<T>) {
		self.request = request
	}
	
	
	/// Filters the data in the request with a handler that traverses each object.
	func filter(_ filterHandler: @escaping ((T) -> (Bool))) -> JCoreRequest {
		self.filterHandler = filterHandler
		return self
	}
	
	
	/// Filters the data in the request using a predicate.
	func filter(_ predicate: NSPredicate) -> JCoreRequest {
		let newPredicate = predicate
		
		
		// if we already have a predicate in this request, compound them, otherwise set the predicate.
		if let predicate = request.predicate {
			request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, newPredicate])
		} else {
			request.predicate = newPredicate
		}
		
		return self
		
	}
	
	
	/// Filter the data in the request using a predicate format (uses SQL format).
	func filter(_ format: String, _ arguments: Any...) -> JCoreRequest {
		return filter(NSPredicate(format: format, argumentArray: arguments))
	}
	
	
	/// Sort the data in the request using a handler that traverses through the objects.
	func sort(by handler: @escaping (T, T) -> (Bool)) -> JCoreRequest {
		sortHandler = handler
		return self
	}
	
	
	/// Sort the data using a descriptor.
	func sort(_ descriptor: NSSortDescriptor) -> JCoreRequest {
		
		// if we have no current descriptors, create an array to hold any new descriptors.
		if request.sortDescriptors == nil {
			request.sortDescriptors = [NSSortDescriptor]()
		}
		
		// append the passed descriptor to the array
		request.sortDescriptors?.append(descriptor)
		
		return self
	}
	
	
	/// Sort the data using a descriptor string.
	func sort(_ descriptor: String, ascending: Bool, caseInsensitive: Bool = false) -> JCoreRequest {
		
		let desc: NSSortDescriptor
		
		if caseInsensitive {
			desc = NSSortDescriptor(key: descriptor, ascending: ascending, selector: #selector(NSString.caseInsensitiveCompare(_:)))
		} else {
			desc = NSSortDescriptor(key: descriptor, ascending: ascending)
		}
		
		return sort(desc)
	}
	
	
	/// Limit the number of objects that will be returned.
	func limit(_ limit: Int) -> JCoreRequest {
		request.fetchLimit = limit
		return self
	}
	
	
	/// Fetch any objects that match the given keyPath.
	func fetch(keyPath: String, fromContext context: NSManagedObjectContext = JCore.shared.context) -> Any? {
		
		var result: Any?
		
		if let results = try? context.fetch(request) as NSArray {
			result = results.value(forKeyPath: keyPath)
		}
		
		return result
		
	}
	
	
	/// Fetch any objects using request keys for expressions.
	func fetch(keys: [JCoreRequestKey], distinct: Bool, includeObject: Bool = true, fromContext context: NSManagedObjectContext = JCore.shared.context) -> JCoreArray<T> {
		
		
		// loop through keys and create expressions for each
		var propertiesToGroupBy = [Any]()
		var propertiesToFetch = [Any]()
		
		for key in keys {
			
			if key.groupBy {
				propertiesToGroupBy.append(key.key)
			}
			
			if let keyPath = key.keyPath, let type = key.type {
				
				let description = NSExpressionDescription()
				description.expression = NSExpression(forKeyPath: keyPath)
				description.name = key.key
				description.expressionResultType = type
				propertiesToFetch.append(description)
				
			} else {
				
				propertiesToFetch.append(key.key)
				
			}
			
		}
		
		
		// create expression and description for the main object
		if includeObject {
			let expression = NSExpression.expressionForEvaluatedObject()
			let description = NSExpressionDescription()
			description.name = "object"
			description.expression = expression
			description.expressionResultType = .objectIDAttributeType
			propertiesToFetch.append(description)
		}
		
		
		// setup the request
		let className = NSStringFromClass(T.self).components(separatedBy: ".").last!
		let request = NSFetchRequest<NSDictionary>(entityName: className)
		request.resultType = .dictionaryResultType
		request.propertiesToGroupBy = propertiesToGroupBy
		request.propertiesToFetch = propertiesToFetch
		request.returnsDistinctResults = distinct
		request.predicate = self.request.predicate
		request.sortDescriptors = self.request.sortDescriptors
		request.fetchLimit = self.request.fetchLimit
		
		
		// fetch objects based on the requested properties
		var objects = [[String: Any]]()
		do {
			objects = try context.fetch(request) as! [[String : Any]]
		} catch let e as NSError {
			print("Core.loadAll()\nERROR: \(e)")
		}
		
		
		// create a core array wherein our data can be nested
		let fetchedArray = JCoreArray<T>(data: objects)
		
		
		// sort our data, if a handler was specified
		if let sort = sortHandler {
			fetchedArray.sortObjects(by: sort)
		}
		
		
		// return our array
		return fetchedArray
		
	}
	
	
	/// Fetch all objects in the request as an array.
	func fetch(fromContext context: NSManagedObjectContext = JCore.shared.context) -> [T] {
		
		var objects = [T]()
		
		context.performAndWait {
			do {
				objects = try context.fetch(request)
			} catch let e as NSError {
				print("Core.loadAll()\nERROR: \(e)")
			}
			
			if let sort = sortHandler {
				objects.sort(by: sort)
			}
			
			if let filter = filterHandler {
				objects = objects.filter(filter)
			}
		}
		
		return objects
		
	}
	
	
	/// Fetch key objects in the request as an array or return nil if no objects were found.
	func fetchOrNil(keys: [JCoreRequestKey], distinct: Bool, fromContext context: NSManagedObjectContext = JCore.shared.context) -> JCoreArray<T>? {
		let results = fetch(keys: keys, distinct: distinct, fromContext: context)
		return results.count != 0 ? results : nil
	}
	
	
	/// Fetch all objects in the request as an array or return nil if no objects were found.
	func fetchOrNil(fromContext context: NSManagedObjectContext = JCore.shared.context) -> [T]? {
		let results = fetch(fromContext: context)
		return results.count != 0 ? results : nil
	}
	
	
	/// Fetch first object in the request.
	func fetchFirst(fromContext context: NSManagedObjectContext = JCore.shared.context) -> T? {
		return limit(1).fetch(fromContext: context).first
	}
	
}
