//
//  btcp_mobile_appApp.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//

import SwiftUI

// btcp.appのエントリーポイント
@main
struct btcp_mobile_appApp: App {
    // 1) AuthManagerのインスタンスを生成
    // @StateObjectで@Publishedの変更を検知
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                // 認証OKの場合はホーム画面へ遷移
                ContentView()
                    .environmentObject(authManager)
            } else {
                // 認証NGの場合はログイン画面へ遷移
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
