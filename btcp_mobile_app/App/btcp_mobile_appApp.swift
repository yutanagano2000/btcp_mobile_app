//
//  btcp_mobile_appApp.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//

import FirebaseAuth
import FirebaseCore
import SwiftUI

// btcp.appのエントリーポイント
@main
struct btcp_mobile_appApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        FirebaseApp.configure()

        // Web3Authを非同期で初期化
        Task { @MainActor in
            do {
                try await Web3AuthManager.shared.initialize()
            } catch {
                print("❌ Web3Auth初期化エラー: \(error.localizedDescription)")
            }
        }
    }

    // 1) AuthManagerのインスタンスを生成
    // @StateObjectで@Publishedの変更を検知
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isCheckingAuth {
                    // 認証状態チェック中はローディング画面を表示
                    ZStack {
                        Color(red: 28/255, green: 26/255, blue: 27/255)
                            .ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                } else if authManager.isAuthenticated {
                    // 認証OK
                    if authManager.shouldShowCardCreation {
                        // カード作成画面を表示
                        KYBCardCreationView()
                            .environmentObject(authManager)
                    } else if authManager.kybStatus == .approved {
                        // KYB承認済み → ホーム画面へ遷移
                        ContentView()
                            .environmentObject(authManager)
                    } else {
                        // KYB未完了 → KYBステータス画面へ遷移
                        KYBStatusView()
                            .environmentObject(authManager)
                    }
                } else {
                    // 認証NGの場合はメールアドレス入力画面へ遷移
                    EmailInputView()
                        .environmentObject(authManager)
                }
            }
            .task {
                // アプリ起動時に認証状態とKYBステータスをチェック
                await authManager.checkAuthState()
            }
            // onOpenURLはiOSがアプリにURLを渡したときに実行されるモディファイア
            .onOpenURL { url in
                print("🔗 リンクを受信しました: \(url.absoluteString)")
                print("📱 URLスキーム: \(url.scheme ?? "なし")")
                print("🌐 URLホスト: \(url.host ?? "なし")")
                print("📂 URLパス: \(url.path)")

                // Firebase認証リンクかどうかをチェック
                if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
                    print("✅ Firebase認証リンクを検出")

                    // UserDefaultsから保存したメールアドレスを取得
                    guard let email = UserDefaults.standard.string(forKey: "emailForSignIn") else {
                        print("❌ メールアドレスが見つかりません")
                        print("💡 ヒント: メールアドレスの入力画面からやり直してください")
                        return
                    }

                    print("📧 保存されたメールアドレス: \(email)")

                    // Firebaseでサインイン処理を実行
                    Auth.auth().signIn(withEmail: email, link: url.absoluteString) { authResult, error in
                        if let error = error {
                            print("❌ サインインエラー: \(error.localizedDescription)")
                            print("🔍 エラーコード: \(error._code)")
                            return
                        }

                        // サインイン成功
                        print("🎉 サインイン成功！")

                        guard let user = authResult?.user else {
                            print("❌ ユーザー情報が取得できません")
                            return
                        }

                        print("👤 ユーザーID: \(user.uid)")
                        print("📧 ユーザーメール: \(user.email ?? "不明")")

                        // Firebase ID Tokenを取得
                        user.getIDToken { idToken, error in
                            if let error = error {
                                print("❌ ID Token取得エラー: \(error.localizedDescription)")
                                return
                            }

                            guard let idToken = idToken else {
                                print("❌ ID Tokenがnilです")
                                return
                            }

                            print("🎫 Firebase ID Token取得成功")
                            print("🔑 Token (先頭50文字): \(String(idToken.prefix(50)))...")

                            // Web3Authに接続してFirestoreに保存
                            Task { @MainActor in
                                do {
                                    // Web3Authが初期化されていない場合は初期化
                                    if !Web3AuthManager.shared.isInitialized {
                                        try await Web3AuthManager.shared.initialize()
                                    }

                                    // Firebase JWTでWeb3Authにログイン
                                    try await Web3AuthManager.shared.loginWithFirebaseJwt(
                                        idToken: idToken,
                                        firebaseUid: user.uid
                                    )

                                    print("🔐 Web3Auth接続完了")
                                    print("📍 ウォレット: \(Web3AuthManager.shared.walletAddress ?? "なし")")

                                    // Firestoreにユーザー情報を保存
                                    if let walletAddress = Web3AuthManager.shared.walletAddress {
                                        try await FirestoreManager.shared.saveUser(
                                            firebaseUid: user.uid,
                                            email: user.email ?? email,
                                            walletAddress: walletAddress
                                        )
                                        print("💾 Firestoreにユーザー情報を保存しました")
                                    }

                                    // Firestoreから既存ユーザーのkybStatusを読み込む
                                    do {
                                        let firestoreUser = try await FirestoreManager.shared.getUser(firebaseUid: user.uid)
                                        if let kybStatusString = firestoreUser.kybStatus {
                                            let kybStatus = KYBStatus(rawValue: kybStatusString) ?? .notStarted
                                            authManager.kybStatus = kybStatus
                                            print("📊 KYBステータスを読み込みました: \(kybStatus)")
                                        } else {
                                            print("ℹ️ KYBステータスが設定されていません")
                                        }
                                    } catch {
                                        print("⚠️ KYBステータスの読み込みに失敗: \(error.localizedDescription)")
                                        // エラーでも続行（新規ユーザーの可能性があるため）
                                    }

                                    // 認証状態を更新
                                    authManager.isAuthenticated = true
                                    print("✨ 認証状態を更新しました")

                                    await PushNotificationManager.shared.uploadFCMTokenIfNeeded()
                                } catch {
                                    print("❌ Web3Auth/Firestore エラー: \(error.localizedDescription)")
                                    // Web3Auth接続に失敗してもFirebase認証は成功しているので、一旦認証状態をtrueにする
                                    authManager.isAuthenticated = true
                                }
                            }
                        }

                        // セキュリティのため、保存したメールアドレスを削除
                        UserDefaults.standard.removeObject(forKey: "emailForSignIn")
                        print("🗑️ 保存されたメールアドレスを削除しました")
                    }
                } else {
                    print("ℹ️ Firebase認証リンクではありません")
                }
            }
        }
    }
}
