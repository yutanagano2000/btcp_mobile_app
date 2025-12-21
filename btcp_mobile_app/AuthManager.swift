import SwiftUI

// 認証状態を管理するクラス
// ObservableObjectプロトコルを使用することで状態変化の自動通知が可能になる
class AuthManager: ObservableObject {
    // @Publishedを使用することで、状態変化の監視対象を指定できる
    @Published var isAuthenticated = false
    func login() {
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false
    }
}
