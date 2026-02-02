//
//  KYBReviewView.swift
//  btcp_mobile_app
//
//  確認画面（Aブロック最終ステップ）
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

/// Aブロック申請完了時にBブロックへ渡す companyId / uboId
struct ABlockResult: Hashable {
    let companyId: String
    let uboId: String
}

struct KYBReviewView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var agreedToTerms = false
    @State private var aBlockResult: ABlockResult?  // Aブロック申請完了後、Bブロックへ渡す companyId / uboId
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    
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
                    // プログレス表示（Aブロック：ステップ4/4＝確認）
                    KYBProgressBar(currentStep: 4, totalSteps: 4)
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
                        // Bブロック（書類提出）は申請後に別画面で行うため、Aブロックの確認では表示しない
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
            
            // 申請ボタン（Aブロック申請。押下で Rain へリクエストし、成功時にBブロックへ遷移）
            VStack {
                Spacer()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
                
                Button {
                    Task {
                        await submitABlockApplication()
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
        .navigationDestination(item: $aBlockResult) { result in
            // Aブロック申請完了後、Bブロック（書類提出）へ companyId / uboId を渡して遷移
            KYBDocumentUploadView(companyId: result.companyId, uboId: result.uboId)
        }
    }
    
    // MARK: - Aブロック申請処理（Rain へリクエスト）
    /// Aブロック完了時点で Rain へ申請リクエストを送信し、成功時にBブロックへ遷移する
    private func submitABlockApplication() async {
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
            print("🚀 Aブロック申請開始（Rain API）...")
            print("👤 Firebase UID: \(firebaseUid)")
            print("📍 Wallet: \(walletAddress)")
            print("📧 Email: \(email)")
            
            // Rain APIで法人アカウントを作成
            let corporateAccountResult = try await RainAPIManager.shared.createCorporateAccount(
                walletAddress: walletAddress,
                email: email,
                dummyData: [:]
            )
            
            print("✅ Rain API呼び出し成功:")
            print("   - 組織ID: \(corporateAccountResult.organizationId)")
            print("   - 組織名: \(corporateAccountResult.organizationName)")

            // GET all users で初期ユーザーIDを取得
            let uboUserId: String?
            do {
                uboUserId = try await RainAPIManager.shared.getInitialUserId(organizationId: corporateAccountResult.organizationId)
                if let id = uboUserId {
                    print("📋 GET all users: 初期ユーザーID = \(id)")
                } else {
                    print("⚠️ GET all users: ユーザーが0件でした")
                }
            } catch {
                print("⚠️ GET all users エラー: \(error.localizedDescription)")
                uboUserId = nil
            }

            // 組織をFirestoreに保存
            print("💾 Firestoreに組織を保存開始...")
            try await FirestoreManager.shared.saveOrganization(
                organizationId: corporateAccountResult.organizationId,
                name: corporateAccountResult.organizationName,
                rainApplicationId: corporateAccountResult.organizationId,
                kybStatus: "approved"
            )
            print("✅ Firestore組織保存完了")

            // 初期ユーザーIDが取得できた場合のみ UBO の KYC と Firestore 保存
            if let uboUserId = uboUserId {
                print("🚀 UBOのKYC手続きを開始...")
                do {
                    _ = try await RainAPIManager.shared.startUBOKYC(
                        organizationId: corporateAccountResult.organizationId,
                        uboUserId: uboUserId
                    )
                } catch {
                    print("⚠️ UBO KYC開始エラー: \(error.localizedDescription)")
                }
                
                let uboKYCStatus = corporateAccountResult.uboKYCStatus ?? "needsVerification"
                print("💾 FirestoreにUBOを保存開始...")
                try await FirestoreManager.shared.saveUBO(
                    firebaseUid: firebaseUid,
                    email: email,
                    walletAddress: walletAddress,
                    rainUserId: uboUserId,
                    organizationId: corporateAccountResult.organizationId,
                    kycStatus: uboKYCStatus
                )
                print("✅ Firestore UBO保存完了")
                
                try await FirestoreManager.shared.updateOrganizationUBO(
                    organizationId: corporateAccountResult.organizationId,
                    uboRainUserId: uboUserId
                )
                print("✅ 組織にUBO情報を保存完了")

                // Bブロックは現状無効のため遷移しない。Aブロック完了としてKYBステータスを更新し、カード作成画面を表示
                await MainActor.run {
                    authManager.kybStatus = .approved
                    authManager.shouldShowCardCreation = true
                }
                print("🎉 Aブロック申請完了（Bブロックは無効）→ カード作成画面へ")
            } else {
                print("⚠️ 初期ユーザーIDが取得できませんでした")
                try await FirestoreManager.shared.saveUser(
                    firebaseUid: firebaseUid,
                    email: email,
                    walletAddress: walletAddress
                )
                let updateData: [String: Any] = [
                    "organizationId": corporateAccountResult.organizationId,
                    "updatedAt": Date()
                ]
                try await Firestore.firestore().collection("users").document(firebaseUid).setData(updateData, merge: true)
                print("✅ 組織情報をユーザーに紐付けました")
                await MainActor.run {
                    errorMessage = "初期ユーザーIDが取得できませんでした。しばらく経ってから再度お試しください。"
                }
            }
        } catch let error as RainAPIError {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            print("❌ KYB申請エラー (Rain API): \(error.localizedDescription)")
        } catch {
            await MainActor.run {
                errorMessage = "申請に失敗しました: \(error.localizedDescription)"
            }
            print("❌ KYB申請エラー: \(error.localizedDescription)")
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
            .environmentObject(AuthManager())
    }
}
