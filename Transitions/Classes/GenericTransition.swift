//
//  GenericTransition.swift
//  Garage
//
//  Created by Pau on 09/12/2016.
//  Copyright © 2016 Pau. All rights reserved.
//

import UIKit

private let defaultCompletionSpeed = 0.99

enum PresentationBaseType: Equatable {
    case view(viewController: UIViewController)
    case navigation(navigationController: UINavigationController)
    case tab(tabBarController: UITabBarController)
    // TODO: Add more possible transitions
    static func ==(lhs: PresentationBaseType, rhs: PresentationBaseType) -> Bool {
        switch (lhs, rhs) {
        case (.view(let valueA), .view(let valueB)): return valueA == valueB
        case (.navigation(let valueA), .navigation(let valueB)): return valueA == valueB
        default: return false
        }
    }
}

class GenericTransition: NSObject, Transition {
    
    // MARK - Private
    
    // Base file to present/dismiss, push/pop, etc.
    fileprivate let presentationBaseType: PresentationBaseType
    // Child view controller (the one presented/dismissed/pushed/...)
    fileprivate var child: UIViewController!
    // Configuration
    fileprivate var configuration: TransitionConfiguration
    // Block with presenting animation
    fileprivate var presentBlock: TransitionBlock?
    // Block with dismissing animation
    fileprivate var dismissBlock: TransitionBlock?
    // Private object for interactive transition
    fileprivate let interactiveTransition: UIPercentDrivenInteractiveTransition
    // Value for interactive transition to decide when the transition is completed
    private let completionSpeed = defaultCompletionSpeed
    // Either the transition is interactive or not
    var interactive: Bool {
        switch configuration {
        case .interactive(transitionProperties: _, interactionProperties: _):
            return true
        default:
            return false
        }
    }
    // Either is pushing or not
    fileprivate var isPushing: Bool = false
    
    // Forward UINavigationControllerDelegate calls
    weak var navigationControllerDelegate: UINavigationControllerDelegate?
    
    // Forward UITabBarDelegate calls
    weak var tabBarDelegate: UITabBarControllerDelegate?
    
    // MARK - Init
    
    required init(withViewController viewController: UIViewController, configuration: TransitionConfiguration) {
        self.configuration = configuration
        self.interactiveTransition = UIPercentDrivenInteractiveTransition()
        self.interactiveTransition.completionSpeed = CGFloat(completionSpeed)
        self.presentationBaseType = PresentationBaseType.view(viewController: viewController)
        super.init()
    }
    
    required init(withNavigationController navigationController: UINavigationController, configuration: TransitionConfiguration) {
        self.configuration = configuration
        self.interactiveTransition = UIPercentDrivenInteractiveTransition()
        self.interactiveTransition.completionSpeed = CGFloat(completionSpeed)
        self.presentationBaseType = PresentationBaseType.navigation(navigationController: navigationController)
        super.init()
        navigationController.delegate = self
    }
    
    required init(withTabBarController tabBarController: UITabBarController, configuration: TransitionConfiguration) {
        self.configuration = configuration
        self.interactiveTransition = UIPercentDrivenInteractiveTransition()
        self.interactiveTransition.completionSpeed = CGFloat(completionSpeed)
        self.presentationBaseType = PresentationBaseType.tab(tabBarController: tabBarController)
        super.init()
        tabBarController.delegate = self
    }
    
    fileprivate func wireTo(viewController: UIViewController) {
        self.child = viewController
        self.child.transitioningDelegate = self
        switch configuration {
        case .interactive(let transitionProperties, _):
            self.child.modalPresentationStyle = transitionProperties.modalPresentationStyle
        case .noninteractive(let transitionProperties):
            self.child.modalPresentationStyle = transitionProperties.modalPresentationStyle
        }
    }
    
    fileprivate func currentViewController() -> UIViewController {
        switch presentationBaseType {
        case .view(let vc): return vc
        case .navigation(let nv): return nv
        case .tab(let tab): return tab
        }
    }
}

// MARK - Interaction methods

extension GenericTransition {
    
    func update(progress: Float) {
        interactiveTransition.update(CGFloat(progress))
    }
    
    func complete() {
        interactiveTransition.finish()
    }
    
    func cancel() {
        interactiveTransition.cancel()
    }
}

// MARK: ViewTransition

extension GenericTransition: ViewTransition {

    func present(viewController vc: UIViewController, withBlock presentBlock: @escaping TransitionBlock, completion: (() -> Void)? = nil) {
        // Set present block
        self.presentBlock = presentBlock
        // Any subclass of UIViewController can present a new view controller
        let viewController: UIViewController = currentViewController()
        // Wire child view controller and set delegates
        wireTo(viewController: vc)
        // Present child view controller
        viewController.present(vc, animated: true, completion: completion)
    }
    
    func dismiss(viewController vc: UIViewController, withBlock dismissBlock: @escaping TransitionBlock, completion: (() -> Void)? = nil) {
        // Set dismiss block
        self.dismissBlock = dismissBlock
        // Wire child view controller and set delegates
        wireTo(viewController: vc)
        // Dismiss child view controller
        child.dismiss(animated: true, completion: completion)
    }
}

