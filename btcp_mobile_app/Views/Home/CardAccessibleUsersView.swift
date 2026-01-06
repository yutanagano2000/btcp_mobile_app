//
//  CardAccessibleUsersView.swift
//  btcp_mobile_app
//
//  Created on 2025/12/22.
//
import SwiftUI

struct AccessibleUser: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let role: String // "管理者" or "補助者"
}

struct CardAccessibleUsersView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    private let headerHeight: CGFloat = 50
    
    // サンプルユーザーデータ（画像に基づく）
    private let allUsers: [AccessibleUser] = [
        AccessibleUser(name: "sugitashoei", email: "sugita@btcpay.jp", role: "管理者"),
        AccessibleUser(name: "Y", email: "querenyong54@gmail.com", role: "管理者"),
        AccessibleUser(name: "Yuta Nagano", email: "yuta.nagano2000@gmail.com", role: "管理者")
    ]
    
    // 検索フィルタリング
    private var filteredUsers: [AccessibleUser] {
        if searchText.isEmpty {
            return allUsers
        } else {
            return allUsers.filter { user in
                user.name.localizedCaseInsensitiveContains(searchText) ||
                user.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色
                Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 固定ヘッダー
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color.white)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                        Text("このカードにアクセスできるユーザー")
                            .foregroundStyle(.white)
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal)
                    .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))
                    
                    // 検索バー
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.gray)
                        TextField(
                            "",
                            text: $searchText,
                            prompt: Text("名前、メールアドレスで検索")
                                .foregroundStyle(.gray.opacity(0.5))
                        )
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                    )
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    // ユーザーリスト
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredUsers) { user in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(user.name)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 16))
                                        Text(user.email)
                                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                            .font(.system(size: 14))
                                    }
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text(user.role)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 16))
                                        Image(systemName: "info.circle")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 16))
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 16)
                                
                                // 区切り線
                                if user.id != filteredUsers.last?.id {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.leading)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    CardAccessibleUsersView()
}

