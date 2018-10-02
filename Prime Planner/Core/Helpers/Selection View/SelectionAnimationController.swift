//
//  SelectionAnimationController.swift
//
//  Created by Jacob Caraballo on 10/1/18.
//  Copyright © 2018 Jacob Caraballo. All rights reserved.
//

import Foundation
import UIKit


// handles the scaling animation of the selection views
class SelectionAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	var presenting = true
	var scalingView: UIView?
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 0.4
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard
			let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
			let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
			else { return }
		let containerView = transitionContext.containerView
		
		
		if presenting {
			containerView.addSubview(toVC.view)
			
			let endFrame = transitionContext.finalFrame(for: toVC)
			let startFrame = endFrame
			
			toVC.view.frame = startFrame
			toVC.view.alpha = 0
			scalingView?.setScale(0.9)
			
			UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: ({
				fromVC.view.tintAdjustmentMode = .dimmed
				toVC.view.alpha = 1
				self.scalingView?.setScale(1)
			})) { _ in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			}
		} else {
			UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: ({
				toVC.view.tintAdjustmentMode = .automatic
				fromVC.view.alpha = 0
				self.scalingView?.setScale(0.9)
			})) { _ in
				transitionContext.completeTransition(true)
			}
		}
		
		
	}
	
}