// MARK: NavigationTransition

extension GenericTransition: NavigationTransition {
    
    func push(viewController: UIViewController, withBlock presentBlock: @escaping TransitionBlock) {
        guard case .navigation(let navigationController) = presentationBaseType else { return }
        // Set present block
        self.presentBlock = presentBlock
        // Set child
        self.child = viewController
        // Set pushing property to true
        self.isPushing = true
        // Get ownership of navigation controller's delegate
//        navigationController.delegate = self
        // Push child into navigation controller
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pop(viewController: UIViewController, withBlock dismissBlock: @escaping TransitionBlock) -> UIViewController? {
        guard case .navigation(let navigationController) = presentationBaseType else { return nil }
        // Set dismiss block
        self.dismissBlock = dismissBlock
        // Set child
        self.child = viewController
        // Set pushing property to false
        self.isPushing = false
        // Get ownership of navigation controller's delegate
//        navigationController.delegate = self
        // Pop navigation controller
        return navigationController.popViewController(animated: true)
    }
}

// MARK: TabBarTransition

extension GenericTransition: TabBarTransition {
    
    func select(viewController: UIViewController, withBlock showBlock: @escaping TransitionBlock) {
        guard case .tab(let tabBarController) = presentationBaseType else { return }
        // Set present block
        self.presentBlock = showBlock
        // Set pushing property to true
        self.isPushing = true
        // Wire child view controller and set delegates
        wireTo(viewController: viewController)
        // Present child view controller
        tabBarController.selectedViewController = viewController
    }
}

// MARK: UITabBarControllerDelegate

extension GenericTransition: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        switch configuration {
        case .interactive(_, let interactionProperties):
            switch interactionProperties.interaction {
            case .all:
                return (isPushing && presentBlock != nil) || (!isPushing && dismissBlock != nil) ? interactiveTransition : nil
            case .present:
                return (isPushing && presentBlock != nil) ? interactiveTransition : nil
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentBlock != nil ? self : nil
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return tabBarDelegate?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tabBarDelegate?.tabBarController?(tabBarController, didSelect: viewController)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        tabBarDelegate?.tabBarController?(tabBarController, willBeginCustomizing: viewControllers)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        tabBarDelegate?.tabBarController?(tabBarController, willBeginCustomizing: viewControllers)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        tabBarDelegate?.tabBarController?(tabBarController, didEndCustomizing: viewControllers, changed: changed)
    }
    
    func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return tabBarDelegate?.tabBarControllerSupportedInterfaceOrientations?(tabBarController) ?? .all
    }
    
    func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
        return tabBarDelegate?.tabBarControllerPreferredInterfaceOrientationForPresentation?(tabBarController) ?? .unknown
    }
}

// MARK: UINavigationControllerDelegate

extension GenericTransition: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        guard let viewController = navigationController.childViewControllers.last else { return nil }
//        self.child = viewController
//        self.isPushing = !viewController.isViewLoaded
        switch configuration {
        case .interactive(_, let interactionProperties):
            switch interactionProperties.interaction {
            case .all:
                return (isPushing && presentBlock != nil) || (!isPushing && dismissBlock != nil) ? interactiveTransition : nil
            case .present:
                return (isPushing && presentBlock != nil) ? interactiveTransition : nil
            case .dismiss:
                return (!isPushing && dismissBlock != nil) ? interactiveTransition : nil
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return presentBlock != nil ? self : nil
        case .pop:
            return dismissBlock != nil ? self : nil
        default:
            return nil
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationControllerDelegate?.navigationController!(navigationController, willShow: viewController, animated: animated)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationControllerDelegate?.navigationController!(navigationController, didShow: viewController, animated: animated)
    }
    
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return navigationControllerDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? navigationController.supportedInterfaceOrientations
    }
    
    func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return navigationControllerDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? navigationController.preferredInterfaceOrientationForPresentation
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension GenericTransition: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentBlock != nil ? self : nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissBlock != nil ? self : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        switch configuration {
        case .interactive(_, let interactionProperties):
            switch interactionProperties.interaction {
            case .all:
                return presentBlock != nil ? interactiveTransition : nil
            case .present:
                return presentBlock != nil ? interactiveTransition : nil
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        switch configuration {
        case .interactive(_, let interactionProperties):
            switch interactionProperties.interaction {
            case .all:
                return dismissBlock != nil ? interactiveTransition : nil
            case .dismiss:
                return dismissBlock != nil ? interactiveTransition : nil
            default:
                return nil
            }
        default:
            return nil
        }
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension GenericTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch configuration {
        case.noninteractive(let transitionProperties):
            return transitionProperties.duration
        case .interactive(let transitionProperties, _):
            return transitionProperties.duration
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if child.isBeingPresented {
            presentBlock?(transitionContext, transitionDuration(using: transitionContext))
        } else if child.isBeingDismissed {
            dismissBlock?(transitionContext, transitionDuration(using: transitionContext))
        } else if isPushing {
            presentBlock?(transitionContext, transitionDuration(using: transitionContext))
        } else {
            dismissBlock?(transitionContext, transitionDuration(using: transitionContext))
        }
    }
}
