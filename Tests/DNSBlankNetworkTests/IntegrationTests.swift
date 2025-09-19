//
//  IntegrationTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBlankNetworkTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import Alamofire
import DNSError
import DNSProtocols
@testable import DNSBlankNetwork

@MainActor
final class IntegrationTests: XCTestCase {
    private var config: NETBlankConfig!
    private var router: NETBlankRouter!

    override func setUp() {
        super.setUp()
        config = NETBlankConfig()
        router = NETBlankRouter(with: config)
    }

    override func tearDown() {
        router = nil
        config = nil
        super.tearDown()
    }

    // MARK: - Router-Config Integration Tests

    func test_routerWithBlankConfig_urlRequestFlow() {
        // Given
        let testURL = URL(string: "https://api.example.com/users")!
        let components = URLComponents(string: "https://api.example.com")!
        _ = config.urlComponents(set: components, for: "default")

        // When
        let result = router.urlRequest(using: testURL)

        // Then
        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
            XCTAssertNotNil(request.allHTTPHeaderFields)
        case .failure:
            XCTFail("Expected successful URL request creation")
        }
    }

    func test_routerWithBlankConfig_urlRequestForCodeFlow() {
        // Given
        let code = "api"
        let testURL = URL(string: "https://api.example.com/posts")!
        let components = URLComponents(string: "https://api.example.com")!
        _ = config.urlComponents(set: components, for: code)

        // When
        let result = router.urlRequest(for: code, using: testURL)

        // Then
        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
            XCTAssertNotNil(request.allHTTPHeaderFields)
        case .failure:
            XCTFail("Expected successful URL request creation for code")
        }
    }

    func test_routerWithBlankConfig_errorPropagation() {
        // Given
        let invalidCode = "nonExistentCode"
        let testURL = URL(string: "https://example.com")!

        // When
        let result = router.urlRequest(for: invalidCode, using: testURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    func test_routerAndConfigOptions_synchronization() {
        // Given
        let option1 = "feature1"
        let option2 = "feature2"

        // When - Enable options on router
        router.enableOption(option1)

        // Then - Router should have the option
        XCTAssertTrue(router.checkOption(option1))

        // When - Enable options on config
        config.enableOption(option2)

        // Then - Config should have the option
        XCTAssertTrue(config.checkOption(option2))

        // Verify they are independent
        XCTAssertFalse(router.checkOption(option2))
        XCTAssertFalse(config.checkOption(option1))
    }

    // MARK: - Lifecycle Integration Tests

    func test_routerAndConfig_lifecycleMethods() {
        // Given
        let expectation = self.expectation(description: "Lifecycle methods complete")
        expectation.expectedFulfillmentCount = 8 // 4 methods × 2 objects

        let testableRouter = TestableIntegrationRouter()
        let testableConfig = TestableIntegrationConfig()
        let integratedRouter = NETBlankRouter(with: testableConfig)

        testableRouter.lifecycleExpectation = expectation
        testableConfig.lifecycleExpectation = expectation

        // When
        testableRouter.didBecomeActive()
        testableRouter.willResignActive()
        testableRouter.willEnterForeground()
        testableRouter.didEnterBackground()

        testableConfig.didBecomeActive()
        testableConfig.willResignActive()
        testableConfig.willEnterForeground()
        testableConfig.didEnterBackground()

        // Then
        waitForExpectations(timeout: 1.0)
    }

    // MARK: - End-to-End Workflow Tests

    func test_completeWorkflow_setupConfigurationAndMakeRequest() {
        // Given - Complete setup scenario
        let apiCode = "api"
        let webCode = "web"

        // Set up API configuration
        var apiComponents = URLComponents()
        apiComponents.scheme = "https"
        apiComponents.host = "api.example.com"
        apiComponents.port = 443
        apiComponents.path = "/v1"

        // Set up Web configuration
        var webComponents = URLComponents()
        webComponents.scheme = "https"
        webComponents.host = "web.example.com"
        webComponents.port = 80

        // When - Configure multiple endpoints
        let apiSetResult = config.urlComponents(set: apiComponents, for: apiCode)
        let webSetResult = config.urlComponents(set: webComponents, for: webCode)

        // Then - Verify configurations are set
        switch apiSetResult {
        case .success:
            break
        case .failure:
            XCTFail("Failed to set API components")
        }

        switch webSetResult {
        case .success:
            break
        case .failure:
            XCTFail("Failed to set web components")
        }

        // When - Make requests to different endpoints
        let apiURL = URL(string: "https://api.example.com/v1/users")!
        let webURL = URL(string: "https://web.example.com/login")!

        let apiResult = router.urlRequest(for: apiCode, using: apiURL)
        let webResult = router.urlRequest(for: webCode, using: webURL)

        // Then - Verify both requests are created successfully
        switch apiResult {
        case .success(let request):
            XCTAssertEqual(request.url, apiURL)
        case .failure:
            XCTFail("Failed to create API request")
        }

        switch webResult {
        case .success(let request):
            XCTAssertEqual(request.url, webURL)
        case .failure:
            XCTFail("Failed to create web request")
        }
    }

    func test_multipleRoutersWithSameConfig_shareConfiguration() {
        // Given
        let sharedConfig = NETBlankConfig()
        let router1 = NETBlankRouter(with: sharedConfig)
        let router2 = NETBlankRouter(with: sharedConfig)

        let components = URLComponents(string: "https://shared.example.com")!
        _ = sharedConfig.urlComponents(set: components, for: "shared")

        let testURL = URL(string: "https://shared.example.com/endpoint")!

        // When
        let result1 = router1.urlRequest(for: "shared", using: testURL)
        let result2 = router2.urlRequest(for: "shared", using: testURL)

        // Then - Both routers should use the same configuration
        switch (result1, result2) {
        case (.success(let request1), .success(let request2)):
            XCTAssertEqual(request1.url, request2.url)
        default:
            XCTFail("Expected both requests to succeed")
        }
    }

    // MARK: - Error Handling Integration Tests

    func test_routerWithCustomConfig_errorHandling() {
        // Given
        let failingConfig = FailingIntegrationConfig()
        let routerWithFailingConfig = NETBlankRouter(with: failingConfig)
        let testURL = URL(string: "https://example.com")!

        // When
        let result = routerWithFailingConfig.urlRequest(using: testURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    // MARK: - Performance Integration Tests

    func test_highVolume_requestCreation_performance() {
        // Given
        let components = URLComponents(string: "https://performance.example.com")!
        _ = config.urlComponents(set: components, for: "performance")

        // When
        measure {
            for i in 0..<1000 {
                let url = URL(string: "https://performance.example.com/test\(i)")!
                _ = router.urlRequest(for: "performance", using: url)
            }
        }

        // Then - Performance measurement completes without assertion
    }

    func test_concurrentRequests_threadSafety() {
        // Given
        let components = URLComponents(string: "https://concurrent.example.com")!
        _ = config.urlComponents(set: components, for: "concurrent")
        let expectation = self.expectation(description: "Concurrent requests")
        expectation.expectedFulfillmentCount = 100

        let queue = DispatchQueue.global(qos: .userInitiated)

        // When
        for i in 0..<100 {
            queue.async {
                let url = URL(string: "https://concurrent.example.com/test\(i)")!
                let result = self.router.urlRequest(for: "concurrent", using: url)

                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Request \(i) failed unexpectedly")
                }
            }
        }

        // Then
        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Complex URL Handling Tests

    func test_complexURLs_withQueryParameters() {
        // Given
        let components = URLComponents(string: "https://api.example.com")!
        _ = config.urlComponents(set: components, for: "api")

        var urlComponents = URLComponents(string: "https://api.example.com/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: "swift testing"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "offset", value: "0")
        ]

        guard let complexURL = urlComponents.url else {
            XCTFail("Failed to create complex URL")
            return
        }

        // When
        let result = router.urlRequest(for: "api", using: complexURL)

        // Then
        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, complexURL)
            XCTAssertTrue(request.url?.absoluteString.contains("q=swift%20testing") ?? false)
        case .failure:
            XCTFail("Failed to handle complex URL")
        }
    }
}

// MARK: - Test Helpers

private class TestableIntegrationRouter: NETBlankRouter {
    var lifecycleExpectation: XCTestExpectation?

    override func didBecomeActive() {
        super.didBecomeActive()
        lifecycleExpectation?.fulfill()
    }

    override func willResignActive() {
        super.willResignActive()
        lifecycleExpectation?.fulfill()
    }

    override func willEnterForeground() {
        super.willEnterForeground()
        lifecycleExpectation?.fulfill()
    }

    override func didEnterBackground() {
        super.didEnterBackground()
        lifecycleExpectation?.fulfill()
    }
}

private class TestableIntegrationConfig: NETBlankConfig {
    var lifecycleExpectation: XCTestExpectation?

    override func didBecomeActive() {
        super.didBecomeActive()
        lifecycleExpectation?.fulfill()
    }

    override func willResignActive() {
        super.willResignActive()
        lifecycleExpectation?.fulfill()
    }

    override func willEnterForeground() {
        super.willEnterForeground()
        lifecycleExpectation?.fulfill()
    }

    override func didEnterBackground() {
        super.didEnterBackground()
        lifecycleExpectation?.fulfill()
    }
}

private class FailingIntegrationConfig: NETBlankConfig {
    override func urlRequest(using url: URL) -> NETPTCLConfigResURLRequest {
        let error = DNSError.NetworkBase
            .invalidParameters(parameters: ["url"], transactionId: "", .blankNetwork(self))
        return .failure(error)
    }

    override func urlRequest(for code: String, using url: URL) -> NETPTCLConfigResURLRequest {
        let error = DNSError.NetworkBase
            .invalidParameters(parameters: ["code", "url"], transactionId: "", .blankNetwork(self))
        return .failure(error)
    }
}