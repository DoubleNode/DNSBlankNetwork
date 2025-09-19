//
//  DNSBlankNetworkCodeLocationTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBlankNetworkTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import DNSError
@testable import DNSBlankNetwork

@MainActor
final class DNSBlankNetworkCodeLocationTests: XCTestCase {
    private var sut: DNSBlankNetworkCodeLocation!

    override func setUp() {
        super.setUp()
        sut = DNSBlankNetworkCodeLocation(self)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_createsInstance() {
        // Given & When
        let codeLocation = DNSBlankNetworkCodeLocation(self)

        // Then
        XCTAssertNotNil(codeLocation)
    }

    // MARK: - Domain Preface Tests

    func test_domainPreface_returnsCorrectValue() {
        // Given & When
        let domainPreface = DNSBlankNetworkCodeLocation.domainPreface

        // Then
        XCTAssertEqual(domainPreface, "com.doublenode.blankNetwork.")
    }

    func test_domainPreface_isNotEmpty() {
        // Given & When
        let domainPreface = DNSBlankNetworkCodeLocation.domainPreface

        // Then
        XCTAssertFalse(domainPreface.isEmpty)
    }

    func test_domainPreface_hasCorrectFormat() {
        // Given & When
        let domainPreface = DNSBlankNetworkCodeLocation.domainPreface

        // Then
        XCTAssertTrue(domainPreface.hasPrefix("com.doublenode."))
        XCTAssertTrue(domainPreface.hasSuffix("."))
        XCTAssertTrue(domainPreface.contains("blankNetwork"))
    }

    // MARK: - Inheritance Tests

    func test_inheritsFromDNSCodeLocation() {
        // Given & When & Then
        XCTAssertTrue(sut is DNSCodeLocation)
    }

    func test_instanceDomainPreface_matchesClassDomainPreface() {
        // Given & When
        let classDomainPreface = DNSBlankNetworkCodeLocation.domainPreface
        let instanceDomainPreface = type(of: sut).domainPreface

        // Then
        XCTAssertEqual(classDomainPreface, instanceDomainPreface)
    }

    // MARK: - Type Alias Tests

    func test_typeAlias_blankNetwork_isCorrectType() {
        // Given & When
        let codeLocation: DNSCodeLocation.blankNetwork = DNSBlankNetworkCodeLocation(self)

        // Then
        XCTAssertTrue(codeLocation is DNSBlankNetworkCodeLocation)
    }

    func test_typeAlias_canBeUsedForErrorCreation() {
        // Given
        let parameters = ["testParam"]
        let transactionId = "test123"

        // When
        let error = DNSError.NetworkBase.invalidParameters(
            parameters: parameters,
            transactionId: transactionId,
            .blankNetwork(sut)
        )

        // Then
        XCTAssertNotNil(error)
        XCTAssertTrue(error is DNSError)
    }

    // MARK: - Error Integration Tests

    func test_codeLocation_usedInErrorContext() {
        // Given
        let testParameters = ["url", "headers"]
        let testTransactionId = "txn_test_123"

        // When - Create different types of errors using the code location
        let invalidParamsError = DNSError.NetworkBase.invalidParameters(
            parameters: testParameters,
            transactionId: testTransactionId,
            .blankNetwork(sut)
        )

        let networkError = DNSError.NetworkBase
            .invalidParameters(
                parameters: ["network"],
                transactionId: testTransactionId,
                .blankNetwork(sut)
            )

        // Then
        XCTAssertNotNil(invalidParamsError)
        XCTAssertNotNil(networkError)
        XCTAssertTrue(invalidParamsError is DNSError)
        XCTAssertTrue(networkError is DNSError)
    }

    // MARK: - Multiple Instance Tests

    func test_multipleInstances_haveSameDomainPreface() {
        // Given
        let instance1 = DNSBlankNetworkCodeLocation(self)
        let instance2 = DNSBlankNetworkCodeLocation(self)

        // When
        let domainPreface1 = type(of: instance1).domainPreface
        let domainPreface2 = type(of: instance2).domainPreface

        // Then
        XCTAssertEqual(domainPreface1, domainPreface2)
    }

    func test_multipleInstances_areIndependent() {
        // Given
        let instance1 = DNSBlankNetworkCodeLocation(self)
        let instance2 = DNSBlankNetworkCodeLocation(self)

        // When & Then
        XCTAssertFalse(instance1 === instance2) // Different object references
        XCTAssertTrue(type(of: instance1) == type(of: instance2)) // Same type
    }

    // MARK: - Static vs Instance Behavior Tests

    func test_staticDomainPreface_consistentAcrossInstances() {
        // Given
        let instances = (0..<5).map { _ in DNSBlankNetworkCodeLocation(self) }

        // When
        let staticDomainPreface = DNSBlankNetworkCodeLocation.domainPreface
        let instanceDomainPrefacess = instances.map { type(of: $0).domainPreface }

        // Then
        for instanceDomainPreface in instanceDomainPrefacess {
            XCTAssertEqual(staticDomainPreface, instanceDomainPreface)
        }
    }

    // MARK: - Thread Safety Tests

    func test_domainPreface_threadSafety() {
        // Given
        let expectation = self.expectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 100
        let queue = DispatchQueue.global(qos: .userInitiated)

        // When - Access domain preface from multiple threads
        for _ in 0..<100 {
            queue.async {
                let domainPreface = DNSBlankNetworkCodeLocation.domainPreface
                XCTAssertEqual(domainPreface, "com.doublenode.blankNetwork.")
                expectation.fulfill()
            }
        }

        // Then
        waitForExpectations(timeout: 5.0)
    }

    func test_instanceCreation_threadSafety() {
        // Given
        let expectation = self.expectation(description: "Instance creation thread safety")
        expectation.expectedFulfillmentCount = 50
        let queue = DispatchQueue.global(qos: .userInitiated)

        // When - Create instances from multiple threads
        for _ in 0..<50 {
            queue.async {
                let instance = DNSBlankNetworkCodeLocation(self)
                XCTAssertNotNil(instance)
                XCTAssertEqual(type(of: instance).domainPreface, "com.doublenode.blankNetwork.")
                expectation.fulfill()
            }
        }

        // Then
        waitForExpectations(timeout: 5.0)
    }

    // MARK: - Performance Tests

    func test_domainPreface_performance() {
        // Given & When & Then
        measure {
            for _ in 0..<10000 {
                _ = DNSBlankNetworkCodeLocation.domainPreface
            }
        }
    }

    func test_instanceCreation_performance() {
        // Given & When & Then
        measure {
            for _ in 0..<1000 {
                _ = DNSBlankNetworkCodeLocation(self)
            }
        }
    }

    // MARK: - String Validation Tests

    func test_domainPreface_validReversedomainFormat() {
        // Given
        let domainPreface = DNSBlankNetworkCodeLocation.domainPreface

        // When
        let components = domainPreface.components(separatedBy: ".")

        // Then
        XCTAssertGreaterThanOrEqual(components.count, 4) // com, doublenode, blankNetwork, ""
        XCTAssertEqual(components[0], "com")
        XCTAssertEqual(components[1], "doublenode")
        XCTAssertTrue(components.contains("blankNetwork"))
        XCTAssertEqual(components.last, "") // Due to trailing dot
    }

    func test_domainPreface_uniqueness() {
        // Given
        let blankNetworkDomain = DNSBlankNetworkCodeLocation.domainPreface

        // When & Then - Verify it's unique compared to expected other domain patterns
        XCTAssertNotEqual(blankNetworkDomain, "com.doublenode.")
        XCTAssertNotEqual(blankNetworkDomain, "com.doublenode.network.")
        XCTAssertNotEqual(blankNetworkDomain, "com.doublenode.blankNetwork") // No trailing dot
        XCTAssertEqual(blankNetworkDomain, "com.doublenode.blankNetwork.") // Correct format
    }
}