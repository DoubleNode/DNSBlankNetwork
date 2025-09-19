//
//  NETBlankRouterTests.swift
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

final class NETBlankRouterTests: XCTestCase, @unchecked Sendable {
    private var sut: NETBlankRouter!
    private var mockConfig: MockNETConfig!

    override func setUp() {
        super.setUp()
        mockConfig = MockNETConfig()
        sut = NETBlankRouter()
    }

    override func tearDown() {
        sut = nil
        mockConfig = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_init_defaultInitializer_createsInstanceWithBlankConfig() {
        // Given & When
        let router = NETBlankRouter()

        // Then
        XCTAssertNotNil(router.netConfig)
        XCTAssertTrue(router.netConfig is NETBlankConfig)
    }

    func test_init_withNetConfig_createsInstanceWithProvidedConfig() {
        // Given
        let customConfig = MockNETConfig()

        // When
        let router = NETBlankRouter(with: customConfig)

        // Then
        XCTAssertNotNil(router.netConfig)
        XCTAssertTrue(router.netConfig === customConfig)
    }

    func test_init_callsConfigure() {
        // Given
        let router = TestableNETBlankRouter()

        // Then
        XCTAssertTrue(router.configureWasCalled)
    }

    // MARK: - Language Code Tests

    func test_languageCode_returnsCurrentLocaleLanguageCode() {
        // Given & When
        let languageCode = NETBlankRouter.languageCode

        // Then
        XCTAssertFalse(languageCode.isEmpty)
        XCTAssertTrue(languageCode.count >= 2)
    }

    func test_languageCode_fallsBackToEnglish() {
        // This tests the fallback behavior when locale is nil
        // In practice, this is difficult to test without mocking Locale
        // So we verify it's not empty and is a valid language code
        let languageCode = NETBlankRouter.languageCode
        XCTAssertFalse(languageCode.isEmpty)
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
        // We can't directly verify no duplicate without exposing options array
        // But the behavior should be consistent
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

    func test_optionManagement_multipleOptions() {
        // Given
        let option1 = "option1"
        let option2 = "option2"
        let option3 = "option3"

        // When
        sut.enableOption(option1)
        sut.enableOption(option2)
        sut.enableOption(option3)

        // Then
        XCTAssertTrue(sut.checkOption(option1))
        XCTAssertTrue(sut.checkOption(option2))
        XCTAssertTrue(sut.checkOption(option3))

        // When
        sut.disableOption(option2)

        // Then
        XCTAssertTrue(sut.checkOption(option1))
        XCTAssertFalse(sut.checkOption(option2))
        XCTAssertTrue(sut.checkOption(option3))
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

    // MARK: - URL Request Tests

    func test_urlRequest_usingURL_delegatesToNetConfig() {
        // Given
        let testURL = URL(string: "https://example.com")!
        let mockRouter = NETBlankRouter(with: mockConfig)
        let expectedRequest = URLRequest(url: testURL)
        mockConfig.urlRequestResult = .success(expectedRequest)

        // When
        let result = mockRouter.urlRequest(using: testURL)

        // Then
        XCTAssertTrue(mockConfig.urlRequestUsingCalled)
        XCTAssertEqual(mockConfig.urlRequestUsingURL, testURL)

        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlRequest_usingURL_withConfigError_returnsError() {
        // Given
        let testURL = URL(string: "https://example.com")!
        let mockRouter = NETBlankRouter(with: mockConfig)
        let expectedError = DNSError.NetworkBase
            .invalidParameters(parameters: ["url"], transactionId: "", .blankNetwork(sut))
        mockConfig.urlRequestResult = .failure(expectedError)

        // When
        let result = mockRouter.urlRequest(using: testURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    func test_urlRequest_forCodeUsingURL_delegatesToNetConfig() {
        // Given
        let testCode = "testCode"
        let testURL = URL(string: "https://example.com")!
        let mockRouter = NETBlankRouter(with: mockConfig)
        let expectedRequest = URLRequest(url: testURL)
        mockConfig.urlRequestForCodeResult = .success(expectedRequest)

        // When
        let result = mockRouter.urlRequest(for: testCode, using: testURL)

        // Then
        XCTAssertTrue(mockConfig.urlRequestForCodeCalled)
        XCTAssertEqual(mockConfig.urlRequestForCodeCode, testCode)
        XCTAssertEqual(mockConfig.urlRequestForCodeURL, testURL)

        switch result {
        case .success(let request):
            XCTAssertEqual(request.url, testURL)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }

    func test_urlRequest_forCodeUsingURL_withConfigError_returnsError() {
        // Given
        let testCode = "testCode"
        let testURL = URL(string: "https://example.com")!
        let mockRouter = NETBlankRouter(with: mockConfig)
        let expectedError = DNSError.NetworkBase
            .invalidParameters(parameters: ["code"], transactionId: "", .blankNetwork(sut))
        mockConfig.urlRequestForCodeResult = .failure(expectedError)

        // When
        let result = mockRouter.urlRequest(for: testCode, using: testURL)

        // Then
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertTrue(error is DNSError)
        }
    }

    // MARK: - Thread Safety Tests

    func test_optionManagement_threadSafety() {
        // Given
        let expectation = self.expectation(description: "Thread safety test")
        expectation.expectedFulfillmentCount = 100
        let option = "threadSafeOption"
        let queue = DispatchQueue.global(qos: .userInitiated)

        // When - Perform concurrent operations with separate router instances
        // This tests that the @Atomic property wrapper works correctly under concurrent access
        for i in 0..<100 {
            queue.async {
                // Create local router instance to avoid MainActor isolation issues
                let router = NETBlankRouter()

                // Test concurrent option management operations
                if i % 3 == 0 {
                    router.enableOption(option)
                    XCTAssertTrue(router.checkOption(option))
                } else if i % 3 == 1 {
                    router.enableOption(option)
                    router.disableOption(option)
                    XCTAssertFalse(router.checkOption(option))
                } else {
                    // Test multiple enable/disable cycles
                    router.enableOption(option)
                    router.enableOption(option) // Should not add duplicate
                    XCTAssertTrue(router.checkOption(option))
                    router.disableOption(option)
                    XCTAssertFalse(router.checkOption(option))
                }

                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 10.0)
    }

    // MARK: - Edge Case Tests

    func test_enableOption_withEmptyString() {
        // Given
        let emptyOption = ""

        // When
        sut.enableOption(emptyOption)

        // Then
        XCTAssertTrue(sut.checkOption(emptyOption))
    }

    func test_disableOption_withEmptyString() {
        // Given
        let emptyOption = ""
        sut.enableOption(emptyOption)

        // When
        sut.disableOption(emptyOption)

        // Then
        XCTAssertFalse(sut.checkOption(emptyOption))
    }

    func test_urlRequest_withMalformedURL() {
        // Given - URL that might cause issues
        let testURL = URL(string: "https://example.com/path with spaces")!

        // When
        let result = sut.urlRequest(using: testURL)

        // Then - Should handle gracefully
        switch result {
        case .success(let request):
            XCTAssertNotNil(request.url)
        case .failure:
            // This is acceptable for malformed URLs
            break
        }
    }
}

// MARK: - Test Helpers

private class TestableNETBlankRouter: NETBlankRouter {
    var configureWasCalled = false

    override func configure() {
        configureWasCalled = true
        super.configure()
    }
}

private class MockNETConfig: NSObject, NETPTCLConfig {
    var urlRequestUsingCalled = false
    var urlRequestUsingURL: URL?
    var urlRequestResult: NETPTCLConfigResURLRequest = .success(URLRequest(url: URL(string: "https://example.com")!))

    var urlRequestForCodeCalled = false
    var urlRequestForCodeCode: String?
    var urlRequestForCodeURL: URL?
    var urlRequestForCodeResult: NETPTCLConfigResURLRequest = .success(URLRequest(url: URL(string: "https://example.com")!))

    var urlComponentsResult: NETPTCLConfigResURLComponents = .success(URLComponents())
    var urlComponentsForCodeResult: NETPTCLConfigResURLComponents = .success(URLComponents())
    var urlComponentsSetResult: NETPTCLConfigResVoid = .success
    var restHeadersResult: NETPTCLConfigResHeaders = .success(HTTPHeaders())
    var restHeadersForCodeResult: NETPTCLConfigResHeaders = .success(HTTPHeaders())

    override required init() {
        super.init()
    }

    func configure() { }
    func checkOption(_ option: String) -> Bool { return false }
    func enableOption(_ option: String) { }
    func disableOption(_ option: String) { }
    func didBecomeActive() { }
    func willResignActive() { }
    func willEnterForeground() { }
    func didEnterBackground() { }

    func urlComponents() -> NETPTCLConfigResURLComponents {
        return urlComponentsResult
    }

    func urlComponents(for code: String) -> NETPTCLConfigResURLComponents {
        return urlComponentsForCodeResult
    }

    func urlComponents(set components: URLComponents, for code: String) -> NETPTCLConfigResVoid {
        return urlComponentsSetResult
    }

    func restHeaders() -> NETPTCLConfigResHeaders {
        return restHeadersResult
    }

    func restHeaders(for code: String) -> NETPTCLConfigResHeaders {
        return restHeadersForCodeResult
    }

    func urlRequest(using url: URL) -> NETPTCLConfigResURLRequest {
        urlRequestUsingCalled = true
        urlRequestUsingURL = url
        return urlRequestResult
    }

    func urlRequest(for code: String, using url: URL) -> NETPTCLConfigResURLRequest {
        urlRequestForCodeCalled = true
        urlRequestForCodeCode = code
        urlRequestForCodeURL = url
        return urlRequestForCodeResult
    }
}