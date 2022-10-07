//
//  WalletView.swift
//  BDKManagerExampleApp
//
//  Created by Daniel Nordh on 3/18/22.
//

import SwiftUI
import BDKManager

struct WalletView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
    var body: some View {
        VStack (spacing: 50){
            Text("Hello, wallet!")
            switch bdkManager.syncState {
            case .synced:
                Text("Balance: \(bdkManager.balance.total.description)")
            case .syncing:
                Text("Balance: Syncing")
            default:
                Text("Balance: Not synced")
            }
            Text(bdkManager.wallet?.getAddress(addressIndex: AddressIndex.new) ?? "-")
        }.onAppear {
            bdkManager.sync() // to sync once
            //bdkManager.startSyncRegularly(interval: 120) // to sync every 120 seconds
        }.onDisappear {
            //bdkManager.stopSyncRegularly() // if startSyncRegularly was used
        }
    }
}
