//
//  MinimalTest.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBlankNetworkTests
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import XCTest
@testable import DNSBlankNetwork

@MainActor
final class MinimalTest: XCTestCase {

    func test_BasicInstantiation() {
        // Test basic class instantiation works
        let router = NETBlankRouter()
        let config = NETBlankConfig()
        let codeLocation = DNSBlankNetworkCodeLocation(self)

        XCTAssertNotNil(router)
        XCTAssertNotNil(config)
        XCTAssertNotNil(codeLocation)
    }

    func test_BasicPropertyAccess() {
        // Test basic property access
        let router = NETBlankRouter()
        let config = NETBlankConfig()

        XCTAssertNotNil(router.netConfig)
        XCTAssertFalse(router.checkOption("test"))
        XCTAssertFalse(config.checkOption("test"))
    }

    func test_CodeLocationDomainPreface() {
        // Test code location domain preface
        let domainPreface = DNSBlankNetworkCodeLocation.domainPreface
        XCTAssertEqual(domainPreface, "com.doublenode.blankNetwork.")
    }

    func test_LanguageCodes() {
        // Test language codes
        let routerLanguageCode = NETBlankRouter.languageCode
        let configLanguageCode = NETBlankConfig.languageCode

        XCTAssertFalse(routerLanguageCode.isEmpty)
        XCTAssertFalse(configLanguageCode.isEmpty)
        XCTAssertEqual(routerLanguageCode, configLanguageCode)
    }
}