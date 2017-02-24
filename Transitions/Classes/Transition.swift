//
//  Transition.swift
//  Garage
//
//  Created by Pau on 16/12/2016.
//  Copyright © 2016 Pau. All rights reserved.
//

import UIKit

public typealias TransitionBlock = (_ transitionContext: UIViewControllerContextTransitioning, _ duration: TimeInterval)->(Void)

/**
 * Enum with transition type (interactive/non interactive)
 */
public enum TransitionConfiguration {
    case noninteractive(transitionProperties: TransitionProperties)
    case interactive(transitionProperties: TransitionProperties, interactionProperties: InteractionProperties)
}

/**
 * Struct with properties for any transition
 * @property duration: transition duration for present/dismiss
 * @property modalPresentationStyle: view controller's presentation style
 */
public struct TransitionProperties {
    // Duration for the transition
    public let duration: TimeInterval
    public let modalPresentationStyle: UIModalPresentationStyle
    public init(duration: TimeInterval, modalPresentationStyle: UIModalPresentationStyle) {
        self.duration = duration
        self.modalPresentationStyle = modalPresentationStyle
    }
}

/**
 * Enum with allowed interaction types for interactive transition
 */
public enum InteractionType {
    case present, dismiss, all, none
}

/**
 * Struct with properties for interactive transition
 * @property interaction: allowed interaction types
 */
public struct InteractionProperties {
    // Sets the interaction interactive for different actions
    public let interaction: InteractionType
    public init(interaction: InteractionType) {
        self.interaction = interaction
    }
}

/**
 * Main Transition protocol
 * @property interactive: either the transition is interactive or not
 * @method update(progress:): update interactive transition
 * @method complete(): complete interactive transition
 * @method cancel(): cancel interactive transition
 */
protocol Transition {
    
    // Properties
    var interactive: Bool { get }
    
    // Methods
    func update(progress: Float)
    func complete()
    func cancel()
}

/**
 * Transition protocol for view controller presenting a new view controller
 * @method present(viewController:withBlock:completion:): present new view 
 * controller from parent view controller
 * @method dismiss(withBlock:completion:): dismiss current child view controller
 */
protocol ViewTransition: Transition {
    
    // Custom initializer with view controller
    init(withViewController: UIViewController, configuration: TransitionConfiguration)
    
    // Present view controller from another view controller
    func present(viewController: UIViewController, withBlock: @escaping TransitionBlock, completion: (() -> Void)?)
    
    // Dismiss controller with transition
    func dismiss(viewController: UIViewController, withBlock: @escaping TransitionBlock, completion: (() -> Void)?)
}

/**
 * Transition protocol for navigation controller presenting a new view controller
 * @method push(viewController:withBlock:): push new view controller inside
 * parent navigation controller
 * @method pop(viewController:withBlock:): pop current child view controller
 * @property navigationControllerDelegate: forwards UINavigationControllerDelegate's 
 * calls to any object that requires them, instead of setting the navigation
 * controller's delegate.
 */
protocol NavigationTransition: Transition {
    
    // Custom initializer with navigation view controller
    init(withNavigationController: UINavigationController, configuration: TransitionConfiguration)
    
    // Push view controller on navigation controller
    func push(viewController: UIViewController, withBlock presentBlock: @escaping TransitionBlock)
    
    // Pop controller with transition
    func pop(viewController: UIViewController, withBlock dismissBlock: @escaping TransitionBlock) -> UIViewController?
    
    // Get calls from UINavigationControllerDelegate
    weak var navigationControllerDelegate: UINavigationControllerDelegate? { get set }
    // NOTE: Do not try to set the delegate of the UINavigationController, 
    // use `navigationControllerDelegate` instead.
}

/**
 * Transition protocol for view controller presenting a new view controller
 * @method push(viewController:withBlock:): push new view controller inside
 * parent navigation controller
 * @method pop(withBlock:): pop current child view controller
 * @property navigationControllerDelegate: forwards UINavigationControllerDelegate's
 * calls to any object that requires them, instead of setting the navigation
 * controller's delegate.
 */
protocol TabBarTransition: Transition {
    
    // Custom initializer with navigation view controller
    init(withTabBarController: UITabBarController, configuration: TransitionConfiguration)
    
    // Push view controller on navigation controller
    func select(viewController: UIViewController, withBlock showBlock: @escaping TransitionBlock)
    
    // Get calls from UINavigationControllerDelegate
    weak var tabBarDelegate: UITabBarControllerDelegate? { get set }
    // NOTE: Do not try to set the delegate of the UITabBarController,
    // use `tabBarDelegate` instead.
}
