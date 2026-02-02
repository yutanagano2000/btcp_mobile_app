//
//  Web3AuthManager.swift
//  btcp_mobile_app
//
//  Created on 2025/01/19.
//

import Combine
import CryptoKit
import FetchNodeDetails
import Foundation
import Web3Auth
import web3swift
import Web3Core
import BigInt

/// Web3Auth接続エラー
enum Web3AuthManagerError: Error, LocalizedError {
    case notInitialized
    case loginFailed(String)
    case noPrivateKey

    var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Web3Authが初期化されていません"
        case .loginFailed(let message):
            return "ログイン失敗: \(message)"
        case .noPrivateKey:
            return "秘密鍵が取得できません"
        }
    }
}

/// Web3Auth接続を管理するクラス
@MainActor
final class Web3AuthManager: ObservableObject {
    static let shared = Web3AuthManager()

    // MARK: - Properties

    private var web3Auth: Web3Auth?

    /// Web3Auth Client ID（環境変数から取得）
    private var clientId: String {
        AppEnvironment.web3AuthClientId
    }

    /// Firebase Custom Verifier名（環境変数から取得）
    private var verifierName: String {
        AppEnvironment.web3AuthVerifierName
    }

    /// リダイレクトURL（環境変数から取得）
    private var redirectUrl: String {
        AppEnvironment.web3AuthRedirectUrl
    }

    /// ウォレットアドレス
    @Published private(set) var walletAddress: String?

    /// 秘密鍵（セキュアに保管すること）
    private(set) var privateKey: String?

    /// ユーザー情報
    @Published private(set) var userInfo: Web3AuthUserInfo?

    /// 初期化済みフラグ
    @Published private(set) var isInitialized = false

    // MARK: - Initialization

    private init() {}

    /// Web3Authを初期化
    func initialize() async throws {
        guard !isInitialized else {
            print("ℹ️ Web3Auth は既に初期化されています")
            return
        }

        print("🔧 Web3Auth 初期化開始...")

        do {
            // Firebase JWT用のカスタム認証設定
            let authConnectionConfig = AuthConnectionConfig(
                authConnectionId: verifierName,
                authConnection: .CUSTOM,
                clientId: clientId
            )

            let options = Web3AuthOptions(
                clientId: clientId,
                web3AuthNetwork: .SAPPHIRE_DEVNET, // 本番は .SAPPHIRE_MAINNET に変更
                redirectUrl: redirectUrl
            )

            let web3Auth = try await Web3Auth(options: options)

            self.web3Auth = web3Auth
            self.isInitialized = true

            print("✅ Web3Auth 初期化完了")
        } catch {
            print("❌ Web3Auth 初期化エラー: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Login with Firebase JWT

    /// Firebase JWTを使ってWeb3Authにログイン
    /// - Parameters:
    ///   - idToken: Firebase ID Token (JWT)
    ///   - firebaseUid: Firebase ユーザーID
    func loginWithFirebaseJwt(idToken: String, firebaseUid: String) async throws {
        guard let web3Auth = web3Auth else {
            throw Web3AuthManagerError.notInitialized
        }

        print("🔐 Web3Auth ログイン開始...")
        print("👤 Firebase UID: \(firebaseUid)")

        // Firebase JWTを使ってログイン
        let loginParams = LoginParams(
            authConnection: .CUSTOM,
            authConnectionId: verifierName,
            mfaLevel: .NONE,
            extraLoginOptions: ExtraLoginOptions(
                id_token: idToken,
                domain: "firebase"
            ),
            curve: .SECP256K1,
            idToken: idToken
        )

        do {
            let response = try await web3Auth.connectTo(loginParams: loginParams)

            // 秘密鍵を保存
            if let privKey = response.privateKey, !privKey.isEmpty {
                self.privateKey = privKey
                // 秘密鍵からウォレットアドレスを生成（web3swift使用 - 標準Ethereum方式）
                do {
                    self.walletAddress = try deriveWalletAddress(from: privKey)
                    print("📍 ウォレットアドレス: \(self.walletAddress ?? "不明")")
                } catch {
                    print("❌ アドレス導出エラー: \(error.localizedDescription)")
                    throw Web3AuthManagerError.noPrivateKey
                }
            } else {
                print("⚠️ 秘密鍵が空です")
                throw Web3AuthManagerError.noPrivateKey
            }

            // ユーザー情報を保存
            self.userInfo = response.userInfo

            print("✅ Web3Auth ログイン成功")
        } catch {
            print("❌ Web3Auth ログインエラー: \(error.localizedDescription)")
            throw Web3AuthManagerError.loginFailed(error.localizedDescription)
        }
    }

    // MARK: - Logout

    /// Web3Authからログアウト
    func logout() async throws {
        guard let web3Auth = web3Auth else {
            throw Web3AuthManagerError.notInitialized
        }

        try await web3Auth.logout()

        // 状態をクリア
        self.walletAddress = nil
        self.privateKey = nil
        self.userInfo = nil

        print("👋 Web3Auth ログアウト完了")
    }

    // MARK: - Helper Methods

    /// 秘密鍵からウォレットアドレスを導出（web3swift使用 - 標準Ethereum方式）
    /// - Parameter privateKey: Web3Authから取得した秘密鍵（16進数文字列）
    /// - Returns: ウォレットアドレス（EIP-55 Checksum付きの文字列推奨）
    /// - Throws: Web3AuthManagerError
    private func deriveWalletAddress(from privateKey: String) throws -> String {
        print("🔐 秘密鍵からアドレス導出開始...")
        
        // 0xプレフィックスを処理
        let cleanHexKey = privateKey.hasPrefix("0x") 
            ? String(privateKey.dropFirst(2)) 
            : privateKey
        
        // 16進数文字列をDataに変換
        // Web3CoreモジュールのData.fromHexを使用
        guard let privateKeyData = Data.fromHex(cleanHexKey) else {
            // ⚠️ セキュリティ: 秘密鍵そのものはログに出さない
            print("❌ 無効な秘密鍵形式（Hex変換失敗）")
            throw Web3AuthManagerError.noPrivateKey
        }
        
        // 秘密鍵の長さを検証（32 bytes = 64 hex characters）
        guard privateKeyData.count == 32 else {
            print("❌ 秘密鍵の長さが無効です: \(privateKeyData.count) bytes (期待値: 32 bytes)")
            throw Web3AuthManagerError.noPrivateKey
        }

        do {
            // web3swiftのKeystoreManagerを使用してアドレスを導出
            // EthereumKeystoreV3を使用して秘密鍵からアドレスを取得
            guard let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: "") else {
                print("❌ Keystore作成失敗")
                throw Web3AuthManagerError.noPrivateKey
            }
            
            // アドレスを取得
            guard let addresses = keystore.addresses, let address = addresses.first else {
                print("❌ アドレス取得失敗")
                throw Web3AuthManagerError.noPrivateKey
            }
            
            // アドレスを文字列に変換（0xプレフィックス付き）
            let addressString = address.address
            
            print("✅ 標準Ethereumアドレス導出成功: \(addressString)")
            return addressString
            
        } catch {
            print("❌ アドレス導出エラー: \(error.localizedDescription)")
            throw Web3AuthManagerError.noPrivateKey
        }
    }

    /// セッションが有効かチェック
    func checkSession() -> Bool {
        guard let web3Auth = web3Auth else {
            return false
        }

        // Web3Authの状態を確認
        let response = web3Auth.web3AuthResponse
        return response?.privateKey != nil && !(response?.privateKey?.isEmpty ?? true)
    }
}
