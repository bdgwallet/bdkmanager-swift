# BDGWalletBDK

This package makes it easier to work with [bdk-swift](https://github.com/bitcoindevkit/bdk-swift) on iOS by providing good defaults, simple setup and modern SwiftUI compatible convenience methods and parameters.

## Installation

Add the github repository (https://github.com/BDGWallet/bdgw-bdk-swift) as a dependency in your Xcode project. You can then import and use the `BDGWalletBDK` library in your Swift code.

```swift
import BDGWalletBDK
```

## Setup

To initalise a bdkManager with BDGWalletBDK and set up the basics:

```swift
let descriptor = "wpkh([c258d2e4/84h/1h/0h]tpubDDYkZojQFQjht8Tm4jsS3iuEmKjTiEGjG6KnuFNKKJb5A6ZUCUZKdvLdSDWofKi4ToRCwb9poe1XdqfUnP4jaJjCB2Zwv11ZLgSbnZSNecE/0/*)" // set descriptor from private key
let network = Network.testnet // set bitcoin, testnet, signet or regtest
let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil) // set esplora or electrum, can take customUrl
let database = Database(type: DatabaseType.memory, path: nil, treeName: nil) // set memory or disk, optional path and tree parameters
        
let bdkManager = BDGWalletBDK.init(descriptor: descriptor, network: network, syncSource: syncSource, database: database)     
```

## Usage

Here's a quick example of creating a SwiftUI app where the bdkManager is an @ObservedObject, which enables the ContentView to automatically update depending on the syncState:

WalletApp.swift
```swift
import SwiftUI
import BDGWalletBDK

@main
struct DailyWalletApp: App {
    @ObservedObject var bdkManager: BDGWalletBDK
    
    init() {
        let descriptor = "wpkh([c258d2e4/84h/1h/0h]tpubDDYkZojQFQjht8Tm4jsS3iuEmKjTiEGjG6KnuFNKKJb5A6ZUCUZKdvLdSDWofKi4ToRCwb9poe1XdqfUnP4jaJjCB2Zwv11ZLgSbnZSNecE/0/*)" // set descriptor from private key
        let network = Network.testnet // set bitcoin, testnet, signet or regtest
        let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil) // set esplora or electrum, can take customUrl
        let database = Database(type: DatabaseType.memory, path: nil, treeName: nil) // set memory or disk, optional path and tree parameters
        
        bdkManager = BDGWalletBDK.init(descriptor: descriptor, network: network, syncSource: syncSource, database: database)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bdkManager)
        }
    }
}
```

ContentView.swift
```swift
import SwiftUI
import BDGWalletBDK

struct ContentView: View {
    @EnvironmentObject var bdkManager: BDGWalletBDK
    @EnvironmentObject var ldkManager: LDKManager
    var body: some View {
        Text("Hello, world!")
            .padding()
        switch bdkManager.syncState {
        case .synced:
            Text("Balance: \(bdkManager.balance)")
        case .syncing:
            Text("Syncing node")
        default:
            Text("Node not synced")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
```
