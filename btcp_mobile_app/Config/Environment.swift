//
//  Environment.swift
//  btcp_mobile_app
//
//  環境変数を一元管理するユーティリティ
//  Info.plistから値を読み込み、アプリ全体で使用する
//

import Foundation

/// 環境変数を管理する構造体
/// Info.plistに定義された値を型安全に取得する
enum AppEnvironment {

    // MARK: - Private Helper

    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            print("⚠️ Info.plist が見つかりません")
            return [:]
        }
        return dict
    }()

    private static func value(for key: String, fallback: String? = nil) -> String {
        if let value = infoDictionary[key] as? String, !value.isEmpty, !value.hasPrefix("$(") {
            return value
        }
        if let fallback = fallback {
            print("⚠️ 環境変数 '\(key)' が設定されていません。フォールバック値を使用します。")
            return fallback
        }
        fatalError("環境変数 '\(key)' が設定されていません。Secrets.xcconfig を確認してください。")
    }

    private static func optionalValue(for key: String) -> String? {
        guard let value = infoDictionary[key] as? String, !value.isEmpty, !value.hasPrefix("$(") else {
            return nil
        }
        return value
    }

    // MARK: - Rain API

    /// Rain API キー
    static var rainApiKey: String {
        value(for: "RAIN_API_KEY", fallback: Fallback.rainApiKey)
    }

    /// Rain API ベースURL
    static var rainApiBaseURL: String {
        value(for: "RAIN_API_BASE_URL", fallback: Fallback.rainApiBaseURL)
    }

    // MARK: - Supabase

    /// Supabase URL
    static var supabaseURL: String {
        value(for: "SUPABASE_URL", fallback: Fallback.supabaseURL)
    }

    /// Supabase Anonymous Key
    static var supabaseAnonKey: String {
        value(for: "SUPABASE_ANON_KEY", fallback: Fallback.supabaseAnonKey)
    }

    // MARK: - Web3Auth

    /// Web3Auth Client ID
    static var web3AuthClientId: String {
        value(for: "WEB3AUTH_CLIENT_ID", fallback: Fallback.web3AuthClientId)
    }

    /// Web3Auth Verifier Name
    static var web3AuthVerifierName: String {
        value(for: "WEB3AUTH_VERIFIER_NAME", fallback: Fallback.web3AuthVerifierName)
    }

    /// Web3Auth Redirect URL
    static var web3AuthRedirectUrl: String {
        value(for: "WEB3AUTH_REDIRECT_URL", fallback: Fallback.web3AuthRedirectUrl)
    }

    // MARK: - Test Credentials (開発用)

    /// テスト用メールアドレス
    static var testEmail: String? {
        optionalValue(for: "TEST_EMAIL") ?? Fallback.testEmail
    }

    /// テスト用パスワード
    static var testPassword: String? {
        optionalValue(for: "TEST_PASSWORD") ?? Fallback.testPassword
    }
}

// MARK: - Fallback Values (開発用・本番リリース前に削除すること)
// ⚠️ 重要: 本番リリース前にこのセクションを削除し、xcconfig設定を完了してください
private enum Fallback {
    // TODO: 本番リリース前に削除
    static let rainApiKey = "5274725f0ac992db00a2e160fecc80794a6180b0"
    static let rainApiBaseURL = "https://api-dev.raincards.xyz/v1/issuing"
    static let supabaseURL = "https://hcomrbvcvcymdyxcfiyr.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhjb21yYnZjdmN5bWR5eGNmaXlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NTE2MDIsImV4cCI6MjA4MDIyNzYwMn0.PYd8dD3WJVFA6E6GlsUrjWds4OyZ1OVnrOsbepIRKoQ"
    static let web3AuthClientId = "BBlSuarULy-MjmGR1YJOGKevanhA2S-Xo-wGt5W8SM6LVVpEM-eYA40y5HC8CS_R1E-_3eOIdZ_nIDVehSaOS3o"
    static let web3AuthVerifierName = "firebase-btcp-prod"
    static let web3AuthRedirectUrl = "jp.sugita.btcp.mobile://auth"
    static let testEmail: String? = "test@example.com"
    static let testPassword: String? = "test1234"
}
