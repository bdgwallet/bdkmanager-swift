//
//  BDKManagerExampleApp.swift
//  BDKManagerExampleApp
//
//  Created by Daniel Nordh on 3/18/22.
//

import SwiftUI
import BDKManager

@main
struct BDKManagerExampleApp: App {
    @ObservedObject var bdkManager: BDKManager
    
    init() {
        let descriptor = "wpkh([c258d2e4/84h/1h/0h]tpubDDYkZojQFQjht8Tm4jsS3iuEmKjTiEGjG6KnuFNKKJb5A6ZUCUZKdvLdSDWofKi4ToRCwb9poe1XdqfUnP4jaJjCB2Zwv11ZLgSbnZSNecE/0/*)"
        let network = Network.testnet
        let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil)
        let database = Database(type: DatabaseType.memory, path: nil, treeName: nil)
        
        bdkManager = BDKManager.init(descriptor: descriptor, network: network, syncSource: syncSource, database: database)
    }
    
    var body: some Scene {
        WindowGroup {
            WalletView()
                .environmentObject(bdkManager)
        }
    }
}
