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
                Text("Balance: \(bdkManager.balance)")
            case .syncing:
                Text("Balance: Syncing")
            default:
                Text("Balance: Not synced")
            }
            Text(bdkManager.wallet?.getNewAddress() ?? "-")
        }.onAppear {
            bdkManager.sync()
        }
    }
}
