//
//  CardHolderView.swift
//  btcp_mobile_app
//
//  Created on 2025/12/22.
//
import SwiftUI

struct CardHolder: Identifiable {
    let id = UUID()
    let name: String
    let email: String
}

struct CardHolderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selectedCardHolder: CardHolder?
    private let headerHeight: CGFloat = 50
    
    // サンプルユーザーデータ
    private let allCardHolders: [CardHolder] = [
        CardHolder(name: "sugitashoei", email: "sugita@btcpay.jp"),
        CardHolder(name: "Yuki", email: "yuki@btcpay.jp"),
        CardHolder(name: "Y", email: "querenyong54@gmail.com"),
        CardHolder(name: "Yuta Nagano", email: "yuta.nagano2000@gmail.com")
    ]
    
    // 検索フィルタリング
    private var filteredCardHolders: [CardHolder] {
        if searchText.isEmpty {
            return allCardHolders
        } else {
            return allCardHolders.filter { cardHolder in
                cardHolder.name.localizedCaseInsensitiveContains(searchText) ||
                cardHolder.email.localizedCaseInsensitiveContains(searchText)
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
                        Text("カード保有者")
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
                            ForEach(filteredCardHolders) { cardHolder in
                                Button {
                                    selectedCardHolder = cardHolder
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(cardHolder.name)
                                                .foregroundStyle(.white)
                                                .font(.system(size: 16))
                                            Text(cardHolder.email)
                                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                                .font(.system(size: 14))
                                        }
                                        Spacer()
                                        if selectedCardHolder?.id == cardHolder.id {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 16)
                                    .background(
                                        selectedCardHolder?.id == cardHolder.id
                                            ? Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)
                                            : Color.clear
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                // 区切り線
                                if cardHolder.id != filteredCardHolders.last?.id {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.leading)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 保存ボタン
                    Button {
                        // 保存処理をここに実装
                        dismiss()
                    } label: {
                        Text("保存")
                            .foregroundStyle(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 200 / 255, green: 200 / 255, blue: 200 / 255))
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 34) // ホームインジケーターの上に余白
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear {
                // デフォルトでYuta Naganoを選択
                selectedCardHolder = allCardHolders.first { $0.email == "yuta.nagano2000@gmail.com" }
            }
        }
    }
}

#Preview {
    CardHolderView()
}

