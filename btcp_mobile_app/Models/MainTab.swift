//
//  MainTab.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//
// アプリ画面のフッターを定義するenumです。
import Foundation

enum MainTab: String, CaseIterable {
    case home = "ホーム"
    case receipt = "請求書登録"
    case history = "利用履歴"
    case account = "アカウント"

    var iconName: String {
        switch self {
        case .home: return "house"
        case .receipt: return "receipt"
        case .history: return "list.bullet.rectangle"
        case .account: return "person"
        }
    }

    var title: String {
        rawValue
    }
}
