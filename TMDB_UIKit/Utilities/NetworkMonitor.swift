//
//  NetworkMonitor.swift
//  TMDB_UIKit
//
//  Created by Ostap Artym on 02.07.2024.
//

import Foundation
import Network

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private var monitor: NWPathMonitor
    private var queue: DispatchQueue
    private(set) var isActive: Bool = false
    private(set) var isExpensive: Bool = false
    private(set) var isConstrained: Bool = false
    private(set) var connectionType: NWInterface.InterfaceType = .other
    
    var pathUpdateHandler: ((NWPath) -> Void)?
    
    init() {
        monitor = NWPathMonitor()
        queue = DispatchQueue(label: "Monitor")
        
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isActive = path.status == .satisfied
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
                
                let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]
                self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
                
                self.pathUpdateHandler?(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
