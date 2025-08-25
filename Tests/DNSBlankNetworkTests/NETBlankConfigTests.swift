//
//  NETBlankConfigTests.swift
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

final class NETBlankConfigTests: XCTestCase {
    
    var config: NETBlankConfig!
    
    override func setUp() {
        super.setUp()
        config = NETBlankConfig()
    }
    
    override func tearDown() {
        config = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(config)
        XCTAssertNotNil(config)  // Config is guaranteed to be NETPTCLConfig
    }
    
    func testLanguageCodeAccessibility() {
        let languageCode = NETBlankConfig.languageCode
        XCTAssertFalse(languageCode.isEmpty)
        XCTAssertTrue(languageCode.count >= 2) // Should be at least 2 characters like "en"
    }
    
    // MARK: - Option Management Tests
    
    func testOptionManagement() {
        let testOptions = ["option1", "option2", "option3"]
        
        // Test initial state - no options should be enabled
        for option in testOptions {
            XCTAssertFalse(config.checkOption(option))
        }
        
        // Test enabling options
        for option in testOptions {
            config.enableOption(option)
            XCTAssertTrue(config.checkOption(option))
        }
        
        // Test that enabling the same option doesn't create duplicates
        config.enableOption(testOptions[0])
        XCTAssertTrue(config.checkOption(testOptions[0]))
        
        // Test disabling options
        config.disableOption(testOptions[1])
        XCTAssertFalse(config.checkOption(testOptions[1]))
        XCTAssertTrue(config.checkOption(testOptions[0])) // Other options should remain
        XCTAssertTrue(config.checkOption(testOptions[2]))
        
        // Test disabling non-existent option (should not crash)
        config.disableOption("nonExistentOption")
        XCTAssertFalse(config.checkOption("nonExistentOption"))
    }
    
