//
//  NetworkMonitor.swift
//  Barman
//
//  Created by JanZelaznog on 27/02/23.
//

import Foundation
import Network
import UIKit

class NetworkMonitor: NSObject {
    
    var internetStatus = false
    var internetType = ""
    
    static let instance = NetworkMonitor()
    
    override private init() {
        super.init()
        startDetection()
    }
    
    func startDetection() {
        let monitor = NWPathMonitor()
        monitor.start(queue:DispatchQueue.global())
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.internetStatus = true
                if path.usesInterfaceType(.wifi) {
                    self.internetType = "WiFi"
                }
                else {
                    self.internetType = "no WiFi"
                }
            }
            else {
                self.internetStatus = false
                self.internetType = ""
            }
        }
    }
}
