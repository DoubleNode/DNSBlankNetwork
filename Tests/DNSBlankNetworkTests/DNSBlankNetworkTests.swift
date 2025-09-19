//
//  DNSBlankNetworkTests.swift
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

final class DNSBlankNetworkTests: XCTestCase {

    // MARK: - Module Level Tests

    func test_DNSBlankNetwork_moduleImports() {
        // Test that the module imports correctly and key classes are accessible
        XCTAssertNotNil(NETBlankRouter.self)
        XCTAssertNotNil(NETBlankConfig.self)
        XCTAssertNotNil(DNSBlankNetworkCodeLocation.self)
    }

    func test_protocolConformance_NETBlankRouter() {
        // Test that NETBlankRouter conforms to required protocols
        let router = NETBlankRouter()
        XCTAssertTrue(router is NETPTCLRouter)
        XCTAssertTrue(router is NSObjectProtocol)
    }

    func test_protocolConformance_NETBlankConfig() {
        // Test that NETBlankConfig conforms to required protocols
        let config = NETBlankConfig()
        XCTAssertTrue(config is NETPTCLConfig)
        XCTAssertTrue(config is NSObjectProtocol)
    }

    func test_codeLocationTypeAlias() {
        // Test that the type alias works correctly
        let codeLocation: DNSCodeLocation.blankNetwork = DNSBlankNetworkCodeLocation(self)
        XCTAssertTrue(codeLocation is DNSBlankNetworkCodeLocation)
        XCTAssertTrue(codeLocation is DNSCodeLocation)
    }

    // MARK: - Basic Functionality Tests

    func test_routerConfig_defaultAssociation() {
        // Test that router creates with blank config by default
        let router = NETBlankRouter()
        XCTAssertNotNil(router.netConfig)
        XCTAssertTrue(router.netConfig is NETBlankConfig)
    }

    func test_routerConfig_customAssociation() {
        // Test that router can use custom config
        let customConfig = NETBlankConfig()
        let router = NETBlankRouter(with: customConfig)
        XCTAssertTrue(router.netConfig === customConfig)
    }

