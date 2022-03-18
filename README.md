# BDKManager for iOS / Swift

This package makes it easier to work with [bdk-swift](https://github.com/bitcoindevkit/bdk-swift) on iOS by providing good defaults, simple setup and modern SwiftUI compatible convenience methods and parameters.  

It is still a work in progress and not ready for production.

## Installation

Add this github repository https://github.com/BDGWallet/bdkmanager-swift as a dependency in your Xcode project.   
You can then import and use the `BDKManager` library in your Swift code.

```swift
import BDKManager
```

## Setup

To initalise a BDKManager and set up the basics:

```swift
let descriptor = "wpkh([c258d2e4/84h/1h/0h]tpubDDYkZojQFQjht8Tm4jsS3iuEmKjTiEGjG6KnuFNKKJb5A6ZUCUZKdvLdSDWofKi4ToRCwb9poe1XdqfUnP4jaJjCB2Zwv11ZLgSbnZSNecE/0/*)" // set descriptor from private key
let network = Network.testnet // bitcoin, testnet, signet or regtest
let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil) // esplora or electrum, can take customUrl
let database = Database(type: DatabaseType.memory, path: nil, treeName: nil) // memory or disk, optional path and tree parameters
        
let bdkManager = BDKManager.init(descriptor: descriptor, network: network, syncSource: syncSource, database: database)     
```

## Usage

Here's a basic but complete example of creating a SwiftUI app where the bdkManager is an @ObservedObject, which enables the ContentView to automatically update depending on the syncState:

**WalletApp.swift**
```swift
import SwiftUI
import BDKManager

@main
struct WalletApp: App {
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
            ContentView()
                .environmentObject(bdkManager)
        }
    }
}
```

**ContentView.swift**
```swift
import SwiftUI
import BDKManager

struct ContentView: View {
    @EnvironmentObject var bdkManager: BDKManager
    
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
```
