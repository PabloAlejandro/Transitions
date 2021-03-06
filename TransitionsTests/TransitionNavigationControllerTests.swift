//
//  TransitionNavigationControllerTests.swift
//  Transitions
//
//  Created by Pau on 24/02/2017.
//  Copyright © 2017 pau-ios-developer. All rights reserved.
//

import XCTest
@testable import Transitions

class TransitionNavigationControllerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNotInteractive() {
        let viewController = TransitionNavigationControllerMock()
        let properties = TransitionProperties(duration: 0.5, modalPresentationStyle: .overFullScreen)
        let configuration = TransitionConfiguration.noninteractive(transitionProperties: properties)
        viewController.transitionConfiguration = configuration
        XCTAssertNotNil(viewController.transition, "Transition must be set")
        XCTAssertFalse(viewController.interactive, "viewController must not be interactive")
    }
    
    func testInteractive() {
        let viewController = TransitionNavigationControllerMock()
        let transitionProperties = TransitionProperties(duration: 0.5, modalPresentationStyle: .overFullScreen)
        let interactionProperties = InteractionProperties(interaction: .all)
        let configuration = TransitionConfiguration.interactive(transitionProperties: transitionProperties, interactionProperties: interactionProperties)
        viewController.transitionConfiguration = configuration
        XCTAssertNotNil(viewController.transition, "Transition must be set")
        XCTAssertTrue(viewController.interactive, "viewController must be interactive")
    }
    
    func testNoConfigurationRelease() {
        weak var vc: TransitionNavigationControllerMock?
        
        autoreleasepool {
            let viewController = TransitionNavigationControllerMock()
            vc = viewController
            XCTAssertNotNil(vc, "vc must be retained")
        }
        
        XCTAssertNil(vc, "vc must be released")
    }
    
    func testRelease() {
        weak var vc: TransitionNavigationControllerMock?
        
        autoreleasepool {
            let viewController = TransitionNavigationControllerMock()
            let properties = TransitionProperties(duration: 0.5, modalPresentationStyle: .overFullScreen)
            let configuration = TransitionConfiguration.noninteractive(transitionProperties: properties)
            viewController.transitionConfiguration = configuration
            vc = viewController
            XCTAssertNotNil(vc, "vc must be retained")
        }
        
        XCTAssertNil(vc, "vc must be released")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

class TransitionNavigationControllerMock: TransitionNavigationController {
    
}