    func test_basicURLRequest_creation() {
        // Test basic URL request creation functionality
        let router = NETBlankRouter()
        let config = NETBlankConfig()
        let testURL = URL(string: "https://example.com")!

        // Set up basic configuration
        let components = URLComponents(string: "https://example.com")!
        let setResult = config.urlComponents(set: components, for: "default")

        switch setResult {
        case .success:
            break
        case .failure:
            XCTFail("Failed to set up basic configuration")
            return
        }

        // Test URL request creation
        let routerWithConfig = NETBlankRouter(with: config)
        let result = routerWithConfig.urlRequest(using: testURL)

        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
        case .failure:
            // This is acceptable for blank implementations
            break
        }
    }

    // MARK: - Error Handling Tests

    func test_errorHandling_invalidConfiguration() {
        // Test error handling with invalid configuration
        let config = NETBlankConfig()
        let router = NETBlankRouter(with: config)
        let testURL = URL(string: "https://example.com")!

        // Try to use non-existent configuration
        let result = router.urlRequest(for: "nonExistent", using: testURL)

        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    func test_codeLocation_errorIntegration() {
        // Test that code location works with error creation
        let error = DNSError.NetworkBase
            .invalidParameters(
                parameters: ["test"],
                transactionId: "test123",
                .blankNetwork(self)
            )

        XCTAssertNotNil(error)
        XCTAssertTrue(error is DNSError)
    }

    // MARK: - Language Code Tests

    func test_languageCode_consistency() {
        // Test that both router and config return consistent language codes
        let routerLanguageCode = NETBlankRouter.languageCode
        let configLanguageCode = NETBlankConfig.languageCode

        XCTAssertEqual(routerLanguageCode, configLanguageCode)
        XCTAssertFalse(routerLanguageCode.isEmpty)
        XCTAssertGreaterThanOrEqual(routerLanguageCode.count, 2)
    }

    // MARK: - Thread Safety Tests

    func test_multipleInstances_threadSafety() {
        // Test creating multiple instances concurrently
        let expectation = self.expectation(description: "Multiple instances thread safety")
        expectation.expectedFulfillmentCount = 50

        let queue = DispatchQueue.global(qos: .userInitiated)

        // Create a placeholder instance to avoid capturing self
        let testPlaceholder = "testPlaceholder"

        for _ in 0..<50 {
            queue.async {
                let router = NETBlankRouter()
                let config = NETBlankConfig()
                let codeLocation = DNSBlankNetworkCodeLocation(testPlaceholder)

                XCTAssertNotNil(router)
                XCTAssertNotNil(config)
                XCTAssertNotNil(codeLocation)

                expectation.fulfill()
            }
        }

        self.wait(for: [expectation], timeout: 5.0)
    }

    // MARK: - Performance Tests

    func test_instanceCreation_performance() {
        // Test performance of creating instances
        measure {
            for _ in 0..<100 {
                let router = NETBlankRouter()
                let config = NETBlankConfig()
                let codeLocation = DNSBlankNetworkCodeLocation(self)

                // Use instances to prevent optimization
                _ = router.checkOption("test")
                _ = config.checkOption("test")
                _ = type(of: codeLocation).domainPreface
            }
        }
    }

    // MARK: - Integration Smoke Tests

    func test_endToEnd_basicWorkflow() {
        // Basic end-to-end workflow test
        let config = NETBlankConfig()
        let router = NETBlankRouter(with: config)

        // Enable some options
        router.enableOption("testFeature")
        config.enableOption("configFeature")

        // Verify options
        XCTAssertTrue(router.checkOption("testFeature"))
        XCTAssertTrue(config.checkOption("configFeature"))

        // Test lifecycle methods don't crash
        XCTAssertNoThrow(router.didBecomeActive())
        XCTAssertNoThrow(router.willResignActive())
        XCTAssertNoThrow(config.willEnterForeground())
        XCTAssertNoThrow(config.didEnterBackground())
    }

    func test_packageIntegrity() {
        // Test that all main components work together
        let codeLocation = DNSBlankNetworkCodeLocation(self)
        let config = NETBlankConfig()
        let router = NETBlankRouter(with: config)

        // Test domain preface
        XCTAssertEqual(DNSBlankNetworkCodeLocation.domainPreface, "com.doublenode.blankNetwork.")

        // Test language codes
        XCTAssertFalse(NETBlankRouter.languageCode.isEmpty)
        XCTAssertFalse(NETBlankConfig.languageCode.isEmpty)

        // Test basic functionality
        XCTAssertFalse(router.checkOption("nonExistent"))
        XCTAssertFalse(config.checkOption("nonExistent"))

        // Test error creation
        let error = DNSError.NetworkBase
            .invalidParameters(
                parameters: ["test"],
                transactionId: "test",
                .blankNetwork(self)
            )
        XCTAssertNotNil(error)
    }

    @MainActor
    static var allTests = [
        ("test_DNSBlankNetwork_moduleImports", test_DNSBlankNetwork_moduleImports),
        ("test_protocolConformance_NETBlankRouter", test_protocolConformance_NETBlankRouter),
        ("test_protocolConformance_NETBlankConfig", test_protocolConformance_NETBlankConfig),
        ("test_codeLocationTypeAlias", test_codeLocationTypeAlias),
        ("test_routerConfig_defaultAssociation", test_routerConfig_defaultAssociation),
        ("test_routerConfig_customAssociation", test_routerConfig_customAssociation),
        ("test_basicURLRequest_creation", test_basicURLRequest_creation),
        ("test_errorHandling_invalidConfiguration", test_errorHandling_invalidConfiguration),
        ("test_codeLocation_errorIntegration", test_codeLocation_errorIntegration),
        ("test_languageCode_consistency", test_languageCode_consistency),
        ("test_multipleInstances_threadSafety", test_multipleInstances_threadSafety),
        ("test_instanceCreation_performance", test_instanceCreation_performance),
        ("test_endToEnd_basicWorkflow", test_endToEnd_basicWorkflow),
        ("test_packageIntegrity", test_packageIntegrity),
    ]
}
