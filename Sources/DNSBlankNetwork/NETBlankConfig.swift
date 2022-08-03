//
//  NETBlankConfig.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBlankNetwork
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import AtomicSwift
import Alamofire
import DNSCore
import DNSError
import DNSProtocols
import Foundation

open class NETBlankConfig: NSObject, NETPTCLConfig {
    static public var languageCode: String {
        DNSCore.languageCode
    }
    
    @Atomic private var options: [String] = []
    private var urlComponentsData: [String: URLComponents] = [:]

    override public required init() {
        super.init()
        self.configure()
    }
    open func configure() { }

    public func checkOption(_ option: String) -> Bool {
        return self.options.contains(option)
    }
    open func enableOption(_ option: String) {
        guard !self.checkOption(option) else { return }
        self.options.append(option)
    }
    open func disableOption(_ option: String) {
        self.options.removeAll { $0 == option }
    }

    // MARK: - UIWindowSceneDelegate methods
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    open func didBecomeActive() { }
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    open func willResignActive() { }
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    open func willEnterForeground() { }
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    open func didEnterBackground() { }

    // MARK: - Network Config Logic (Public) -
    open func urlComponents() -> NETPTCLConfigResURLComponents {
        let code = self.urlComponentsData.keys.first ?? ""
        return self.urlComponents(for: code)
    }
    open func urlComponents(for code: String) -> NETPTCLConfigResURLComponents {
        let code = self.urlComponentsData.keys.first ?? ""
        guard let retval = self.urlComponentsData[code] else {
            let error = DNSError.NetworkBase
                .invalidParameter(parameter: "code",
                                  DNSCodeLocation.blankNetwork(self, "\(#file),\(#line),\(#function)"))
            DNSCore.reportError(error)
            return .failure(error)
        }
        return .success(retval)
    }
    open func urlComponents(set components: URLComponents, for code: String) -> NETPTCLConfigResVoid {
        guard !code.isEmpty else {
            let error = DNSError.NetworkBase
                .invalidParameter(parameter: "code",
                                  DNSCodeLocation.blankNetwork(self, "\(#file),\(#line),\(#function)"))
            DNSCore.reportError(error)
            return .failure(error)
        }
        self.urlComponentsData[code] = components
        return .success
    }
    open func restHeaders() -> NETPTCLConfigResHeaders {
        let code = self.urlComponentsData.keys.first ?? ""
        return self.restHeaders(for: code)
    }
    open func restHeaders(for code: String) -> NETPTCLConfigResHeaders {
        let headers: HTTPHeaders = []
        return .success(headers)
    }
}
