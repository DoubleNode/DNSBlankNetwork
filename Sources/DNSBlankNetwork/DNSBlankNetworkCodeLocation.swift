//
//  DNSBlankNetworkCodeLocation.swift
//  DoubleNode Swift Framework (DNSFramework) - DNSBlankNetwork
//
//  Created by Darren Ehlers.
//  Copyright © 2020 - 2016 DoubleNode.com. All rights reserved.
//

import DNSError

public extension DNSCodeLocation {
    typealias blankNetwork = DNSBlankNetworkCodeLocation
}
open class DNSBlankNetworkCodeLocation: DNSCodeLocation, @unchecked Sendable {
    override open class var domainPreface: String { "com.doublenode.blankNetwork." }
}
