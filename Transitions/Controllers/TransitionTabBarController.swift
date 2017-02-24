//
//  TransitionTabBarController.swift
//  Sample-Transitions
//
//  Created by Pau on 20/02/2017.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation
import UIKit

open class TransitionTabBarController: UITabBarController {

    fileprivate var transition: TabBarTransition?
    
    public var transitionConfiguration: TransitionConfiguration! {
        didSet {
            self.transition = GenericTransition(withTabBarController: self, configuration: transitionConfiguration)
        }
    }
    
    public func select(_ vc: UIViewController, withBlock showBlock: @escaping TransitionBlock, sender: Any?) {
        if let transition = transition {
            transition.select(viewController: vc, withBlock: showBlock)
        } else {
            selectedViewController = vc
        }
    }
    
    public func select(index: Int, withBlock showBlock: @escaping TransitionBlock, sender: Any?) {
        self.select(childViewControllers[index], withBlock: showBlock, sender: sender)
    }
}

extension TransitionTabBarController: Transition {
    
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

