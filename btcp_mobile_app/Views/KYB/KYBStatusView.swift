//
//  KYBStatusView.swift
//  btcp_mobile_app
//
//  KYB認証ステータス画面（開始画面）
//

import SwiftUI
import FirebaseAuth

struct KYBStatusView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isSubmitting = false
    @State private var showCompletionAlert = false
    @State private var errorMessage: String?
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // メインコンテンツ
                    VStack(spacing: 32) {
                        // アイコン
                        ZStack {
                            Circle()
                                .stroke(secondaryText.opacity(0.5), lineWidth: 2)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "exclamationmark")
                                .font(.system(size: 36, weight: .light))
                                .foregroundStyle(secondaryText)
                        }
                        
                        // タイトルと説明
                        VStack(spacing: 16) {
                            Text("KYB認証が必要です")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("カードをご利用いただくには、法人確認（KYB）が必要です。以下のボタンから認証を開始してください。")
                                .font(.subheadline)
                                .foregroundStyle(secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // ステップリスト
                        VStack(alignment: .leading, spacing: 20) {
                            StepRow(icon: "building.2", text: "法人情報の登録")
                            StepRow(icon: "doc.text", text: "必要書類のアップロード")
                            StepRow(icon: "checkmark.shield", text: "審査完了後、カードが利用可能に")
                        }
                        .padding(.vertical, 20)
                    }
                    
                    Spacer()
                    
                    // ボタン
                    VStack(spacing: 16) {
                        // エラーメッセージ表示
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 8)
                        }
                        
                        Button {
                            Task {
                                await submitMockKYBApplication()
                            }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(height: 56)
                            } else {
                                HStack {
                                    Image(systemName: "arrow.up.right")
                                    Text("KYB認証を開始")
                                }
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .background(isSubmitting ? secondaryText.opacity(0.3) : accentColor.opacity(0.3))
                        .cornerRadius(12)
                        .disabled(isSubmitting)
                        .buttonStyle(.plain)
                        
                        Divider()
                            .background(secondaryText.opacity(0.3))
                            .padding(.vertical, 8)
                        
                        Button {
                            authManager.logout()
                        } label: {
                            Text("ログアウト")
                                .font(.body)
                                .foregroundStyle(secondaryText)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("KYB認証ステータス")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("申請完了", isPresented: $showCompletionAlert) {
                Button("OK") {
                    // 自動的にContentViewに遷移（kybStatusが.approvedになったため）
                }
            } message: {
                Text("KYB申請が完了しました。承認済みのため、すぐにカードをご利用いただけます。")
            }
        }
    }
    
    // MARK: - モックKYB申請処理
    
    /// フォーム入力なしで直接Rain APIにPOST（モック化）
    private func submitMockKYBApplication() async {
        // Firebase UID、ウォレットアドレス、メールアドレスを取得
        guard let firebaseUid = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                errorMessage = "ユーザー情報が取得できません。再度ログインしてください。"
            }
            return
        }
        
        guard let walletAddress = Web3AuthManager.shared.walletAddress else {
            await MainActor.run {
                errorMessage = "ウォレットアドレスが取得できません。"
            }
            return
        }
        
        guard let email = Auth.auth().currentUser?.email else {
            await MainActor.run {
                errorMessage = "メールアドレスが取得できません。"
            }
            return
        }
        
        await MainActor.run {
            isSubmitting = true
            errorMessage = nil
        }
        
        do {
            print("🚀 KYB申請開始（モック）...")
            print("👤 Firebase UID: \(firebaseUid)")
            print("📍 Wallet: \(walletAddress)")
            print("📧 Email: \(email)")
            
            // Rain APIで法人アカウントを作成（モックデータ）
            let rainUserId = try await RainAPIManager.shared.createCorporateAccount(
                walletAddress: walletAddress,
                email: email,
                dummyData: [:] // ダミーデータはRainAPIManager内で設定
            )
            
            print("✅ Rain API呼び出し成功: rainUserId = \(rainUserId)")
            
            // FirestoreにrainUserIdを保存（kybStatus: "approved"）
            try await FirestoreManager.shared.updateRainUserId(
                firebaseUid: firebaseUid,
                rainUserId: rainUserId,
                kybStatus: "approved"
            )
            
            print("✅ Firestore保存完了")
            
            // AuthManagerのステータスも更新
            await MainActor.run {
                authManager.kybStatus = .approved
                showCompletionAlert = true
            }
            
            print("🎉 KYB申請完了！")
        } catch let error as RainAPIError {
            await MainActor.run {
                errorMessage = error.localizedDescription
                print("❌ KYB申請エラー (Rain API): \(error.localizedDescription)")
            }
        } catch {
            await MainActor.run {
                errorMessage = "申請に失敗しました: \(error.localizedDescription)"
                print("❌ KYB申請エラー: \(error.localizedDescription)")
            }
        }
        
        await MainActor.run {
            isSubmitting = false
        }
    }
}

// ステップ行コンポーネント
struct StepRow: View {
    let icon: String
    let text: String
    
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(accentColor)
                .frame(width: 40, height: 40)
                .background(accentColor.opacity(0.15))
                .cornerRadius(8)
            
            Text(text)
                .font(.body)
                .foregroundStyle(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}



#Preview("KYBStatusView") {
    NavigationStack {
        KYBStatusView()
            .environmentObject(AuthManager())
    }
}
