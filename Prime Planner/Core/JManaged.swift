//
//  JManaged.swift
//  Money
//
//  Created by Jacob Caraballo on 8/18/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import CoreData


// Class that simplifies the management of objects in the database, if they are desired to be customized.
class JManaged {
	
	class func set(_ value: Any?, forKey key: String, inObject object: NSManagedObject) {
		object.willChangeValue(forKey: key)
		object.setPrimitiveValue(value, forKey: key)
		object.didChangeValue(forKey: key)
	}
	
	class func get(_ key: String, inObject object: NSManagedObject) -> Any? {
		object.willAccessValue(forKey: key)
		let value = object.primitiveValue(forKey: key)
		object.didAccessValue(forKey: key)
		return value
	}
	
}
