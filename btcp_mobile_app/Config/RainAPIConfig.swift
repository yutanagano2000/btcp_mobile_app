//
//  RainAPIConfig.swift
//  btcp_mobile_app
//
//  Rain API設定
//

import Foundation

/// Rain API設定
enum RainAPIConfig {
    // TODO: 実際のRain APIのベースURLに置き換えてください
    static let baseURL = "https://api-dev.raincards.xyz/v1/issuing"

    // TODO: 実際のRain APIキーに置き換えてください
    static let apiKey = "5274725f0ac992db00a2e160fecc80794a6180b0"

    // 法人アカウント作成エンドポイント
    static let createCorporateAccountEndpoint = "/applications/company"
}
