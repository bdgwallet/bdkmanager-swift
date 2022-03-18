//  Created by Daniel Nordh on 2/17/22.
//
//  The following repos have been useful in the creation of this code:
//  - BDKSwiftSample by FuturePaul, https://github.com/futurepaul/BdkSwiftSample, which in turn was inspired by
//  - BDK Android Demo Wallet by Thunderbiscuit, https://github.com/thunderbiscuit/bitcoindevkit-android-sample-app

import Foundation
import BitcoinDevKit

public class BDGWalletBDK: ObservableObject {
    @Published var wallet: Wallet?
    @Published var balance: UInt64 = 0
    @Published var transactions: [BitcoinDevKit.Transaction] = []
    @Published var walletState = WalletState.empty {
        didSet {
            switch walletState {
            case .empty:
                print("Wallet is not initialized")
            case .initializing:
                print("Wallet is initializing")
            case .initialized(let wallet):
                print("Wallet is initialized")
                self.wallet = wallet
                self.sync()
            case .failed(let error):
                print("Error initializing wallet:" + error.localizedDescription)
            }
        }
    }
    @Published var syncState = SyncState.empty {
        didSet {
            switch syncState {
            case .empty:
                print("Node is not initialized")
            case .syncing:
                print("Node is syncing")
            case .synced:
                print("Node is synced")
                self.getBalance()
                self.getTransactions()
            case .failed(let error):
                print("Error, node syncing failed: " + error.localizedDescription)
            }
        }
    }
    
    private let bdkQueue = DispatchQueue (label: "bdkQueue", qos: .userInitiated)
    
    public init(descriptor: String, network: Network, syncSource: SyncSource, database: Database) {
        self.walletState = WalletState.initializing
        let databaseConfig = databaseConfig(database: database)
        let blockchainConfig = blockchainConfig(network: network, syncSource: syncSource)
        initializeWallet(descriptor: descriptor, changeDescriptor: nil, network: network, databaseConfig: databaseConfig, blockchainConfig: blockchainConfig)
    }
    
    private func blockchainConfig(network: Network, syncSource: SyncSource) -> BlockchainConfig {
        var blockchainConfig: BlockchainConfig
        switch syncSource.type {
        case .esplora:
            let defaultUrl = network == Network.bitcoin ? ESPLORA_URL_BITCOIN : ESPLORA_URL_TESTNET
            let url = syncSource.customUrl != nil ? syncSource.customUrl : defaultUrl
            let esploraConfig = EsploraConfig.init(baseUrl: url!, proxy: nil, timeoutRead: 1000, timeoutWrite: 1000, stopGap: 20)
            blockchainConfig = BlockchainConfig.esplora(config: esploraConfig)
        case .electrum:
            let defaultUrl = network == Network.bitcoin ? ELECTRUM_URL_BITCOIN : ELECTRUM_URL_TESTNET
            let url = syncSource.customUrl != nil ? syncSource.customUrl : defaultUrl
            let electrumConfig = ElectrumConfig(url: url!, socks5: nil, retry: 5, timeout: nil, stopGap: 10)
            blockchainConfig = BlockchainConfig.electrum(config: electrumConfig)
        }
        return blockchainConfig
    }
    
    private func databaseConfig(database: Database) -> DatabaseConfig {
        var databaseConfig: DatabaseConfig
        switch database.type {
        case .memory:
            databaseConfig = DatabaseConfig.memory(junk: "")
        case .disk:
            let path = database.path != nil ? database.path : ""
            let treeName = database.treeName != nil ? database.treeName : ""
            let sledDbConfig = SledDbConfiguration(path: path!, treeName: treeName!)
            databaseConfig = DatabaseConfig.sled(config: sledDbConfig)
        }
        return databaseConfig
    }
    
    private func initializeWallet(descriptor: String, changeDescriptor: String?, network: Network, databaseConfig: DatabaseConfig, blockchainConfig: BlockchainConfig) {
        do {
            let wallet = try Wallet.init(descriptor: descriptor, changeDescriptor: nil, network: network, databaseConfig: databaseConfig, blockchainConfig: blockchainConfig)
            self.walletState = WalletState.initialized(wallet)
        } catch let error {
            self.walletState = WalletState.failed(error)
        }
    }
    
    public func sync() {
        switch self.walletState {
        case .initialized(let wallet):
            self.syncState = SyncState.syncing
            bdkQueue.async {
                do {
                    let progress = Progress() // Progress for Esplora/Electrum is not available, but object is required by the wallet.sync function.
                    try wallet.sync(progressUpdate: progress, maxAddressParam: nil)
                    DispatchQueue.main.async {
                        self.syncState = SyncState.synced
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.syncState = SyncState.failed(error)
                    }
                }
            }
        default:
            print("Could not sync, wallet not initialized")
        }
    }
    
    private func getBalance() {
        do {
            self.balance = try self.wallet!.getBalance()
            print("Balance is: " + self.balance.description)
        } catch let error {
            print("Error getting wallet balance: " + error.localizedDescription)
        }
    }
    
    private func getTransactions() {
        do {
            let transactions = try self.wallet!.getTransactions()
            self.transactions = transactions.sorted(by: {
                switch $0 {
                case .confirmed(_, let confirmation_a):
                    switch $1 {
                    case .confirmed(_, let confirmation_b): return confirmation_a.timestamp > confirmation_b.timestamp
                    default: return false
                    }
                default:
                    switch $1 {
                    case .unconfirmed(_):
                        return true
                    default: return false
                    }
                }
            })
            print("Transaction count: " + self.transactions.count.description)
        } catch let error {
            print("Error getting transactions: " + error.localizedDescription)
        }
    }
}

// Structs, Classes and enums

public typealias Network = BitcoinDevKit.Network

public struct SyncSource {
    public let type: SyncSourceType
    public let customUrl: String?
    
    public init(type: SyncSourceType, customUrl: String?) {
        self.type = type
        self.customUrl = customUrl
    }
}

public enum SyncSourceType {
    case esplora
    case electrum
}

public struct Database {
    public let type: DatabaseType
    public let path: String?
    public let treeName: String?
    
    public init(type: DatabaseType, path: String?, treeName: String?) {
        self.type = type
        self.path = path
        self.treeName = treeName
    }
}

public enum DatabaseType {
    case memory
    case disk
}

class Progress : BdkProgress {
    var value = Float()
    func update(progress: Float, message: String?) {
        value = progress
        print("progress", progress, message as Any)
    }
}

enum SyncState {
    case empty
    case syncing
    case synced
    case failed(Error)
}

enum WalletState {
    case empty
    case initializing
    case initialized(Wallet)
    case failed(Error)
}

// Defeault public api URLs

let ESPLORA_URL_BITCOIN = "https://blockstream.info/api/"
let ESPLORA_URL_TESTNET = "https://blockstream.info/testnet/api"

let ELECTRUM_URL_BITCOIN = "ssl://electrum.blockstream.info:60001"
let ELECTRUM_URL_TESTNET = "ssl://electrum.blockstream.info:60002"

