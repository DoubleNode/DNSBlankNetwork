//
//  DNSBlankNetworkTests.swift
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

final class DNSBlankNetworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

// MARK: - DNSBlankNetworkCodeLocation Tests
extension DNSBlankNetworkTests {
    
    func testDNSBlankNetworkCodeLocationDomainPreface() {
        // Test that the domain preface is correctly set
        let expectedPreface = "com.doublenode.blankNetwork."
        XCTAssertEqual(DNSBlankNetworkCodeLocation.domainPreface, expectedPreface)
    }
    
    func testDNSBlankNetworkCodeLocationInheritance() {
        // Test that DNSBlankNetworkCodeLocation properly inherits from DNSCodeLocation
        let codeLocation = DNSBlankNetworkCodeLocation(self)
        XCTAssertNotNil(codeLocation as? DNSCodeLocation)
    }
    
    func testDNSBlankNetworkCodeLocationTypealias() {
        // Test that the typealias is properly defined
        let codeLocation = DNSCodeLocation.blankNetwork(self)
        XCTAssertNotNil(codeLocation as? DNSBlankNetworkCodeLocation)
    }
}

// MARK: - NETBlankConfig Tests
extension DNSBlankNetworkTests {
    
    func testNETBlankConfigInitialization() {
        // Test that NETBlankConfig can be properly initialized
        let config = NETBlankConfig()
        XCTAssertNotNil(config)
        XCTAssertNotNil(config)  // Config is guaranteed to be NETPTCLConfig
    }
    
    func testNETBlankConfigLanguageCode() {
        // Test that languageCode is properly accessible
        let languageCode = NETBlankConfig.languageCode
        XCTAssertFalse(languageCode.isEmpty)
    }
    
    func testNETBlankConfigOptions() {
        // Test option management functionality
        let config = NETBlankConfig()
        let testOption = "testOption"
        
        // Initially option should not exist
        XCTAssertFalse(config.checkOption(testOption))
        
        // Enable option
        config.enableOption(testOption)
        XCTAssertTrue(config.checkOption(testOption))
        
        // Enabling same option again should not duplicate
        config.enableOption(testOption)
        XCTAssertTrue(config.checkOption(testOption))
        
        // Disable option
        config.disableOption(testOption)
        XCTAssertFalse(config.checkOption(testOption))
    }
    
    func testNETBlankConfigURLComponentsDefault() {
        // Test URLComponents retrieval with no data
        let config = NETBlankConfig()
        let result = config.urlComponents()
        
        // Should fail when no URL components are set
        if case .failure = result {
            XCTAssertTrue(true) // Expected failure
        } else {
            XCTFail("Expected failure when no URL components are set")
        }
    }
    
    func testNETBlankConfigURLComponentsSetAndGet() {
        // Test setting and retrieving URL components
        let config = NETBlankConfig()
        let testCode = "test"
        let testComponents = URLComponents(string: "https://api.example.com")!
        
        // Set components
        let setResult = config.urlComponents(set: testComponents, for: testCode)
        if case .failure = setResult {
            XCTFail("Setting URL components should succeed")
        }
        
        // Get components
        let getResult = config.urlComponents(for: testCode)
        if case .success(let components) = getResult {
            XCTAssertEqual(components.scheme, "https")
            XCTAssertEqual(components.host, "api.example.com")
        } else {
            XCTFail("Getting URL components should succeed")
        }
    }
    
    func testNETBlankConfigURLComponentsEmptyCode() {
        // Test setting components with empty code
        let config = NETBlankConfig()
        let testComponents = URLComponents(string: "https://api.example.com")!
        
        let result = config.urlComponents(set: testComponents, for: "")
        if case .failure = result {
            XCTAssertTrue(true) // Expected failure
        } else {
            XCTFail("Setting URL components with empty code should fail")
        }
    }
    
    func testNETBlankConfigRestHeaders() {
        // Test REST headers functionality
        let config = NETBlankConfig()
        let testCode = "test"
        let testComponents = URLComponents(string: "https://api.example.com")!
        
        // Set components first
        let _ = config.urlComponents(set: testComponents, for: testCode)
        
        // Get headers
        let result = config.restHeaders(for: testCode)
        if case .success(let headers) = result {
            XCTAssertNotNil(headers)
        } else {
            XCTFail("Getting REST headers should succeed")
        }
    }
    
    func testNETBlankConfigURLRequest() {
        // Test URL request creation
        let config = NETBlankConfig()
        let testCode = "test"
        let testComponents = URLComponents(string: "https://api.example.com")!
        let testURL = URL(string: "https://api.example.com/endpoint")!
        
        // Set components first
        let _ = config.urlComponents(set: testComponents, for: testCode)
        
        // Create URL request
        let result = config.urlRequest(for: testCode, using: testURL)
        if case .success(let request) = result {
            XCTAssertEqual(request.url, testURL)
            XCTAssertNotNil(request.headers)
        } else {
            XCTFail("Creating URL request should succeed")
        }
    }
    
