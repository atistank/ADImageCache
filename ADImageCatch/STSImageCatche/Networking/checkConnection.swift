//
//  checkConnection.swift
//  ADImageCatch
//
//  Created by Apple on 5/23/18.
//  Copyright © 2018 Apple. All rights reserved.
//
import SystemConfiguration
import CoreTelephony
import Foundation
import Reachability

//MARK: - Check connection extension UIViewcontroller you want to use
extension DemoViewController {
    
    func checkNetworking(check: @escaping (StatusConnection) ->()){
        let reachability = Reachability()!
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                check(.ConnectionTypeWiFi)
            } else {
                print("Reachable via Cellular")
                let networkString = self.networkInfo.currentRadioAccessTechnology
                switch networkString {
                case CTRadioAccessTechnologyLTE :
                    check(.ConnectionType4G)
                case CTRadioAccessTechnologyWCDMA :
                    check(.ConnectionType3G)
                case CTRadioAccessTechnologyEdge :
                    check(.ConnectionType2G)
                default:
                    check(.ConnectionTypeUnknown)
                }
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
            check(.ConnectionTypeNone)
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
            check(.ConnectionTypeUnknown)
        }
    }
}
