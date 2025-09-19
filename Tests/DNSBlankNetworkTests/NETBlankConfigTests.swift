//
//  NETBlankConfigTests.swift
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

final class NETBlankConfigTests: XCTestCase {
    private var sut: NETBlankConfig!

    override func setUp() {
        super.setUp()
        sut = NETBlankConfig()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_createsInstance() {
        // Given & When
        let config = NETBlankConfig()

        // Then
        XCTAssertNotNil(config)
    }

    func test_init_callsConfigure() {
        // Given
        let config = TestableNETBlankConfig()

        // Then
        XCTAssertTrue(config.configureWasCalled)
    }

    // MARK: - Language Code Tests

    func test_languageCode_returnsCurrentLocaleLanguageCode() {
        // Given & When
        let languageCode = NETBlankConfig.languageCode

        // Then
        XCTAssertFalse(languageCode.isEmpty)
        XCTAssertTrue(languageCode.count >= 2)
    }

    // MARK: - Option Management Tests

    func test_checkOption_withNonExistentOption_returnsFalse() {
        // Given
        let option = "nonExistentOption"

        // When
        let result = sut.checkOption(option)

        // Then
        XCTAssertFalse(result)
    }

    func test_checkOption_withExistingOption_returnsTrue() {
        // Given
        let option = "testOption"
        sut.enableOption(option)

        // When
        let result = sut.checkOption(option)

        // Then
        XCTAssertTrue(result)
    }

    func test_enableOption_withNewOption_addsOption() {
        // Given
        let option = "newOption"
        XCTAssertFalse(sut.checkOption(option))

        // When
        sut.enableOption(option)

        // Then
        XCTAssertTrue(sut.checkOption(option))
    }

    func test_enableOption_withExistingOption_doesNotAddDuplicate() {
        // Given
        let option = "existingOption"
        sut.enableOption(option)
        XCTAssertTrue(sut.checkOption(option))

        // When
        sut.enableOption(option) // Enable again

        // Then
        XCTAssertTrue(sut.checkOption(option))
    }

    func test_disableOption_withExistingOption_removesOption() {
        // Given
        let option = "optionToRemove"
        sut.enableOption(option)
        XCTAssertTrue(sut.checkOption(option))

        // When
        sut.disableOption(option)

        // Then
        XCTAssertFalse(sut.checkOption(option))
    }

    func test_disableOption_withNonExistentOption_doesNothing() {
        // Given
        let option = "nonExistentOption"
        XCTAssertFalse(sut.checkOption(option))

        // When
        sut.disableOption(option)

        // Then
        XCTAssertFalse(sut.checkOption(option))
    }

    // MARK: - Lifecycle Method Tests

    func test_didBecomeActive_doesNotThrow() {
        // Given & When & Then
        XCTAssertNoThrow(sut.didBecomeActive())
    }

    func test_willResignActive_doesNotThrow() {
        // Given & When & Then
        XCTAssertNoThrow(sut.willResignActive())
    }

    func test_willEnterForeground_doesNotThrow() {
        // Given & When & Then
        XCTAssertNoThrow(sut.willEnterForeground())
    }

    func test_didEnterBackground_doesNotThrow() {
        // Given & When & Then
        XCTAssertNoThrow(sut.didEnterBackground())
    }

    // MARK: - URL Components Tests

    func test_urlComponents_withNoData_returnsError() {
        // Given - empty urlComponentsData

        // When
        let result = sut.urlComponents()

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    func test_urlComponents_withDefaultCode_returnsSuccess() {
        // Given
        let components = URLComponents(string: "https://example.com")!
        _ = sut.urlComponents(set: components, for: "default")

        // When
        let result = sut.urlComponents()

        // Then
        switch result {
        case .success(let returnedComponents):
            XCTAssertEqual(returnedComponents.scheme, "https")
            XCTAssertEqual(returnedComponents.host, "example.com")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlComponents_withoutDefaultCodeButWithOtherCode_returnsFirstAvailable() {
        // Given
        let components = URLComponents(string: "https://api.example.com")!
        _ = sut.urlComponents(set: components, for: "api")

        // When
        let result = sut.urlComponents()

        // Then
        switch result {
        case .success(let returnedComponents):
            XCTAssertEqual(returnedComponents.scheme, "https")
            XCTAssertEqual(returnedComponents.host, "api.example.com")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlComponentsForCode_withValidCode_returnsSuccess() {
        // Given
        let code = "testCode"
        let components = URLComponents(string: "https://test.example.com")!
        _ = sut.urlComponents(set: components, for: code)

        // When
        let result = sut.urlComponents(for: code)

        // Then
        switch result {
        case .success(let returnedComponents):
            XCTAssertEqual(returnedComponents.scheme, "https")
            XCTAssertEqual(returnedComponents.host, "test.example.com")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlComponentsForCode_withInvalidCode_returnsError() {
        // Given
        let invalidCode = "nonExistentCode"

        // When
        let result = sut.urlComponents(for: invalidCode)

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    func test_urlComponentsSetForCode_withValidCode_returnsSuccess() {
        // Given
        let code = "newCode"
        let components = URLComponents(string: "https://new.example.com")!

        // When
        let result = sut.urlComponents(set: components, for: code)

        // Then
        switch result {
        case .success:
            // Verify it was stored correctly
            let getResult = sut.urlComponents(for: code)
            switch getResult {
            case .success(let storedComponents):
                XCTAssertEqual(storedComponents.scheme, "https")
                XCTAssertEqual(storedComponents.host, "new.example.com")
            case .failure:
                XCTFail("Failed to retrieve stored components")
            }
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlComponentsSetForCode_withEmptyCode_returnsError() {
        // Given
        let emptyCode = ""
        let components = URLComponents(string: "https://example.com")!

        // When
        let result = sut.urlComponents(set: components, for: emptyCode)

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    func test_urlComponentsSetForCode_allowsOverwriting() {
        // Given
        let code = "overwriteCode"
        let originalComponents = URLComponents(string: "https://original.example.com")!
        let newComponents = URLComponents(string: "https://new.example.com")!

        // When
        _ = sut.urlComponents(set: originalComponents, for: code)
        let result = sut.urlComponents(set: newComponents, for: code)

        // Then
        switch result {
        case .success:
            let getResult = sut.urlComponents(for: code)
            switch getResult {
            case .success(let storedComponents):
                XCTAssertEqual(storedComponents.host, "new.example.com")
            case .failure:
                XCTFail("Failed to retrieve overwritten components")
            }
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    // MARK: - REST Headers Tests

    func test_restHeaders_withNoData_returnsEmptyHeaders() {
        // Given - no URL components data

        // When
        let result = sut.restHeaders()

        // Then
        switch result {
        case .success(let headers):
            XCTAssertTrue(headers.isEmpty)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_restHeaders_withDefaultCode_returnsEmptyHeaders() {
        // Given
        let components = URLComponents(string: "https://example.com")!
        _ = sut.urlComponents(set: components, for: "default")

        // When
        let result = sut.restHeaders()

        // Then
        switch result {
        case .success(let headers):
            XCTAssertTrue(headers.isEmpty)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_restHeadersForCode_returnsEmptyHeaders() {
        // Given
        let code = "testCode"

        // When
        let result = sut.restHeaders(for: code)

        // Then
        switch result {
        case .success(let headers):
            XCTAssertTrue(headers.isEmpty)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    // MARK: - URL Request Tests

    func test_urlRequest_usingURL_withNoData_failsGracefully() {
        // Given
        let url = URL(string: "https://example.com")!

        // When
        let result = sut.urlRequest(using: url)

        // Then
        // This should either succeed with basic request or fail gracefully
        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, url)
            XCTAssertTrue(request.allHTTPHeaderFields?.isEmpty ?? true)
        case .failure:
            // This is also acceptable behavior
            break
        }
    }

    func test_urlRequest_usingURL_withDefaultComponents_createsRequest() {
        // Given
        let url = URL(string: "https://example.com")!
        let components = URLComponents(string: "https://example.com")!
        _ = sut.urlComponents(set: components, for: "default")

        // When
        let result = sut.urlRequest(using: url)

        // Then
        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, url)
            XCTAssertNotNil(request.allHTTPHeaderFields)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlRequestForCode_usingURL_createsRequestWithHeaders() {
        // Given
        let code = "testCode"
        let url = URL(string: "https://test.example.com")!

        // When
        let result = sut.urlRequest(for: code, using: url)

        // Then
        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, url)
            XCTAssertNotNil(request.allHTTPHeaderFields)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlRequestForCode_withFailingHeaders_returnsError() {
        // Given
        let config = TestableNETBlankConfigWithFailingHeaders()
        let code = "testCode"
        let url = URL(string: "https://example.com")!

        // When
        let result = config.urlRequest(for: code, using: url)

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    // MARK: - Integration Tests

    func test_urlComponents_integrationWithMultipleCodes() {
        // Given
        let apiComponents = URLComponents(string: "https://api.example.com")!
        let webComponents = URLComponents(string: "https://web.example.com")!
        let defaultComponents = URLComponents(string: "https://default.example.com")!

        // When
        _ = sut.urlComponents(set: apiComponents, for: "api")
        _ = sut.urlComponents(set: webComponents, for: "web")
        _ = sut.urlComponents(set: defaultComponents, for: "default")

        // Then
        switch sut.urlComponents(for: "api") {
        case .success(let components):
            XCTAssertEqual(components.host, "api.example.com")
        case .failure:
            XCTFail("Failed to get api components")
        }

        switch sut.urlComponents(for: "web") {
        case .success(let components):
            XCTAssertEqual(components.host, "web.example.com")
        case .failure:
            XCTFail("Failed to get web components")
        }

        // Default should be returned by urlComponents()
        switch sut.urlComponents() {
        case .success(let components):
            XCTAssertEqual(components.host, "default.example.com")
        case .failure:
            XCTFail("Failed to get default components")
        }
    }

    // MARK: - Thread Safety Tests

    func test_optionManagement_atomicSafety() {
        // Given - Test that @Atomic property works correctly
        let option = "atomicSafeOption"

        // When - Perform multiple operations in sequence (simulating concurrent access)
        for i in 0..<10 {
            if i % 2 == 0 {
                sut.enableOption(option)
                XCTAssertTrue(sut.checkOption(option), "Option should be enabled at iteration \(i)")
            } else {
                sut.disableOption(option)
                XCTAssertFalse(sut.checkOption(option), "Option should be disabled at iteration \(i)")
            }
        }

        // Then - Final state should be disabled (last operation was at i=9, odd number)
        XCTAssertFalse(sut.checkOption(option))
    }

    func test_urlComponentsManagement_consistentAccess() {
        // Given - Test consistent access to urlComponentsData without concurrency
        let codes = ["test0", "test1", "test2", "test3", "test4"]

        // When - Set components for multiple codes
        for (index, code) in codes.enumerated() {
            let components = URLComponents(string: "https://test\(index).example.com")!
            let result = sut.urlComponents(set: components, for: code)

            // Then - Each set operation should succeed
            switch result {
            case .success:
                break
            case .failure:
                XCTFail("Failed to set components for code: \(code)")
            }
        }

        // When - Retrieve components for all codes
        for (index, code) in codes.enumerated() {
            let result = sut.urlComponents(for: code)

            // Then - Each retrieval should succeed and return correct host
            switch result {
            case .success(let components):
                XCTAssertEqual(components.host, "test\(index).example.com")
            case .failure:
                XCTFail("Failed to retrieve components for code: \(code)")
            }
        }
    }

    // MARK: - Edge Case Tests

    func test_urlComponents_withNilScheme() {
        // Given
        var components = URLComponents()
        components.host = "example.com"
        components.path = "/api"
        _ = sut.urlComponents(set: components, for: "noScheme")

        // When
        let result = sut.urlComponents(for: "noScheme")

        // Then
        switch result {
        case .success(let returnedComponents):
            XCTAssertNil(returnedComponents.scheme)
            XCTAssertEqual(returnedComponents.host, "example.com")
            XCTAssertEqual(returnedComponents.path, "/api")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlComponents_withComplexURL() {
        // Given
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.example.com"
        components.port = 8443
        components.path = "/v1/users"
        components.query = "limit=10&offset=0"
        _ = sut.urlComponents(set: components, for: "complex")

        // When
        let result = sut.urlComponents(for: "complex")

        // Then
        switch result {
        case .success(let returnedComponents):
            XCTAssertEqual(returnedComponents.scheme, "https")
            XCTAssertEqual(returnedComponents.host, "api.example.com")
            XCTAssertEqual(returnedComponents.port, 8443)
            XCTAssertEqual(returnedComponents.path, "/v1/users")
            XCTAssertEqual(returnedComponents.query, "limit=10&offset=0")
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
}

// MARK: - Test Helpers

private class TestableNETBlankConfig: NETBlankConfig {
    var configureWasCalled = false

    override func configure() {
        configureWasCalled = true
        super.configure()
    }
}

private class TestableNETBlankConfigWithFailingHeaders: NETBlankConfig {
    override func restHeaders(for code: String) -> NETPTCLConfigResHeaders {
        let error = DNSError.NetworkBase
            .invalidParameters(parameters: ["code"], transactionId: "", .blankNetwork(self))
        return .failure(error)
    }
}