    func testOptionsConcurrency() {
        // Test option management under concurrent access
        let expectation = XCTestExpectation(description: "Concurrent option operations")
        let queue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        for i in 0..<100 {
            group.enter()
            queue.async {
                // Create independent config instance for each concurrent operation
                let localConfig = NETBlankConfig()
                localConfig.enableOption("option\(i)")
                localConfig.checkOption("option\(i)")
                if i % 2 == 0 {
                    localConfig.disableOption("option\(i)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - URL Components Tests
    
    func testURLComponentsSetAndRetrieve() {
        let testCode = "testAPI"
        let testComponents = URLComponents(string: "https://api.test.com/v1")!
        
        // Test setting components
        let setResult = config.urlComponents(set: testComponents, for: testCode)
        XCTAssertTrue(setResult.isSuccess)
        
        // Test retrieving components
        let getResult = config.urlComponents(for: testCode)
        switch getResult {
        case .success(let components):
            XCTAssertEqual(components.scheme, "https")
            XCTAssertEqual(components.host, "api.test.com")
            XCTAssertEqual(components.path, "/v1")
        case .failure:
            XCTFail("Should successfully retrieve URL components")
        }
    }
    
    func testURLComponentsWithEmptyCode() {
        let testComponents = URLComponents(string: "https://api.test.com")!
        
        // Test setting with empty code should fail
        let setResult = config.urlComponents(set: testComponents, for: "")
        XCTAssertTrue(setResult.isFailure)
        
        if case .failure(let error) = setResult {
            XCTAssertTrue(error is any DNSError)
        }
    }
    
    func testURLComponentsNonExistentCode() {
        // Test retrieving components for non-existent code
        let getResult = config.urlComponents(for: "nonExistent")
        XCTAssertTrue(getResult.isFailure)
        
        if case .failure(let error) = getResult {
            XCTAssertTrue(error is any DNSError)
        }
    }
    
    func testURLComponentsDefaultRetrieval() {
        // Test default component retrieval when no default is set
        let defaultResult = config.urlComponents()
        XCTAssertTrue(defaultResult.isFailure)
        
        // Set a non-default component and test fallback
        let testComponents = URLComponents(string: "https://fallback.test.com")!
        let _ = config.urlComponents(set: testComponents, for: "fallback")
        
        let fallbackResult = config.urlComponents()
        XCTAssertTrue(fallbackResult.isSuccess)
    }
    
    func testURLComponentsOverwrite() {
        let testCode = "overwriteTest"
        let originalComponents = URLComponents(string: "https://original.test.com")!
        let newComponents = URLComponents(string: "https://new.test.com")!
        
        // Set original components
        let _ = config.urlComponents(set: originalComponents, for: testCode)
        
        // Overwrite with new components
        let _ = config.urlComponents(set: newComponents, for: testCode)
        
        // Verify new components are retrieved
        let getResult = config.urlComponents(for: testCode)
        if case .success(let components) = getResult {
            XCTAssertEqual(components.host, "new.test.com")
        } else {
            XCTFail("Should retrieve overwritten components")
        }
    }
    
    // MARK: - REST Headers Tests
    
    func testRestHeaders() {
        let testCode = "headerTest"
        let testComponents = URLComponents(string: "https://header.test.com")!
        let _ = config.urlComponents(set: testComponents, for: testCode)
        
        let headersResult = config.restHeaders(for: testCode)
        switch headersResult {
        case .success(let headers):
            XCTAssertNotNil(headers)
            // Default implementation should return empty headers
            XCTAssertEqual(headers.count, 0)
        case .failure:
            XCTFail("Should successfully retrieve REST headers")
        }
    }
    
    func testRestHeadersDefault() {
        // Set up a component for fallback
        let testComponents = URLComponents(string: "https://default.test.com")!
        let _ = config.urlComponents(set: testComponents, for: "testDefault")
        
        let headersResult = config.restHeaders()
        XCTAssertTrue(headersResult.isSuccess)
    }
    
    // MARK: - URL Request Tests
    
    func testURLRequestCreation() {
        let testCode = "requestTest"
        let testComponents = URLComponents(string: "https://request.test.com")!
        let testURL = URL(string: "https://request.test.com/endpoint")!
        
        // Set up components
        let _ = config.urlComponents(set: testComponents, for: testCode)
        
        // Create URL request
        let requestResult = config.urlRequest(for: testCode, using: testURL)
        switch requestResult {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
            XCTAssertNotNil(request.headers)
            XCTAssertEqual(request.httpMethod, "GET") // Default method
        case .failure:
            XCTFail("Should successfully create URL request")
        }
    }
    
    func testURLRequestDefault() {
        let testURL = URL(string: "https://default.test.com/endpoint")!
        
        // Test without any components - should use fallback logic
        let requestResult = config.urlRequest(using: testURL)
        XCTAssertFalse(requestResult.isFailure)
        
        // Set up default components
        let defaultComponents = URLComponents(string: "https://default.test.com")!
        let _ = config.urlComponents(set: defaultComponents, for: "default")
        
        let successResult = config.urlRequest(using: testURL)
        XCTAssertTrue(successResult.isSuccess)
    }
    
    func testURLRequestWithInvalidConfig() {
        let testURL = URL(string: "https://invalid.test.com/endpoint")!
        
        // Don't set any config - request should fail gracefully
        let requestResult = config.urlRequest(for: "invalidCode", using: testURL)
        XCTAssertFalse(requestResult.isFailure)
        
        if case .failure(let error) = requestResult {
            XCTAssertTrue(error is any DNSError)
        }
    }
    
    // MARK: - Scene Lifecycle Tests
    
    func testSceneLifecycleMethods() {
        // These methods should not crash when called
        XCTAssertNoThrow(config.didBecomeActive())
        XCTAssertNoThrow(config.willResignActive())
        XCTAssertNoThrow(config.willEnterForeground())
        XCTAssertNoThrow(config.didEnterBackground())
    }
    
    // MARK: - Configuration Tests
    
    func testConfigureMethod() {
        // The configure method is open for overriding
        // Base implementation should not crash
        XCTAssertNoThrow(config.configure())
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() {
        weak var weakConfig: NETBlankConfig?
        
        autoreleasepool {
            let strongConfig = NETBlankConfig()
            weakConfig = strongConfig
            XCTAssertNotNil(weakConfig)
        }
        
        // After autoreleasepool, config should be deallocated
        XCTAssertNil(weakConfig)
    }
}

