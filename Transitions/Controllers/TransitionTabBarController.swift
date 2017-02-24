//
//  TransitionTabBarController.swift
//  Sample-Transitions
//
//  Created by Pau on 20/02/2017.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation
import UIKit

class TransitionTabBarController: UITabBarController {

    private(set) var transition: TabBarTransition?
    
    var transitionConfiguration: TransitionConfiguration! {
        didSet {
            self.transition = GenericTransition(withTabBarController: self, configuration: transitionConfiguration)
        }
    }
    
    func select(_ vc: UIViewController, withBlock showBlock: @escaping TransitionBlock, sender: Any?) {
        if let transition = transition {
            transition.select(viewController: vc, withBlock: showBlock)
        } else {
            selectedViewController = vc
        }
    }
    
    func select(index: Int, withBlock showBlock: @escaping TransitionBlock, sender: Any?) {
        self.select(childViewControllers[index], withBlock: showBlock, sender: sender)
    }
}

extension TransitionTabBarController: Transition {
    
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

