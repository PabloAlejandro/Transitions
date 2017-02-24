# Transitions
Transitions library provides an easy way to present different view controllers with a transition animation, which may be interactive, by just subclassing your view controller.

## Usage

Firstly you need to import the library in the view controller you want to subclass by adding `import Transitions`.

Then, just subclass by using the right view controller object:
- `TransitionViewController`
- `TransitionNavigationController`
- `TransitionTabBarController`

When initialising your subclass, initialise its `transitionConfiguration` property:
``` yaml
let properties = TransitionProperties(duration: 0.5, modalPresentationStyle: .overFullScreen)
let configuration = TransitionConfiguration.noninteractive(transitionProperties: properties)
self.transitionConfiguration = configuration
```

And finally, use the public method in your subclass in order to present or dismiss a new view controller with a custom animation, by just defining a block wit the animation:

``` yaml
let vc = UIViewcontroller()
let presentBlock = { (transitionContext: UIViewControllerContextTransitioning, duration: TimeInterval) in
    let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
    let containerView = transitionContext.containerView
    toViewController.view.alpha = 0.0
    containerView.addSubview(toViewController.view)
    UIView.animate(withDuration: duration, animations: {
        toViewController.view.alpha = 1.0
    }, completion: { finished in
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    })
}
self.present(vc, presentBlock: presentBlock)
```

## Versions
### v 0.1.5
Unit Tests added
### v 0.1.4
Podspecs and documentation updated.
### v 0.1.3
First version which contains three `UIViewController` subclasses supporting interactive transitions.

## Files

### Controllers
- `TransitionViewController` -> `UIViewController` subclass which allows present/dismiss interactive transitions by using an instance method.
- `TransitionNavigationController` ->`UINavigationController` subclass which allows push/pop interactive transitions by using an instance method. 
- `TransitionTabBarController` -> `UITabBarController` subclass which allows select interactive transitions by using an instance method.

### Classes
- `Transition` -> Protocol and objects declarations.
- `GenericTransition` -> Main manager implementing Transition protocols.
