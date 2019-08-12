//
//  NetworkAvailability.swift
//  ImageCachingLibrary
//
//  Created by Aman Thakur on 8/5/19.
//  Copyright © 2019 Aman Thakur. All rights reserved.
//

import SystemConfiguration

class NetworkAvailability : NSObject{
    
    enum NetworkStatus {
        case Available
        case Unavailable
    }
    
    var isAvailable : NetworkStatus {
        get {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return .Unavailable
            }
            
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return .Unavailable
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            
            return (isReachable && !needsConnection) ? .Available : .Unavailable
        }
    }
}
