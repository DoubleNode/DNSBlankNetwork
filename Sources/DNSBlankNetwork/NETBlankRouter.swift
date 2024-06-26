//
//  NETBlankRouter.swift
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

// Protocol Return Types
public typealias NETBlankRouterRtnVoid = Void

// Protocol Result Types
public typealias NETBlankRouterResVoid = Result<NETBlankRouterRtnVoid, Error>

open class NETBlankRouter: NSObject, NETPTCLRouter {
    static public var languageCode: String {
        DNSCore.languageCode
    }
    
    public var netConfig: NETPTCLConfig
    @Atomic private var options: [String] = []
    
    override public required init() {
        self.netConfig = NETBlankConfig()
        super.init()
        self.configure()
    }
    public required init(with netConfig: NETPTCLConfig) {
        self.netConfig = netConfig
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

    // MARK: - Network Router Logic (Public) -
    open func urlRequest(using url: URL) -> NETPTCLRouterResURLRequest {
        let result = netConfig.urlRequest(using: url)
        if case .failure(let error) = result {
            DNSCore.reportError(error)
            return .failure(error)
        }
        let urlRequest = try! result.get()
        return .success(urlRequest)
    }
    open func urlRequest(for code: String,
                         using url: URL) -> NETPTCLRouterResURLRequest {
        let result = netConfig.urlRequest(for: code, using: url)
        if case .failure(let error) = result {
            DNSCore.reportError(error)
            return .failure(error)
        }
        let urlRequest = try! result.get()
        return .success(urlRequest)
    }
}
