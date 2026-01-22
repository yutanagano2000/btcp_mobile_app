//
//  KYBReviewView.swift
//  btcp_mobile_app
//
//  確認画面
//

import SwiftUI
import FirebaseAuth

struct KYBReviewView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var agreedToTerms = false
    @State private var showCompletionAlert = false
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // プログレス表示
                    KYBProgressBar(currentStep: 5, totalSteps: 5)
                        .padding(.top, 20)
                    
                    // 説明
                    Text("入力内容をご確認ください")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                    
                    // セクション
                    VStack(spacing: 16) {
                        ReviewSection(
                            title: "会社情報",
                            items: [
                                ("会社名", "株式会社サンプル"),
                                ("法人番号", "1234567890123"),
                                ("業種", "IT・通信")
                            ]
                        )
                        
                        ReviewSection(
                            title: "住所",
                            items: [
                                ("郵便番号", "150-0001"),
                                ("住所", "東京都渋谷区神宮前1-2-3"),
                                ("電話番号", "03-1234-5678")
                            ]
                        )
                        
                        ReviewSection(
                            title: "代表者情報",
                            items: [
                                ("氏名", "山田 太郎"),
                                ("役職", "代表取締役"),
                                ("メール", "taro@example.com")
                            ]
                        )
                        
                        ReviewSection(
                            title: "アップロード書類",
                            items: [
                                ("登記簿謄本", "アップロード済み"),
                                ("本人確認書類", "アップロード済み")
                            ]
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // 利用規約同意
                    Button {
                        agreedToTerms.toggle()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                .foregroundStyle(agreedToTerms ? accentColor : secondaryText)
                            
                            Text("利用規約とプライバシーポリシーに同意します")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // 申請ボタン
            VStack {
                Spacer()
                
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
                        await submitKYBApplication()
                    }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(height: 56)
                    } else {
                        Text("申請する")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(agreedToTerms && !isSubmitting ? accentColor : secondaryText.opacity(0.3))
                .cornerRadius(12)
                .disabled(!agreedToTerms || isSubmitting)
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(
                        colors: [backgroundColor.opacity(0), backgroundColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .allowsHitTesting(false)
                )
            }
        }
        .navigationTitle("確認")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("申請完了", isPresented: $showCompletionAlert) {
            Button("OK") {
                // ホーム画面に戻る処理（kybStatusが.approvedになったので自動的にContentViewに遷移）
            }
        } message: {
            Text("KYB申請が完了しました。承認済みのため、すぐにカードをご利用いただけます。")
        }
    }
    
    // MARK: - KYB申請処理
    
    /// KYB申請を送信（簡易版：最初から承認済み）
    private func submitKYBApplication() async {
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
            print("🚀 KYB申請開始...")
            print("👤 Firebase UID: \(firebaseUid)")
            print("📍 Wallet: \(walletAddress)")
            print("📧 Email: \(email)")
            
            // Rain APIで法人アカウントを作成（簡易版：最初から承認済み）
            let rainUserId = try await RainAPIManager.shared.createCorporateAccount(
                walletAddress: walletAddress,
                email: email,
                dummyData: [:] // 簡易版なのでダミーデータはRainAPIManager内で設定
            )
            
            print("✅ Rain API呼び出し成功: rainUserId = \(rainUserId)")
            
            // FirestoreにrainUserIdを保存（kybStatus: "approved"）
            try await FirestoreManager.shared.updateRainUserId(
                firebaseUid: firebaseUid,
                rainUserId: rainUserId,
                kybStatus: "approved" // 簡易版なので最初から承認済み
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

// レビューセクションコンポーネント
struct ReviewSection: View {
    let title: String
    let items: [(String, String)]
    
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            VStack(spacing: 8) {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .font(.caption)
                            .foregroundStyle(secondaryText)
                        Spacer()
                        Text(item.1)
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        KYBReviewView()
    }
}
