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
let network = Network.testnet // set bitcoin, testnet, signet or regtest
let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil) // set esplora or electrum, can take customUrl
let database = Database(type: DatabaseType.memory, path: nil, treeName: nil) // set memory or disk, optional path and tree parameters
        
bdkManager = BDKManager.init(network: network, syncSource: syncSource, database: database)   
```

## Load wallet

To create a new extended private key, descriptor and load the wallet:

```swift
do {
    let wordCount = WordCount.words12 // 12, 24
    let extendedKeyInfo = try bdkManager.generateExtendedKey(wordCount: wordCount, password: nil)
    let descriptor = bdkManager.createDescriptor(descriptorType: DescriptorType.singleKey_wpkh84, extendedKeyInfo: extendedKeyInfo)
    bdkManager.loadWallet(descriptor: descriptor)
} catch let error {
    print(error)
}  
```

To load  wallet from an existing descriptor:

```swift
let descriptor = "wpkh(tprv8ZgxMBicQKsPeSitUfdxhsVaf4BXAASVAbHypn2jnPcjmQZvqZYkeqx7EHQTWvdubTSDa5ben7zHC7sUsx4d8tbTvWdUtHzR8uhHg2CW7MT/*)"
bdkManager.loadWallet(descriptor: descriptor) 
```

## Syncing

The wallet can either be synced manually by calling `sync()`, or at regular intervals by using `startSyncRegularly` and `stopSyncRegularly`.
On every sync, the @Published parameters `.balance` and `.transactions` are updated, which means they automatically trigger updates in SwiftUI.

```swift
bdkManager.sync() // Will sync once

bdkManager.startSyncRegularly(interval: 120) // Will sync every 120 seconds
bdkManager.stopSyncRegularly() // Will stop the regular sync
```

## Example

A working SwiftUI example app is included in the repo. It has very basic functionality of showing the balance for a descriptor address. In this case the bdkManager is an @ObservedObject, which enables the WalletView to automatically update depending on bdkManager.syncState. The two files required:

**WalletApp.swift**
```swift
import SwiftUI
import BDKManager

@main
struct WalletApp: App {
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
```

**WalletView.swift**
```swift
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
            bdkManager.sync() // to sync once
            //bdkManager.startSyncRegularly(interval: 120) // to sync every 120 seconds
        }.onDisappear {
            //bdkManager.stopSyncRegularly() // if startSyncRegularly was used
        }
    }
}
```
