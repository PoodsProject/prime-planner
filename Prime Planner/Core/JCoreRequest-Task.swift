//
//  JCoreRequest-Task.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/12/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation

extension JCore {
	
	var tasks: JCoreRequest<Task> {
		return jcore.data(Task.self)
	}
	
}


extension JCoreRequest where T: Task {
	
	
	
}
