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
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    // KYB申請済みの場合は何も表示しない（ホーム画面に遷移するため）
    var body: some View {
        // KYB申請済みの場合は空のViewを返す（自動的にContentViewに遷移する）
        if authManager.kybStatus == .approved {
            EmptyView()
        } else {
            kybStatusViewContent
        }
    }
    
    private var kybStatusViewContent: some View {
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
                        NavigationLink(destination: KYBCompanyInfoView()) {
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
                        .frame(maxWidth: .infinity)
                        .background(accentColor.opacity(0.3))
                        .cornerRadius(12)
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
