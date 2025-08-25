//
//  DNSBlankNetworkCodeLocationTests.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBlankNetworkTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
import Foundation
import DNSError
@testable import DNSBlankNetwork

final class DNSBlankNetworkCodeLocationTests: XCTestCase {
    
    // MARK: - Basic Functionality Tests
    
    func testDomainPreface() {
        let expectedPreface = "com.doublenode.blankNetwork."
        XCTAssertEqual(DNSBlankNetworkCodeLocation.domainPreface, expectedPreface)
    }
    
    func testInheritanceFromDNSCodeLocation() {
        let codeLocation = DNSBlankNetworkCodeLocation(self)
        XCTAssertNotNil(codeLocation as? DNSCodeLocation)
    }
    
    func testSendableConformance() {
        // Test that the class conforms to Sendable (compile-time check)
        let codeLocation = DNSBlankNetworkCodeLocation(self)
        
        // This should compile without warnings if @unchecked Sendable is properly applied
        Task {
            let _ = DNSBlankNetworkCodeLocation.domainPreface
        }
        
        XCTAssertNotNil(codeLocation)
    }
    
    // MARK: - Typealias Tests
    
    func testTypealiasExtension() {
        // Test that the typealias works correctly
        let codeLocationViaTypealias = DNSCodeLocation.blankNetwork(self)
        XCTAssertNotNil(codeLocationViaTypealias as? DNSBlankNetworkCodeLocation)
        XCTAssertNotNil(codeLocationViaTypealias as? DNSCodeLocation)
    }
    
    func testTypealiasConsistency() {
        let directInstance = DNSBlankNetworkCodeLocation(self)
        let typealiasInstance = DNSCodeLocation.blankNetwork(self)
        
        // Both should have the same domain preface
        XCTAssertEqual(type(of: directInstance).domainPreface, type(of: typealiasInstance).domainPreface)
    }
    
    // MARK: - Class Properties Tests
    
    func testDomainPrefaceFormat() {
        let preface = DNSBlankNetworkCodeLocation.domainPreface
        
        // Should start with com.doublenode
        XCTAssertTrue(preface.hasPrefix("com.doublenode"))
        
        // Should end with a dot
        XCTAssertTrue(preface.hasSuffix("."))
        
        // Should contain blankNetwork
        XCTAssertTrue(preface.contains("blankNetwork"))
        
        // Should be properly formatted reverse DNS
        let components = preface.dropLast().components(separatedBy: ".")
        XCTAssertGreaterThanOrEqual(components.count, 3)
        XCTAssertEqual(components[0], "com")
        XCTAssertEqual(components[1], "doublenode")
        XCTAssertTrue(components.contains("blankNetwork"))
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        let codeLocation = DNSBlankNetworkCodeLocation(self)
        XCTAssertNotNil(codeLocation)
    }
    
    func testMultipleInstances() {
        let instance1 = DNSBlankNetworkCodeLocation(self)
        let instance2 = DNSBlankNetworkCodeLocation(self)
        
        // Should be different instances
        XCTAssertFalse(instance1 === instance2)
        
        // But should have the same domain preface
        XCTAssertEqual(type(of: instance1).domainPreface, type(of: instance2).domainPreface)
    }
    
    // MARK: - Inheritance Chain Tests
    
    func testInheritanceChain() {
        let codeLocation = DNSBlankNetworkCodeLocation(self)
        
        // Test inheritance hierarchy
        XCTAssertNotNil(codeLocation as? DNSBlankNetworkCodeLocation)
        XCTAssertNotNil(codeLocation as? DNSCodeLocation)
    }
    
    func testOverriddenClassProperty() {
        // Test that the domainPreface is properly overridden
        let blankNetworkPreface = DNSBlankNetworkCodeLocation.domainPreface
        let basePreface = DNSCodeLocation.domainPreface
        
        // They should be different (proving override works)
        XCTAssertNotEqual(blankNetworkPreface, basePreface)
        XCTAssertTrue(blankNetworkPreface.contains("blankNetwork"))
    }
    
    // MARK: - Thread Safety Tests
    
