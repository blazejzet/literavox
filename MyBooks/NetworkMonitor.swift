//
//  NetworkMonitor.swift
//  Remmed Streaming App
//
//  Created by Damian Skarżyński on 16/02/2021.
//

import Foundation
import Network


@objc class NetworkMonitor: NSObject,ObservableObject {
    @Published @objc dynamic var isConnectedToWifi:Bool = true
    
    static let shared = NetworkMonitor()
    
    override init() {
        super.init()
        startMonitoring()
    }

    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    private var status: NWPath.Status = .requiresConnection
    var isReachable: Bool { status == .satisfied }
    var isReachableOnCellular: Bool = true

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive
            if path.status == .satisfied {
                print("We're connected to wifi!")
                DispatchQueue.main.async {
                    self?.isConnectedToWifi = true
                }
                
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                    self?.isConnectedToWifi = false
                }
            }
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
    
    func getWifiConnectionStatus(cb: @escaping ()->Void){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                cb()
        }
    }
    @objc func onChangeConn(){
        if self.status == .satisfied{
            print("dziala net")
        }
    }
    deinit {
        self.stopMonitoring()
    }
}
