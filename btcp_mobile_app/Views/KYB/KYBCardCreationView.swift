//
//  KYBCardCreationView.swift
//  btcp_mobile_app
//
//  KYB申請完了後のカード作成画面
//

import SwiftUI
import FirebaseAuth

struct KYBCardCreationView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isCreating = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    @State private var createdCardId: String?
    @State private var isInitializing = true // 画面表示時の初期化中フラグ
    @State private var initialUserIdFromFirestore: String? // Firestoreから取得した initial user ID（カード作成APIに渡す）
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                // 初期化中はローディング表示
                if isInitializing {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                            .scaleEffect(1.5)
                        Text("Rain API側でユーザーが準備されるまで待機中...")
                            .font(.subheadline)
                            .foregroundStyle(secondaryText)
                            .padding(.top, 20)
                    }
                } else {
                    ScrollView {
                    VStack(spacing: 32) {
                        // アイコン
                        ZStack {
                            Circle()
                                .stroke(accentColor.opacity(0.3), lineWidth: 2)
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "creditcard")
                                .font(.system(size: 48, weight: .light))
                                .foregroundStyle(accentColor)
                        }
                        .padding(.top, 40)
                        
                        // タイトルと説明
                        VStack(spacing: 16) {
                            Text("カードを作成")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text("KYB認証が完了しました。カードを作成してご利用を開始してください。")
                                .font(.subheadline)
                                .foregroundStyle(secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // カード情報プレビュー
                        VStack(alignment: .leading, spacing: 16) {
                            Text("カード情報")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 12) {
                                InfoRow(label: "カード名", value: "NaganoSwift")
                                InfoRow(label: "タイプ", value: "仮想カード")
                                InfoRow(label: "ステータス", value: "アクティブ")
                                InfoRow(label: "利用制限", value: "¥100,000 / 24時間")
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        // デバッグ情報（開発用）
                        VStack(alignment: .leading, spacing: 16) {
                            Text("デバッグ情報")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            VStack(spacing: 12) {
                                InfoRow(label: "Initial User ID", value: getRainUserIdForDisplay())
                            }
                            .padding()
                            .background(cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                    }
                }
                }
                
                // ボタン
                if !isInitializing {
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
                            await createCard()
                        }
                    } label: {
                        if isCreating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(height: 56)
                        } else {
                            HStack {
                                Image(systemName: "creditcard.fill")
                                Text("カードを作成")
                            }
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(isCreating ? secondaryText.opacity(0.3) : accentColor)
                    .cornerRadius(12)
                    .disabled(isCreating)
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
            }
            .navigationTitle("カード作成")
            .task {
                // 画面表示時にRain API側でユーザーが完全に作成されるまで待機
                await initializeView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("カード作成完了", isPresented: $showSuccessAlert) {
                Button("OK") {
                    // カード作成画面を閉じてホーム画面へ遷移
                    authManager.shouldShowCardCreation = false
                }
            } message: {
                if let cardId = createdCardId {
                    Text("カードが正常に作成されました。\nカードID: \(cardId)")
                } else {
                    Text("カードが正常に作成されました。")
                }
            }
        }
    }
    
    // MARK: - 画面初期化
    
    private func initializeView() async {
        // Firestoreから initial user ID（rainUserId）を取得して表示用に保存
        if let firebaseUid = Auth.auth().currentUser?.uid {
            do {
                let firestoreUser = try await FirestoreManager.shared.getUser(firebaseUid: firebaseUid)
                await MainActor.run {
                    initialUserIdFromFirestore = firestoreUser.rainUserId
                }
                print("🔍 カード作成画面: Firestoreから取得した initial user ID: \(firestoreUser.rainUserId ?? "なし")")
            } catch {
                print("⚠️ カード作成画面: Firestoreからユーザー情報を取得できませんでした: \(error.localizedDescription)")
            }
        }
        
        // Rain API側でユーザーが完全に作成されるまで待機（5秒）
        print("⏳ カード作成画面初期化: Rain API側でユーザーが完全に作成されるまで5秒待機...")
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        await MainActor.run {
            isInitializing = false
        }
        print("✅ カード作成画面初期化完了")
    }
    
    // MARK: - ヘルパーメソッド
    
    private func getRainUserIdForDisplay() -> String {
        if let userId = initialUserIdFromFirestore {
            return userId
        } else {
            return "取得中..."
        }
    }
    
    // MARK: - カード作成処理
    
    private func createCard() async {
        // Firebase UIDを取得
        guard let firebaseUid = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                errorMessage = "ユーザー情報が取得できません。再度ログインしてください。"
            }
            return
        }
        
        // Firestoreから initial user ID を取得（Aブロックで保存したIDをカード作成APIに渡す）。無い場合は GET all users でフォールバック
        var initialUserId: String?
        var organizationId: String?
        var kycStatus: String?
        do {
            let firestoreUser = try await FirestoreManager.shared.getUser(firebaseUid: firebaseUid)
            initialUserId = firestoreUser.rainUserId
            organizationId = firestoreUser.organizationId
            kycStatus = firestoreUser.kycStatus

            print("🔍 Firestoreから取得した情報:")
            print("   - Firebase UID: \(firebaseUid)")
            print("   - Initial User ID: \(firestoreUser.rainUserId ?? "なし")")
            print("   - Email: \(firestoreUser.email)")
            print("   - KYC Status: \(firestoreUser.kycStatus ?? "なし")")
            print("   - Organization ID: \(firestoreUser.organizationId ?? "なし")")

            // Firestoreに initial user ID が無い場合、組織IDがあれば GET all users で取得（フォールバック）
            if initialUserId == nil, let orgId = organizationId {
                print("⚠️ Firestoreに initial user ID がありません。GET all users で取得を試みます...")
                do {
                    initialUserId = try await RainAPIManager.shared.getInitialUserId(organizationId: orgId)
                    if let id = initialUserId {
                        print("📋 フォールバック: initial user ID を取得しました: \(id)")
                    }
                } catch {
                    print("⚠️ GET all users フォールバック失敗: \(error.localizedDescription)")
                }
            }

            guard let userId = initialUserId else {
                await MainActor.run {
                    errorMessage = "組織の初期ユーザーIDが見つかりません。KYB申請を再度実行してください。"
                }
                return
            }

            // カード作成は initial user ID があれば無条件で実行（KYC完了は不要）
            print("✅ Initial User ID 取得: \(userId)")
            print("💳 Initial user ID を使ってカードを作成します")
        } catch {
            await MainActor.run {
                errorMessage = "ユーザー情報の取得に失敗しました: \(error.localizedDescription)"
            }
            return
        }

        guard let userId = initialUserId else {
            return
        }
        
        await MainActor.run {
            isCreating = true
            errorMessage = nil
        }
        
        do {
            print("💳 カード作成開始...")
            print("👤 Initial User ID（カード作成APIに渡す）: \(userId)")
            if let orgId = organizationId {
                print("🏢 Organization ID: \(orgId)")
            }
            
            // Rain API側でユーザーが完全に作成されるまで待機（初回は5秒）
            print("⏳ Rain API側でユーザーが完全に作成されるまで5秒待機...")
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5秒待機
            
            // カード作成リクエスト
            let cardRequest = CreateCardRequest(
                type: "virtual",
                status: "active",
                limit: CardLimit(
                    amount: 100000,  // デフォルト: 10万円
                    frequency: "per24HourPeriod"
                ),
                configuration: CardConfiguration(
                    displayName: "NaganoSwift",
                    productId: nil,
                    productRef: nil,
                    virtualCardArt: nil
                ),
                shipping: ShippingAddress(
                    line1: "1-1-1 Shibuya",
                    city: "Shibuya-ku",
                    postalCode: "150-0001",
                    countryCode: "JP",
                    phoneNumber: "09012345678",
                    line2: nil,
                    region: "Tokyo",
                    method: nil,
                    firstName: "Yuta",
                    lastName: "Nagano"
                ),
                billing: BillingAddress(
                    line1: "1-1-1 Shibuya",
                    city: "Shibuya-ku",
                    region: "Tokyo",
                    postalCode: "150-0001",
                    countryCode: "JP",
                    line2: nil,
                    country: nil
                ),
                bulkShippingGroupId: nil
            )
            
            // リトライロジック（最大3回、各回2秒待機）
            var cardInfo: [String: Any]?
            var lastError: Error?
            let maxRetries = 3
            
            for attempt in 1...maxRetries {
                do {
                    // Aブロックで取得した initial user ID をパラメータに渡してカード作成
                    cardInfo = try await RainAPIManager.shared.createCard(
                        userId: userId,
                        cardRequest: cardRequest
                    )
                    print("✅ カード作成完了（試行 \(attempt)回目）")
                    print("💳 Initial user ID (\(userId)) でカードを作成しました")
                    if let cardId = cardInfo?["id"] as? String {
                        print("💳 カードID: \(cardId)")
                        await MainActor.run {
                            createdCardId = cardId
                        }
                        
                        // カード作成成功後、カードIDをFirestoreに保存
                        do {
                            try await FirestoreManager.shared.saveCardId(
                                firebaseUid: firebaseUid,
                                cardId: cardId
                            )
                            print("✅ カードIDをFirestoreに保存しました: \(cardId)")
                        } catch {
                            print("⚠️ カードIDのFirestore保存に失敗しました: \(error.localizedDescription)")
                        }
                    }
                    break // 成功したらループを抜ける
                } catch {
                    lastError = error
                    print("⚠️ カード作成エラー（試行 \(attempt)/\(maxRetries)）: \(error.localizedDescription)")
                    
                        if attempt < maxRetries {
                            // リトライ時は5秒待機（Rain API側でユーザーが作成されるのを待つ）
                            print("⏳ 5秒待機してリトライします...")
                            try? await Task.sleep(nanoseconds: 5_000_000_000)
                        }
                }
            }
            
            if cardInfo == nil {
                // すべてのリトライに失敗した場合
                if let error = lastError {
                    await MainActor.run {
                        errorMessage = "カード作成に失敗しました: \(error.localizedDescription)"
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "カード作成に失敗しました"
                    }
                }
            } else {
                // 成功
                await MainActor.run {
                    showSuccessAlert = true
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "カード作成エラー: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run {
            isCreating = false
        }
    }
}

// MARK: - 情報行コンポーネント

struct InfoRow: View {
    let label: String
    let value: String
    
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
    }
}

#Preview("KYBCardCreationView") {
    NavigationStack {
        KYBCardCreationView()
            .environmentObject(AuthManager())
    }
}
