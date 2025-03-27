//
//  CheckNetwrok.swift
//  Platforma
//
//  Created by Daniil Razbitski on 27/03/2025.
//

import Combine
import Network

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "monitoring")
    @Published var status: NWPath.Status = .satisfied

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.status = path.status
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
