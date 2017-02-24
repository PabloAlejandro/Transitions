//
//  TransitionViewController.swift
//  Transitions
//
//  Created by Pau on 17/02/2017.
//  Copyright © 2017 Pau. All rights reserved.
//

import Foundation
import UIKit

class TransitionViewController: UIViewController {
    
    private(set) var transition: ViewTransition?
    
    var transitionConfiguration: TransitionConfiguration! {
        didSet {
            self.transition = GenericTransition(withViewController: self, configuration: transitionConfiguration)
        }
    }
    
    func present(_ viewControllerToPresent: UIViewController, presentBlock: @escaping TransitionBlock, completion: (() -> Void)? = nil) {
        if let transition = transition {
            transition.present(viewController: viewControllerToPresent, withBlock: presentBlock, completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: true, completion: completion)
        }
    }
    
    func dismiss(dismissBlock: @escaping TransitionBlock, completion: (() -> Void)? = nil) {
        if let transition = transition {
            transition.dismiss(viewController: self, withBlock: dismissBlock, completion: completion)
        } else {
            super.dismiss(animated: true, completion: completion)
        }
    }
}

extension TransitionViewController: Transition {
    
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
