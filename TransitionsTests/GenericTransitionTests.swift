//
//  GenericTransition.swift
//  TransitionTests
//
//  Created by Pau on 24/02/2017.
//  Copyright © 2017 pau-ios-developer. All rights reserved.
//

import XCTest
@testable import Transitions

class GenericTransitionTests: XCTestCase {
    
    weak var transition: GenericTransition?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewController() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let viewController: UIViewController = UIViewController()
        let properties = TransitionProperties(duration: 0.5, modalPresentationStyle: .overFullScreen)
        let configuration = TransitionConfiguration.noninteractive(transitionProperties: properties)
        
        autoreleasepool {
            let strongTransition = GenericTransition(withViewController: viewController, configuration: configuration)
            transition = strongTransition
            XCTAssertNotNil(transition, "transition must be retained")
        }
        
        XCTAssertNil(transition, "transition must be released")
    }
    
    func testWeakViewController() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        weak var viewController: UIViewController?
        var strongTransition: GenericTransition!
        
        autoreleasepool {
            let strongVC = UIViewController()
            viewController = strongVC
            XCTAssertNotNil(viewController, "viewController must be retained")
            let properties = TransitionProperties(duration: 0.5, modalPresentationStyle: .overFullScreen)
            let configuration = TransitionConfiguration.noninteractive(transitionProperties: properties)
            strongTransition = GenericTransition(withViewController: viewController!, configuration: configuration)
        }
        
        XCTAssertNil(viewController, "viewController must be released")
        XCTAssertNotNil(strongTransition, "strongTransition must be retained")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
