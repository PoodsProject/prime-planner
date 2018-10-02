//
//  SelectionViewController~TableView.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit

extension SelectionViewController: UITableViewDelegate, UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return showsNoItemSection ? 2 : 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 && showsNoItemSection { return 1 }
		return items.count
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
		
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
			cell.selectionStyle = .none
		}
		
		let name = items[indexPath.row].title
		cell.textLabel?.text = name
		cell.contentView.alpha = 1
		cell.isUserInteractionEnabled = true
		cell.accessoryType = .none
		cell.backgroundColor = UIColor.clear
		cell.contentView.backgroundColor = UIColor.clear
		cell.textLabel?.textColor = .black
		
		if let object = selected.object as? TaskPriority, name == object.string {
			cell.accessoryType = .checkmark
		}
		
		return cell
	}
	func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
		UIView.animate(withDuration: 0.15) {
			tableView.cellForRow(at: indexPath)?.setScale(0.97)
		}
	}
	func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
		UIView.animate(withDuration: 0.15) {
			tableView.cellForRow(at: indexPath)?.setScale(1.0)
		}
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		dismiss(items[indexPath.row], cancelled: false)
	}
	
}