    func testConcurrentAccess() {
        let expectation = XCTestExpectation(description: "Concurrent access test")
        let queue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        let resultsQueue = DispatchQueue(label: "results", attributes: .concurrent)
        var results: [String] = []
        
        // Test concurrent access to class property
        for _ in 0..<100 {
            group.enter()
            queue.async {
                let preface = DNSBlankNetworkCodeLocation.domainPreface
                resultsQueue.async(flags: .barrier) {
                    results.append(preface)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            // All results should be identical
            let uniqueResults = Set(results)
            XCTAssertEqual(uniqueResults.count, 1)
            XCTAssertEqual(results.count, 100)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentInstanceCreation() {
        let expectation = XCTestExpectation(description: "Concurrent instance creation")
        let queue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        let instancesQueue = DispatchQueue(label: "instances", attributes: .concurrent)
        var instances: [DNSBlankNetworkCodeLocation] = []
        
        // Create multiple instances concurrently
        for _ in 0..<50 {
            group.enter()
            queue.async {
                // Use a test object instead of self to avoid capture issues
                let testObject = NSObject()
                let instance = DNSBlankNetworkCodeLocation(testObject)
                instancesQueue.async(flags: .barrier) {
                    instances.append(instance)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            XCTAssertEqual(instances.count, 50)
            
            // All instances should have the same domain preface
            let prefixes = instances.map { type(of: $0).domainPreface }
            let uniquePrefixes = Set(prefixes)
            XCTAssertEqual(uniquePrefixes.count, 1)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithDNSError() {
        let codeLocation = DNSBlankNetworkCodeLocation(self)
        
        // Test that code location can be used with DNS errors
        // This tests the integration with the DNSError system
        let error = DNSError.NetworkBase.invalidParameters(
            parameters: ["test"], 
            transactionId: "testTransaction",
            codeLocation
        )
        
        XCTAssertNotNil(error)
        // The error should contain our code location information
        let errorDescription = error.errorDescription ?? ""
        XCTAssertTrue(errorDescription.contains("NETBASE") || errorDescription.contains("NETBASE"))
    }
    
    // MARK: - Memory Management Tests
    
    func testMemoryManagement() {
        weak var weakCodeLocation: DNSBlankNetworkCodeLocation?
        
        autoreleasepool {
            let codeLocation = DNSBlankNetworkCodeLocation(self)
            weakCodeLocation = codeLocation
            XCTAssertNotNil(weakCodeLocation)
        }
        
        // Should be deallocated after autoreleasepool
        XCTAssertNil(weakCodeLocation)
    }
    
    func testRetainCycleAvoidance() {
        weak var weakCodeLocation: DNSBlankNetworkCodeLocation?
        
        autoreleasepool {
            let codeLocation = DNSBlankNetworkCodeLocation(self)
            weakCodeLocation = codeLocation
            
            // Simulate usage that might create retain cycles
            let _ = type(of: codeLocation).domainPreface
            
            XCTAssertNotNil(weakCodeLocation)
        }
        
        // Should still be deallocated
        XCTAssertNil(weakCodeLocation)
    }
    
    // MARK: - Performance Tests
    
    func testDomainPrefacePerformance() {
        measure {
            for _ in 0..<10000 {
                let _ = DNSBlankNetworkCodeLocation.domainPreface
            }
        }
    }
    
    func testInstanceCreationPerformance() {
        measure {
            for _ in 0..<1000 {
                let _ = DNSBlankNetworkCodeLocation(self)
            }
        }
    }
    
    // MARK: - Edge Cases Tests
    
    func testClassPropertyConsistency() {
        // Test that the class property is consistent across multiple calls
        let preface1 = DNSBlankNetworkCodeLocation.domainPreface
        let preface2 = DNSBlankNetworkCodeLocation.domainPreface
        let preface3 = DNSBlankNetworkCodeLocation.domainPreface
        
        XCTAssertEqual(preface1, preface2)
        XCTAssertEqual(preface2, preface3)
    }
    
    func testInheritanceWithTypealias() {
        // Test complex inheritance scenarios with typealias
        let directInstance: DNSBlankNetworkCodeLocation = DNSBlankNetworkCodeLocation(self)
        let typealiasInstance: DNSBlankNetworkCodeLocation = DNSCodeLocation.blankNetwork(self)
        let baseInstance: DNSCodeLocation = DNSCodeLocation.blankNetwork(self)
        
        XCTAssertEqual(type(of: directInstance).domainPreface, type(of: typealiasInstance).domainPreface)
        XCTAssertEqual(type(of: typealiasInstance).domainPreface, type(of: baseInstance).domainPreface)
    }
}
