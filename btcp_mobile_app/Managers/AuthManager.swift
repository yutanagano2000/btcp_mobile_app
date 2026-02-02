import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

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
    @Published var isCheckingAuth = true // 認証状態チェック中フラグ
    @Published var shouldShowCardCreation = false // カード作成画面を表示するかどうか
    
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
        kybStatus = .notStarted
    }
    
    // MARK: - 認証状態チェック
    
    /// アプリ起動時にFirebase認証状態とKYBステータスをチェック
    /// 
    /// KYBステータスの取得フロー:
    /// 1. FirestoreからkybStatusを読み込む（Rain APIから直接取得していない）
    /// 2. KYB申請時: Rain API申請 → rainUserId取得 → FirestoreにkybStatus: "approved"を保存
    /// 3. アプリ起動時: FirestoreからkybStatusを読み込んで画面遷移を決定
    func checkAuthState() async {
        print("🔍 認証状態をチェック中...")
        
        await MainActor.run {
            isCheckingAuth = true
        }
        
        // ステップ1: Firebase認証状態をチェック
        guard let currentUser = Auth.auth().currentUser else {
            await MainActor.run {
                isAuthenticated = false
                kybStatus = .notStarted
                isCheckingAuth = false
            }
            print("ℹ️ 未認証状態")
            return
        }
        
        print("✅ Firebase認証済み: \(currentUser.uid)")
        
        // ステップ2: Web3Authのセッションを復元（既にログイン済みの場合は自動的に復元される）
        // 注意: Web3Authセッション復元に失敗しても、KYBステータスのチェックは続行する
        await restoreWeb3AuthSession(firebaseUid: currentUser.uid)
        
        // ステップ3: FirestoreからKYBステータスを読み込む
        // 注意: Rain APIから直接取得していない。Firestoreに保存されたkybStatusを参照
        print("📖 FirestoreからKYBステータスを取得開始...")
        do {
            let firestoreUser = try await FirestoreManager.shared.getUser(firebaseUid: currentUser.uid)
            
            print("✅ Firestoreからユーザー情報を取得成功")
            print("   - Email: \(firestoreUser.email)")
            print("   - Wallet: \(firestoreUser.walletAddress)")
            print("   - Rain User ID: \(firestoreUser.rainUserId ?? "なし")")
            print("   - KYB Status: \(firestoreUser.kybStatus ?? "なし")")
            
            // KYBステータスを設定
            let status: KYBStatus
            if let kybStatusString = firestoreUser.kybStatus {
                status = KYBStatus(rawValue: kybStatusString) ?? .notStarted
                print("📋 FirestoreからKYBステータスを取得: \(kybStatusString) → \(status)")
            } else {
                status = .notStarted
                print("ℹ️ FirestoreにKYBステータスが設定されていません（新規ユーザーの可能性）")
            }
            
            await MainActor.run {
                isAuthenticated = true
                kybStatus = status
                isCheckingAuth = false
            }

            await PushNotificationManager.shared.uploadFCMTokenIfNeeded()
            print("📊 最終KYBステータス: \(status)")
            print("✨ 認証状態を更新しました")
        } catch let error as FirestoreManagerError {
            print("❌ FirestoreからKYBステータスの読み込みに失敗 (FirestoreManagerError):")
            print("   エラー説明: \(error.localizedDescription)")
            print("   エラー詳細: \(error)")
            
            // ユーザーが見つからない場合（Firestoreのデータが削除された場合など）は、
            // Firebase認証をログアウトしてメールアドレス入力画面を表示
            if case .userNotFound = error {
                print("ℹ️ Firestoreにユーザーが見つかりません。Firebase認証をログアウトしてメールアドレス入力画面を表示します")
                
                // Firebase認証をログアウト
                do {
                    try Auth.auth().signOut()
                    print("✅ Firebase認証をログアウトしました")
                } catch {
                    print("⚠️ Firebase認証のログアウトに失敗: \(error.localizedDescription)")
                }
                
                await MainActor.run {
                    isAuthenticated = false
                    kybStatus = .notStarted
                    isCheckingAuth = false
                }
            } else {
                // その他のFirestoreエラー（ネットワークエラーなど）の場合も、
                // Firestoreにドキュメントが存在するかどうかを明示的にチェック
                print("🔍 Firestoreにドキュメントが存在するか確認中...")
                let documentExists = await checkFirestoreDocumentExists(firebaseUid: currentUser.uid)
                
                if !documentExists {
                    print("ℹ️ Firestoreにドキュメントが存在しません。Firebase認証をログアウトしてメールアドレス入力画面を表示します")
                    
                    // Firebase認証をログアウト
                    do {
                        try Auth.auth().signOut()
                        print("✅ Firebase認証をログアウトしました")
                    } catch {
                        print("⚠️ Firebase認証のログアウトに失敗: \(error.localizedDescription)")
                    }
                    
                    await MainActor.run {
                        isAuthenticated = false
                        kybStatus = .notStarted
                        isCheckingAuth = false
                    }
                } else {
                    // ドキュメントが存在する場合は、ネットワークエラーなどの一時的な問題の可能性がある
                    print("⚠️ Firestoreにドキュメントは存在しますが、取得に失敗しました（ネットワークエラーの可能性）")
                    await MainActor.run {
                        isAuthenticated = true
                        kybStatus = .notStarted
                        isCheckingAuth = false
                    }
                    await PushNotificationManager.shared.uploadFCMTokenIfNeeded()
                }
            }
        } catch {
            print("❌ FirestoreからKYBステータスの読み込みに失敗 (その他):")
            print("   エラー説明: \(error.localizedDescription)")
            print("   エラータイプ: \(type(of: error))")
            print("   エラー詳細: \(error)")
            
            // Firestoreにドキュメントが存在するかどうかを明示的にチェック
            print("🔍 Firestoreにドキュメントが存在するか確認中...")
            let documentExists = await checkFirestoreDocumentExists(firebaseUid: currentUser.uid)
            
            if !documentExists {
                print("ℹ️ Firestoreにドキュメントが存在しません。Firebase認証をログアウトしてメールアドレス入力画面を表示します")
                
                // Firebase認証をログアウト
                do {
                    try Auth.auth().signOut()
                    print("✅ Firebase認証をログアウトしました")
                } catch {
                    print("⚠️ Firebase認証のログアウトに失敗: \(error.localizedDescription)")
                }
                
                await MainActor.run {
                    isAuthenticated = false
                    kybStatus = .notStarted
                    isCheckingAuth = false
                }
            } else {
                // ドキュメントが存在する場合は、ネットワークエラーなどの一時的な問題の可能性がある
                print("⚠️ Firestoreにドキュメントは存在しますが、取得に失敗しました（ネットワークエラーの可能性）")
                await MainActor.run {
                    isAuthenticated = true
                    kybStatus = .notStarted
                    isCheckingAuth = false
                }
                await PushNotificationManager.shared.uploadFCMTokenIfNeeded()
            }
        }
    }
    
    /// Firestoreにドキュメントが存在するかどうかをチェック
    private func checkFirestoreDocumentExists(firebaseUid: String) async -> Bool {
        do {
            let document = try await Firestore.firestore()
                .collection("users")
                .document(firebaseUid)
                .getDocument()
            return document.exists
        } catch {
            print("⚠️ Firestoreドキュメント存在確認エラー: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Web3Authのセッションを復元
    private func restoreWeb3AuthSession(firebaseUid: String) async {
        // Web3Authが初期化されていない場合は初期化
        if !Web3AuthManager.shared.isInitialized {
            do {
                try await Web3AuthManager.shared.initialize()
                print("✅ Web3Auth初期化完了")
            } catch {
                print("⚠️ Web3Auth初期化エラー: \(error.localizedDescription)")
                print("🔍 エラー詳細: \(error)")
                // 初期化に失敗しても続行（KYBステータスのチェックは続ける）
                return
            }
        }
        
        // 既にセッションが存在するかチェック
        if Web3AuthManager.shared.checkSession() {
            print("✅ Web3Authセッションは既に有効です")
            print("📍 ウォレット: \(Web3AuthManager.shared.walletAddress ?? "なし")")
            return
        }
        
        // セッションが存在しない場合は、Firebase ID Tokenを使って再ログイン
        guard let currentUser = Auth.auth().currentUser else {
            print("⚠️ Firebaseユーザーが見つかりません")
            return
        }
        
        do {
            // Firebase ID Tokenを取得
            print("🎫 Firebase ID Tokenを取得中...")
            let idToken = try await currentUser.getIDToken()
            print("✅ Firebase ID Token取得成功")
            
            print("🔄 Web3Authセッションを復元中...")
            print("👤 Firebase UID: \(firebaseUid)")
            
            // Firebase JWTでWeb3Authにログイン
            try await Web3AuthManager.shared.loginWithFirebaseJwt(
                idToken: idToken,
                firebaseUid: firebaseUid
            )
            
            print("✅ Web3Authセッション復元完了")
            print("📍 ウォレット: \(Web3AuthManager.shared.walletAddress ?? "なし")")
        } catch let error as Web3AuthManagerError {
            print("❌ Web3Authセッション復元エラー (Web3AuthManagerError):")
            print("   エラー説明: \(error.localizedDescription)")
            print("   エラー詳細: \(error)")
            // エラーでも続行（KYBステータスのチェックは続ける）
        } catch {
            print("❌ Web3Authセッション復元エラー (その他):")
            print("   エラー説明: \(error.localizedDescription)")
            print("   エラータイプ: \(type(of: error))")
            print("   エラー詳細: \(error)")
            // エラーでも続行（KYBステータスのチェックは続ける）
        }
    }
}
