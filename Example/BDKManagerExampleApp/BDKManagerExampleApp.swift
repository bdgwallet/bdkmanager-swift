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
        // Define BDKManager init options
        let network = Network.testnet // set bitcoin, testnet, signet or regtest
        let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil) // set esplora or electrum, can take customUrl
        let database = Database(type: DatabaseType.memory, path: nil, treeName: nil) // set memory or disk, optional path and tree parameters
        
        // Initialize a BDKManager instance
        bdkManager = BDKManager.init(network: network, syncSource: syncSource, database: database)
        
        // Load a singlekey wallet from a newly generated private key
        do {
            let wordCount = WordCount.words12 // 12, 24
            let extendedKeyInfo = try bdkManager.generateExtendedKey(wordCount: wordCount, password: nil)
            let descriptor = bdkManager.createDescriptor(descriptorType: DescriptorType.singleKey_wpkh84, extendedKeyInfo: extendedKeyInfo)
            bdkManager.loadWallet(descriptor: descriptor)
        } catch let error {
            print(error)
        }
        
        // Or load a wallet from an existing descriptor
        //let descriptor = "wpkh(tprv8ZgxMBicQKsPeSitUfdxhsVaf4BXAASVAbHypn2jnPcjmQZvqZYkeqx7EHQTWvdubTSDa5ben7zHC7sUsx4d8tbTvWdUtHzR8uhHg2CW7MT/*)"
        //bdkManager.loadWallet(descriptor: descriptor)
    }
    
    var body: some Scene {
        WindowGroup {
            WalletView()
                .environmentObject(bdkManager)
        }
    }
}
