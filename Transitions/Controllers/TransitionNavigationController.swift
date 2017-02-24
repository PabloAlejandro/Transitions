//
//  TransitionNavigationController.swift
//  Transitions
//
//  Created by Pau on 17/02/2017.
//  Copyright © 2017 Pau. All rights reserved.
//

import Foundation
import UIKit

// NOTE: Do not set delegate for this class, instead use self.transition?.navigationControllerDelegate 
// if you need to get the calls from the navigation controller's delegate.

class TransitionNavigationController: UINavigationController {

    fileprivate var transition: NavigationTransition?
    
    var transitionConfiguration: TransitionConfiguration! {
        didSet {
            self.transition = GenericTransition(withNavigationController: self, configuration: transitionConfiguration)
        }
    }
    
    // MARK: Native transition methods
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }
    
    // MARK: Custom transition methods
    
    func pushViewController(_ viewController: UIViewController, withBlock pushBlock: @escaping TransitionBlock) {
        if let transition = transition {
            transition.push(viewController: viewController, withBlock: pushBlock)
        } else {
            super.pushViewController(viewController, animated: true)
        }
    }
    
    func popViewController(withBlock popBlock: @escaping TransitionBlock) -> UIViewController? {
        if let transition = transition {
            return transition.pop(viewController: self, withBlock: popBlock)
        } else {
             return super.popViewController(animated: true)
        }
    }
}

extension TransitionNavigationController: Transition {

    var interactive: Bool {
        return transition?.interactive ?? false
    }
    
    func update(progress: Float) {
        transition?.update(progress: progress)
    }
    
    func complete() {
        transition?.complete()
    }
    
    func cancel() {
        transition?.cancel()
    }
}
