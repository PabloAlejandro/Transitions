//
//  TransitionViewController.swift
//  Transitions
//
//  Created by Pau on 17/02/2017.
//  Copyright © 2017 Pau. All rights reserved.
//

import Foundation
import UIKit

open class TransitionViewController: UIViewController {
    
    fileprivate var transition: ViewTransition?
    
    public var transitionConfiguration: TransitionConfiguration! {
        didSet {
            self.transition = GenericTransition(withViewController: self, configuration: transitionConfiguration)
        }
    }
    
    public func present(_ viewControllerToPresent: UIViewController, presentBlock: @escaping TransitionBlock, completion: (() -> Void)? = nil) {
        if let transition = transition {
            transition.present(viewController: viewControllerToPresent, withBlock: presentBlock, completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: true, completion: completion)
        }
    }
    
    public func dismiss(dismissBlock: @escaping TransitionBlock, completion: (() -> Void)? = nil) {
        if let transition = transition {
            transition.dismiss(viewController: self, withBlock: dismissBlock, completion: completion)
        } else {
            super.dismiss(animated: true, completion: completion)
        }
    }
}

extension TransitionViewController: Transition {
    
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
