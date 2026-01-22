//
//  AccountsView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/16.
//
import SwiftUI
import FirebaseAuth

struct AccountsView: View {
    private let headerHeight: CGFloat = 10
    @EnvironmentObject private var authManager: AuthManager
    @State private var selectedTab: AccountTabType = .general // デフォルトは全般

    // タブの種類を定義
    enum AccountTabType {
        case general // 全般
        case transaction // 入金 / 出金
        case api // API
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 40) {
                        Color.clear.frame(height: headerHeight)
                        CardUsageCardView(progress: 0.8)

                        // 残高カードを追加
                        VStack(alignment: .leading, spacing: 16) {
                            Text("残高")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))

                            HStack(spacing: 20) {
                                // USDC
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("USDC")
                                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                        .font(.system(size: 14))
                                    Text("0.0000")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20, weight: .bold))
                                }

                                Spacer()

                                // USDT
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("USDT")
                                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                        .font(.system(size: 14))
                                    Text("0.0000")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 20, weight: .bold))
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                        .cornerRadius(12)

                        // タブバーを追加
                        AccountTabBarView(selectedTab: $selectedTab)

                        // タブの内容に応じて表示を切り替え
                        if selectedTab == .general {
                            GeneralTabContent()
                        } else if selectedTab == .transaction {
                            TransactionTabContent()
                        } else {
                            APITabContent()
                        }
                    }
                    .padding()
                    .padding(.bottom, 60)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))
        }
    }
}

// タブバーコンポーネント
struct AccountTabBarView: View {
    @Binding var selectedTab: AccountsView.AccountTabType

    var body: some View {
        HStack(spacing: 0) {
            // 全般タブ
            Button {
                selectedTab = .general
            } label: {
                Text("全般")
                    .foregroundStyle(selectedTab == .general ? Color.white : Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                    .font(.system(size: 16, weight: selectedTab == .general ? .semibold : .regular))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedTab == .general
                            ? Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255)
                            : Color.clear
                    )
            }

            // 入金 / 出金タブ
            Button {
                selectedTab = .transaction
            } label: {
                Text("入金 / 出金")
                    .foregroundStyle(selectedTab == .transaction ? Color.white : Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                    .font(.system(size: 16, weight: selectedTab == .transaction ? .semibold : .regular))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedTab == .transaction
                            ? Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255)
                            : Color.clear
                    )
            }

            // APIタブ
            Button {
                selectedTab = .api
            } label: {
                Text("API")
                    .foregroundStyle(selectedTab == .api ? Color.white : Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                    .font(.system(size: 16, weight: selectedTab == .api ? .semibold : .regular))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedTab == .api
                            ? Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255)
                            : Color.clear
                    )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
        )
        .animation(.none, value: selectedTab)
    }
}

// 全般タブのコンテンツ（現在のコンテンツを移動）
struct GeneralTabContent: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isResetting = false
    @State private var showResetAlert = false
    @State private var resetErrorMessage: String?

    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 20) {
                HStack {
                    Image(systemName: "building.2")
                    Spacer()
                    Text("BitcoinPay株式会社")
                }
                HStack {
                    Image(systemName: "person")
                    Spacer()
                    Text("Yuta Nagano")
                }
                HStack {
                    Image(systemName: "envelope")
                    Spacer()
                    Text(verbatim: "yuta.nagano2000@gmail.com")
                }
            }
            .padding()
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
            .cornerRadius(12)

            VStack {
                HStack {
                    Text("カードグループ設定")
                    Spacer()
                    NavigationLink {
                        CardGroupSettingView()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding()
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
            .cornerRadius(12)
            VStack {
                HStack {
                    Text("アプリ設定")
                    Spacer()
                    NavigationLink {
                        AppSettingView()
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding()
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
            .cornerRadius(12)

            VStack(spacing: 40) {
                HStack {
                    Text("よくある質問")
                    Spacer()
                    NavigationLink {
                        Text("よくある質問画面")
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                HStack {
                    Text("アプリ利用規約")
                    Spacer()
                    NavigationLink {
                        Text("アプリ利用規約画面")
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                HStack {
                    Text("その他の利用規約")
                    Spacer()
                    NavigationLink {
                        Text("その他の利用規約画面")
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                HStack {
                    Text("プライバシーポリシー")
                    Spacer()
                    NavigationLink {
                        Text("プライバシーポリシー画面")
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding()
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
            .cornerRadius(12)

            VStack(spacing: 40) {
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text("1.32.0")
                }
                HStack {
                    Text("ソフトウェア・ライセンス")
                    Spacer()
                    NavigationLink {
                        Text("ソフトウェアライセンス画面")
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding()
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
            .cornerRadius(12)
            VStack {
                HStack {
                    Image(systemName: "document.on.document")
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ユーザー情報をコピーする")
                        Text("問い合わせの際はこちらの情報を添付してください")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
            .cornerRadius(12)
            
            // 開発用: KYBステータスリセットボタン
            VStack {
                Button {
                    Task {
                        await resetKYBStatus()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text(isResetting ? "リセット中..." : "KYBステータスをリセット（開発用）")
                    }
                    .foregroundStyle(Color.orange)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                    .cornerRadius(12)
                }
                .disabled(isResetting)
                
                if let errorMessage = resetErrorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }
            }
            
            VStack {
                Button {
                    authManager.logout()
                } label: {
                    Text("ログアウト")
                        .foregroundStyle(Color(red: 255 / 255, green: 107 / 255, blue: 77 / 255))
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                        .cornerRadius(12)
                }
            }
        }
        .alert("リセット完了", isPresented: $showResetAlert) {
            Button("OK") {
                // リセット後、ログアウトして再ログインするとKYBStatusViewが表示される
                authManager.logout()
            }
        } message: {
            Text("KYBステータスをリセットしました。再度ログインしてKYB認証を開始してください。")
        }
    }
    
    // MARK: - リセット処理
    private func resetKYBStatus() async {
        guard let firebaseUid = Auth.auth().currentUser?.uid else {
            await MainActor.run {
                resetErrorMessage = "ユーザー情報が取得できません"
            }
            return
        }
        
        await MainActor.run {
            isResetting = true
            resetErrorMessage = nil
        }
        
        do {
            try await FirestoreManager.shared.resetKYBStatus(firebaseUid: firebaseUid)
            await MainActor.run {
                authManager.kybStatus = .notStarted
                showResetAlert = true
            }
            print("✅ KYBステータスリセット成功")
        } catch {
            await MainActor.run {
                resetErrorMessage = "リセットに失敗しました: \(error.localizedDescription)"
            }
            print("❌ KYBステータスリセットエラー: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            isResetting = false
        }
    }
}

// 入金 / 出金タブのコンテンツ（空のコンテンツ）
struct TransactionTabContent: View {
    var body: some View {
        VStack {
            Text("入金 / 出金")
                .foregroundStyle(Color.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// APIタブのコンテンツ（空のコンテンツ）
struct APITabContent: View {
    var body: some View {
        VStack {
            Text("API")
                .foregroundStyle(Color.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    AccountsView()
}
