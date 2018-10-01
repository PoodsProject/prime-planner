//
//  JCore.swift
//  JCore
//
//  Created by Jacob Caraballo on 9/6/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import CoreData


/// retrieves the Core Database shared instance.
var jcore = JCore.shared

class JCore {
	
	// initialize our core database and assign it to our shared variable
	static var shared = JCore()
	
	let container: NSPersistentContainer
	
	// getters for the context and coordinator
	var context: NSManagedObjectContext {
		return container.viewContext
	}
	var coordinator: NSPersistentStoreCoordinator {
		return container.persistentStoreCoordinator
	}
	
	init() {
		
		
		// initialize our container
		container = NSPersistentContainer(name: "JCore")
		
		
		// load the persistent store
		container.loadPersistentStores { (description, error) in
			
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
			
		}
		
		
		// setup the context allowing automatic merges from the parent
		context.automaticallyMergesChangesFromParent = true
		
		
	}
	
	
	/// Updates the context with any pending changes and saves into the database. Context defaults to the main context.
	func save(context: NSManagedObjectContext = JCore.shared.context) {
		if context.hasChanges {
			
			// try to save the context
			do {
				try context.save()
			} catch let error as NSError {
				// an error could occur in the case of low space or memory on the device
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
			
			// if we passed in a context other than the main context, update the main context afterwards
			if context != JCore.shared.context {
				save()
			}
			
		}
	}
	
	
	/// Inserts a new object with the passed Type into the context and returns it.
	func new<T: NSManagedObject>(_ type: T.Type) -> T {
		let name = NSStringFromClass(type).components(separatedBy: ".").last!
		return NSEntityDescription.insertNewObject(forEntityName: name, into: context) as! T
	}
	
	
	/// Removes an object from the context, thus removing it from the database.
	func remove(_ object: NSManagedObject?) {
		guard let object = object else { return }
		context.delete(object)
		save()
	}
	
	
	/**
	
	Begins a request for every object in the database that is associated with the given type.
	
	- Parameter type: The object type that is being requested from the database
	
	- Returns: A `JCoreRequest` representing the objects for the given type.
	
	*/
	func data<T: NSManagedObject>(_ type: T.Type) -> JCoreRequest<T> {
		
		// get the class name from the passed type as a string
		let className = String(describing: type)
		
		// create a request with the class name (corresponds to the entity in our data model)
		let request = NSFetchRequest<T>(entityName: className)
		request.returnsObjectsAsFaults = false
		
		// return a new core request with our fetch request
		return JCoreRequest<T>(request: request)
		
	}
	
}
