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

open class TransitionNavigationController: UINavigationController {

    fileprivate var transition: NavigationTransition?
    
    public var transitionConfiguration: TransitionConfiguration! {
        didSet {
            self.transition = GenericTransition(withNavigationController: self, configuration: transitionConfiguration)
        }
    }
    
    // MARK: Custom transition methods
    
    public func pushViewController(_ viewController: UIViewController, withBlock pushBlock: @escaping TransitionBlock) {
        if let transition = transition {
            transition.push(viewController: viewController, withBlock: pushBlock)
        } else {
            super.pushViewController(viewController, animated: true)
        }
    }
    
    public func popViewController(withBlock popBlock: @escaping TransitionBlock) -> UIViewController? {
        if let transition = transition {
            return transition.pop(viewController: self, withBlock: popBlock)
        } else {
             return super.popViewController(animated: true)
        }
    }
}

extension TransitionNavigationController: Transition {

    public var interactive: Bool {
        return transition?.interactive ?? false
    }
    
    public func update(progress: Float) {
        transition?.update(progress: progress)
    }
    
    public func complete() {
        transition?.complete()
    }
    
    public func cancel() {
        transition?.cancel()
    }
}
