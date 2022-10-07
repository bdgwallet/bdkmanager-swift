# BDK Manager for iOS / Swift

This package makes it easier to work with [bdk-swift](https://github.com/bitcoindevkit/bdk-swift) on iOS by providing good defaults, simple setup and modern SwiftUI compatible convenience functions and variables.  

It is still a work in progress and not ready for production.

## Installation

Add this github repository https://github.com/bdgwallet/bdkmanager-swift as a dependency in your Xcode project.   
You can then import and use the `BDKManager` library in your Swift code.

```swift
import BDKManager
```

## Setup

To initalise a BDKManager you need to tell it what bitcoin `Network` it should use, what `SyncSource` the wallet is going to connect to for blockchain data, and where the `Database` should store information. The two supported sync source types by BDK on iOS at the moment is Esplora and Electrum API servers. You can specify a custom URL to a private server, or if none is supplied it will default to the public [Blockstream APIs](https://github.com/Blockstream/esplora/blob/master/API.md).

```swift
let network = Network.testnet // .bitcoin, .testnet, .signet or .regtest
let syncSource = SyncSource(type: SyncSourceType.esplora, customUrl: nil) // .esplora or .electrum, optional customUrl
let database = Database(type: DatabaseType.memory, path: nil, treeName: nil) // .memory or .disk, optional path and tree parameters
        
bdkManager = BDKManager.init(network: network, syncSource: syncSource, database: database)   
```

## Load wallet

To create a new extended private key, descriptor and load the wallet:

```swift
do {    
    let wordCount = WordCount.words12 // .words12, .words24
    let mnemonic = generateMnemonic(wordCount: wordCount)
    let descriptorType = DescriptorType.singleKey_tr86 // .singleKey_tr86, .singleKey_wpkh84
    let descriptor = bdkManager.descriptorFromMnemonic(
        descriptorType: descriptorType,
        mnemonic: mnemonic,
        password: nil) // optional password
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

## Sync

The wallet can either be synced manually by calling `sync()`, or at regular intervals by using `startSyncRegularly` and `stopSyncRegularly`.
On every sync, the @Published parameters `.balance` and `.transactions` are updated, which means they automatically trigger updates in SwiftUI.

```swift
bdkManager.sync() // Will sync once

bdkManager.startSyncRegularly(interval: 120) // Will sync immediately, then every 120 seconds
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
            let wordCount = WordCount.words12 // .words12, .words24
            let mnemonic = generateMnemonic(wordCount: wordCount)
            let descriptorType = DescriptorType.singleKey_tr86 // .singleKey_tr86, .singleKey_wpkh84
            let descriptor = bdkManager.descriptorFromMnemonic(
                descriptorType: descriptorType,
                mnemonic: mnemonic,
                password: nil) // optional password
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
                Text("Balance: \(bdkManager.balance.total.description)")
            case .syncing:
                Text("Balance: Syncing")
            default:
                Text("Balance: Not synced")
            }
            Text(bdkManager.wallet?.getAddress(addressIndex: AddressIndex.new) ?? "-")
        }.onAppear {
            bdkManager.sync() // to sync once
            //bdkManager.startSyncRegularly(interval: 120) // to sync immediately, then every 120 seconds
        }.onDisappear {
            //bdkManager.stopSyncRegularly() // if startSyncRegularly was used
        }
    }
}
```

## Public variables

BDK Manager has the following `@Published` public variables, meaning they can be observed and lead to updates in SwiftUI:
```swift
.wallet: Wallet?
.balance: Balance
.transactions: [TransactionDetails]
.walletState // .empty, .loading, .loaded, .failed
.syncState // .empty, .syncing, .synced, .failed
```

## Public functions

BDK Manager has the following public functions:
```swift
init(network: Network, syncSource: SyncSource, database: Database)
descriptorFromMnemonic(descriptorType: DescriptorType, mnemonic: String, password: String?) -> String?
descriptorFromXprv(descriptorType: DescriptorType, xprv: String) -> String
loadWallet(descriptor: String)
sync()
startSyncRegularly(interval: TimeInterval)
stopSyncRegularly()
sendBitcoin(recipient: String, amount: UInt64, feeRate: Float?) -> Transaction?
```

Since the wallet is a BDK Wallet, the corresponding functions are also available on .wallet:
```swift
getAddress(addressIndex: AddressIndex) -> String
getLastUnusedAddress()  -> String
getBalance() throws -> Balance
sign( psbt: PartiallySignedBitcoinTransaction ) throws
getTransactions() throws -> [Transaction]
getNetwork()  -> Network
broadcast( psbt: PartiallySignedBitcoinTransaction ) throws -> Transaction
```
