//
//  RainAPIConfig.swift
//  btcp_mobile_app
//
//  Rain API設定
//

import Foundation

/// Rain API設定
enum RainAPIConfig {
    /// Rain API ベースURL（環境変数から取得）
    static var baseURL: String {
        AppEnvironment.rainApiBaseURL
    }

    /// Rain API キー（環境変数から取得）
    static var apiKey: String {
        AppEnvironment.rainApiKey
    }

    // 法人アカウント作成エンドポイント
    static let createCorporateAccountEndpoint = "/applications/company"

    // 全ユーザー一覧取得エンドポイント（GET all users）
    static let getUsersEndpoint = "/users"

    // Rain API公開鍵（RSA暗号化用）
    // 公開鍵は機密情報ではないためハードコードで問題なし
    static let publicKeyPEM = """
    -----BEGIN PUBLIC KEY-----
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCAP192809jZyaw62g/eTzJ3P9H
    +RmT88sXUYjQ0K8Bx+rJ83f22+9isKx+lo5UuV8tvOlKwvdDS/pVbzpG7D7NO45c
    0zkLOXwDHZkou8fuj8xhDO5Tq3GzcrabNLRLVz3dkx0znfzGOhnY4lkOMIdKxlQb
    LuVM/dGDC9UpulF+UwIDAQAB
    -----END PUBLIC KEY-----
    """
}
