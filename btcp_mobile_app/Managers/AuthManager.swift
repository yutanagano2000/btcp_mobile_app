import SwiftUI
import Combine

// KYBステータス
enum KYBStatus: String {
    case notStarted = "not_started"  // 未開始
    case pending = "pending"          // 審査中
    case approved = "approved"        // 承認済み
    case rejected = "rejected"        // 拒否
}

// 認証状態を管理するクラス
// ObservableObjectプロトコルを使用することで状態変化の自動通知が可能になる
class AuthManager: ObservableObject {
    // @Publishedを使用することで、状態変化の監視対象を指定できる
    @Published var isAuthenticated = false
    @Published var kybStatus: KYBStatus = .notStarted
    
    // Supabaseクライアントを設定
//    private var supabase: SupabaseClient
    
    // supabaseを初期化する
    init(){
        // self.supabase = SupabaseClient(
        //     supabaseURL: URL(string: SupabaseConfig.supabaseURL)!,
        //     supabaseKey: SupabaseConfig.supabaseAnonKey)
        // checkSession()
    }
    
    // Supabaseのセッション状態をテスト
    // Supabaseライブラリの機能
//    func checkSession(){
//        Task{
//            if let session = try? await supabase.auth.session{
//                await MainActor.run{self.isAuthenticated = true}
//            }
//        }
//    }
    // // ログイン
    // func login(email: String, password: String) async {
    //     do{
    //         _ = try await supabase.auth.signIn(email: email, password: password)
    //         await MainActor.run{self.isAuthenticated = true}
    //     } catch {
    //         print("ログインエラー: \(error)")
    //     }
        
    // }

    func login(email: String, password: String) async {
        if email == SupabaseConfig.testEmail && password == SupabaseConfig.testPassword{
        await MainActor.run {
            self.isAuthenticated = true
            }
        } else {
            self.isAuthenticated = false
        }
    }

    func logout() {
        isAuthenticated = false
    }
}
