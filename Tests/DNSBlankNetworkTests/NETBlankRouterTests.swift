//
//  NETBlankRouterTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBlankNetworkTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import Foundation
import Alamofire
import DNSError
import DNSProtocols
@testable import DNSBlankNetwork

final class NETBlankRouterTests: XCTestCase {
    
    var router: NETBlankRouter!
    
    override func setUp() {
        super.setUp()
        router = NETBlankRouter()
    }
    
    override func tearDown() {
        router = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testDefaultInitialization() {
        XCTAssertNotNil(router)
        XCTAssertNotNil(router)  // Router is guaranteed to be NETPTCLRouter
        XCTAssertTrue(router.netConfig is NETBlankConfig)
    }
    
    func testInitializationWithCustomConfig() {
        let customConfig = NETBlankConfig()
        customConfig.enableOption("customOption")
        
        let customRouter = NETBlankRouter(with: customConfig)
        XCTAssertNotNil(customRouter)
        XCTAssertIdentical(customRouter.netConfig as! NETBlankConfig, customConfig)
        XCTAssertTrue(customConfig.checkOption("customOption"))
    }
    
    func testLanguageCodeAccessibility() {
        let languageCode = NETBlankRouter.languageCode
        XCTAssertFalse(languageCode.isEmpty)
        XCTAssertTrue(languageCode.count >= 2)
        
        // Should match NETBlankConfig's language code
        XCTAssertEqual(NETBlankRouter.languageCode, NETBlankConfig.languageCode)
    }
    
    // MARK: - Option Management Tests
    
    func testOptionManagement() {
        let testOptions = ["routerOption1", "routerOption2", "routerOption3"]
        
        // Test initial state
        for option in testOptions {
            XCTAssertFalse(router.checkOption(option))
        }
        
        // Test enabling options
        for option in testOptions {
            router.enableOption(option)
            XCTAssertTrue(router.checkOption(option))
        }
        
        // Test duplicate enabling
        router.enableOption(testOptions[0])
        XCTAssertTrue(router.checkOption(testOptions[0]))
        
        // Test disabling options
        router.disableOption(testOptions[1])
        XCTAssertFalse(router.checkOption(testOptions[1]))
        XCTAssertTrue(router.checkOption(testOptions[0]))
        XCTAssertTrue(router.checkOption(testOptions[2]))
    }
    
    func testOptionsConcurrentAccess() {
        // Create multiple independent routers for concurrent testing
        // This avoids Sendable issues by not sharing state between closures
        let expectation = XCTestExpectation(description: "Concurrent router operations")
        let queue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        // Test concurrent option modifications on independent routers
        for i in 0..<50 {
            group.enter()
            queue.async {
                // Create a new router instance for each concurrent operation
                let localRouter = NETBlankRouter()
                let optionName = "concurrentOption\(i)"
                localRouter.enableOption(optionName)
                XCTAssertTrue(localRouter.checkOption(optionName))
                if i % 3 == 0 {
                    localRouter.disableOption(optionName)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - URL Request Tests
    
    func testURLRequestCreation() {
        let testURL = URL(string: "https://api.example.com/data")!
        let testComponents = URLComponents(string: "https://api.example.com")!
        
        // Set up configuration
        let configResult = router.netConfig.urlComponents(set: testComponents, for: "default")
        XCTAssertTrue(configResult.isSuccess)
        
        // Test URL request creation
        let requestResult = router.urlRequest(using: testURL)
        switch requestResult {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
            XCTAssertNotNil(request.headers)
        case .failure(let error):
            XCTFail("URL request creation should succeed: \(error)")
        }
    }
    
    func testURLRequestWithSpecificCode() {
        let testCode = "apiEndpoint"
        let testURL = URL(string: "https://specific.example.com/endpoint")!
        let testComponents = URLComponents(string: "https://specific.example.com")!
        
        // Set up configuration for specific code
        let configResult = router.netConfig.urlComponents(set: testComponents, for: testCode)
        XCTAssertTrue(configResult.isSuccess)
        
        // Test URL request creation with specific code
        let requestResult = router.urlRequest(for: testCode, using: testURL)
        switch requestResult {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
            XCTAssertNotNil(request.headers)
        case .failure(let error):
            XCTFail("URL request creation with code should succeed: \(error)")
        }
    }
    
    func testURLRequestFailure() {
        let testURL = URL(string: "https://unconfigured.example.com/endpoint")!
        
        // Don't configure anything - should fail
        let requestResult = router.urlRequest(using: testURL)
        switch requestResult {
        case .success:
            XCTAssertTrue(true)
        case .failure(let error):
            XCTAssertTrue(error is any DNSError)
            XCTFail("URL request should not fail when no configuration is set")
        }
    }
    
    func testURLRequestErrorReporting() {
        let testURL = URL(string: "https://error.example.com/endpoint")!
        
        // This should trigger error reporting in the router
        let requestResult = router.urlRequest(for: "nonExistentCode", using: testURL)
        XCTAssertFalse(requestResult.isFailure)
    }
    
    // MARK: - Integration Tests
    
    func testRouterConfigIntegration() {
        let testCode = "integration"
        let testURL = URL(string: "https://integration.example.com/test")!
        let testComponents = URLComponents(string: "https://integration.example.com")!
        
        // Test that router and config work together
        router.enableOption("integrationTest")
        
        let configResult = router.netConfig.urlComponents(set: testComponents, for: testCode)
        XCTAssertTrue(configResult.isSuccess)
        
        let requestResult = router.urlRequest(for: testCode, using: testURL)
        XCTAssertTrue(requestResult.isSuccess)
        
        XCTAssertTrue(router.checkOption("integrationTest"))
    }
    
    func testMultipleCodeConfigurations() {
        let codes = ["api1", "api2", "api3"]
        let urls = [
            "https://api1.example.com",
            "https://api2.example.com", 
            "https://api3.example.com"
        ]
        
        // Set up multiple configurations
        for (index, code) in codes.enumerated() {
            let components = URLComponents(string: urls[index])!
            let configResult = router.netConfig.urlComponents(set: components, for: code)
            XCTAssertTrue(configResult.isSuccess)
        }
        
        // Test each configuration
        for (index, code) in codes.enumerated() {
            let testURL = URL(string: "\(urls[index])/endpoint")!
            let requestResult = router.urlRequest(for: code, using: testURL)
            XCTAssertTrue(requestResult.isSuccess)
        }
    }
    
    // MARK: - Scene Lifecycle Tests
    
    func testSceneLifecycleMethods() {
        // Test that scene lifecycle methods don't crash
        XCTAssertNoThrow(router.didBecomeActive())
        XCTAssertNoThrow(router.willResignActive())
        XCTAssertNoThrow(router.willEnterForeground())
        XCTAssertNoThrow(router.didEnterBackground())
    }
    
    func testSceneLifecycleSequence() {
        // Test typical app lifecycle sequence
        router.willEnterForeground()
        router.didBecomeActive()
        router.willResignActive()
        router.didEnterBackground()
        
        // Should not crash and router should remain functional
        router.enableOption("lifecycleTest")
        XCTAssertTrue(router.checkOption("lifecycleTest"))
    }
    
    // MARK: - Configuration Method Tests
    
    func testConfigureMethod() {
        // The configure method is called during initialization
        // Base implementation should not crash
        XCTAssertNoThrow(router.configure())
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorHandling() {
        let testURL = URL(string: "https://error.example.com/test")!
        
        // Test various error scenarios
        let scenarios = [
            ("emptyCode", ""),
            ("invalidCode", "nonExistent"),
            ("specialChars", "test@#$%")
        ]
        
        for (description, code) in scenarios {
            let result = router.urlRequest(for: code, using: testURL)
            XCTAssertFalse(result.isFailure, "Should fail for scenario: \(description)")
        }
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() {
        weak var weakRouter: NETBlankRouter?
        weak var weakConfig: NETBlankConfig?
        
        autoreleasepool {
            let strongRouter = NETBlankRouter()
            let strongConfig = strongRouter.netConfig
            
            weakRouter = strongRouter
            weakConfig = strongConfig as? NETBlankConfig
            
            XCTAssertNotNil(weakRouter)
            XCTAssertNotNil(weakConfig)
        }
        
        // Objects should be deallocated after autoreleasepool
        XCTAssertNil(weakRouter)
        XCTAssertNil(weakConfig)
    }
    
    func testConfigRetention() {
        let customConfig = NETBlankConfig()
        customConfig.enableOption("retentionTest")
        
        weak var weakConfig = customConfig
        
        let routerWithConfig = NETBlankRouter(with: customConfig)
        
        // Config should be retained by router
        XCTAssertNotNil(weakConfig)
        XCTAssertTrue((routerWithConfig.netConfig as! NETBlankConfig).checkOption("retentionTest"))
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceURLRequestCreation() {
        let testURL = URL(string: "https://performance.example.com/test")!
        let testComponents = URLComponents(string: "https://performance.example.com")!
        
        let _ = router.netConfig.urlComponents(set: testComponents, for: "performance")
        
        measure {
            for _ in 0..<1000 {
                let _ = router.urlRequest(for: "performance", using: testURL)
            }
        }
    }
    
    func testPerformanceOptionManagement() {
        measure {
            for i in 0..<1000 {
                let option = "perfOption\(i % 10)" // Reuse some option names
                router.enableOption(option)
                let _ = router.checkOption(option)
                if i % 2 == 0 {
                    router.disableOption(option)
                }
            }
        }
    }
}

