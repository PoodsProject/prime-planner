//
//  TaskDetailViewController.swift
//  Prime Planner
//
//  Created by Jacob Caraballo on 9/14/18.
//  Copyright © 2018 Poods. All rights reserved.
//

import Foundation
import UIKit

class TaskDetailViewController: UIViewController {
	
	private let testDetailLabel = UILabel()
	
	// this is project private by default, so any class in the project can access and edit it
	var detailTextPassedFromPreviousController = "Hello, World!" {
		
		// lets observe the setter and update our label text when the detail text is changed
		didSet {
			
			// update our label text
			testDetailLabel.text = detailTextPassedFromPreviousController
			
			
			// once the text is set, lets size the label to fit the text that its holding
			testDetailLabel.sizeToFit()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set our background color, because it's transparent by default
		view.backgroundColor = .white
		
		
		// layout our test label
		layoutTestDetailLabel()
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// ensure that our nav bar is showing in this controller,
		// since it's being pushed from a controller where it's hidden
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	func layoutTestDetailLabel() {
		
		testDetailLabel.translatesAutoresizingMaskIntoConstraints = false
		testDetailLabel.font = UIFont.systemFont(ofSize: 60)
		testDetailLabel.textColor = .red
		view.addSubview(testDetailLabel)
		
		
		// we're only going to constrain the center anchors, because
		// the sizing is managed by the setter observer above
		NSLayoutConstraint.activate([
			
			testDetailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			testDetailLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			
			])
		
	}
	
}