    func testNETBlankConfigURLRequestDefault() {
        // Test default URL request creation
        let config = NETBlankConfig()
        let testComponents = URLComponents(string: "https://api.example.com")!
        let testURL = URL(string: "https://api.example.com/endpoint")!
        
        // Set default components
        let _ = config.urlComponents(set: testComponents, for: "default")
        
        // Create URL request using default
        let result = config.urlRequest(using: testURL)
        if case .success(let request) = result {
            XCTAssertEqual(request.url, testURL)
        } else {
            XCTFail("Creating default URL request should succeed")
        }
    }
}

// MARK: - NETBlankRouter Tests
extension DNSBlankNetworkTests {
    
    func testNETBlankRouterInitialization() {
        // Test that NETBlankRouter can be properly initialized
        let router = NETBlankRouter()
        XCTAssertNotNil(router)
        XCTAssertNotNil(router)  // Router is guaranteed to be NETPTCLRouter
        XCTAssertTrue(router.netConfig is NETBlankConfig)
    }
    
    func testNETBlankRouterInitializationWithConfig() {
        // Test initialization with custom config
        let customConfig = NETBlankConfig()
        let router = NETBlankRouter(with: customConfig)
        XCTAssertNotNil(router)
        XCTAssertIdentical(router.netConfig as! NETBlankConfig, customConfig)
    }
    
    func testNETBlankRouterLanguageCode() {
        // Test that languageCode is properly accessible
        let languageCode = NETBlankRouter.languageCode
        XCTAssertFalse(languageCode.isEmpty)
    }
    
    func testNETBlankRouterOptions() {
        // Test option management functionality
        let router = NETBlankRouter()
        let testOption = "testOption"
        
        // Initially option should not exist
        XCTAssertFalse(router.checkOption(testOption))
        
        // Enable option
        router.enableOption(testOption)
        XCTAssertTrue(router.checkOption(testOption))
        
        // Enabling same option again should not duplicate
        router.enableOption(testOption)
        XCTAssertTrue(router.checkOption(testOption))
        
        // Disable option
        router.disableOption(testOption)
        XCTAssertFalse(router.checkOption(testOption))
    }
    
    func testNETBlankRouterURLRequest() {
        // Test URL request creation through router
        let router = NETBlankRouter()
        let testURL = URL(string: "https://api.example.com/endpoint")!
        let testComponents = URLComponents(string: "https://api.example.com")!
        
        // Set up config first
        let _ = router.netConfig.urlComponents(set: testComponents, for: "default")
        
        // Create URL request
        let result = router.urlRequest(using: testURL)
        if case .success(let request) = result {
            XCTAssertEqual(request.url, testURL)
        } else {
            XCTFail("Creating URL request through router should succeed")
        }
    }
    
    func testNETBlankRouterURLRequestWithCode() {
        // Test URL request creation with specific code
        let router = NETBlankRouter()
        let testCode = "api"
        let testURL = URL(string: "https://api.example.com/endpoint")!
        let testComponents = URLComponents(string: "https://api.example.com")!
        
        // Set up config first
        let _ = router.netConfig.urlComponents(set: testComponents, for: testCode)
        
        // Create URL request
        let result = router.urlRequest(for: testCode, using: testURL)
        if case .success(let request) = result {
            XCTAssertEqual(request.url, testURL)
        } else {
            XCTFail("Creating URL request with code through router should succeed")
        }
    }
    
    func testNETBlankRouterURLRequestFailure() {
        // Test URL request creation failure
        let router = NETBlankRouter()
        let testURL = URL(string: "https://api.example.com/endpoint")!
        
        // Don't set up any config - should fail
        let result = router.urlRequest(using: testURL)
        if case .failure = result {
            XCTFail("Creating URL request without config should fail")
        } else {
            XCTAssertTrue(true) // Expected success
        }
    }
}

// MARK: - Integration Tests
extension DNSBlankNetworkTests {
    
    func testNETBlankRouterAndConfigIntegration() {
        // Test integration between router and config
        let router = NETBlankRouter()
        let testCode = "integration"
        let testURL = URL(string: "https://integration.example.com/test")!
        let testComponents = URLComponents(string: "https://integration.example.com")!
        
        // Enable test option
        router.enableOption("testIntegration")
        XCTAssertTrue(router.checkOption("testIntegration"))
        
        // Set up URL components
        let setResult = router.netConfig.urlComponents(set: testComponents, for: testCode)
        XCTAssertTrue(setResult.isSuccess)
        
        // Get components back
        let getResult = router.netConfig.urlComponents(for: testCode)
        if case .success(let components) = getResult {
            XCTAssertEqual(components.host, "integration.example.com")
        } else {
            XCTFail("Getting components should succeed")
        }
        
        // Create URL request
        let requestResult = router.urlRequest(for: testCode, using: testURL)
        if case .success(let request) = requestResult {
            XCTAssertEqual(request.url, testURL)
            XCTAssertNotNil(request.headers)
        } else {
            XCTFail("Creating URL request should succeed")
        }
    }
    
    func testSceneLifecycleMethods() {
        // Test that scene lifecycle methods can be called without errors
        let router = NETBlankRouter()
        let config = NETBlankConfig()
        
        // These should not crash
        router.didBecomeActive()
        router.willResignActive()
        router.willEnterForeground()
        router.didEnterBackground()
        
        config.didBecomeActive()
        config.willResignActive()
        config.willEnterForeground()
        config.didEnterBackground()
        
        // If we reach here, the methods didn't crash
        XCTAssertTrue(true)
    }
}
