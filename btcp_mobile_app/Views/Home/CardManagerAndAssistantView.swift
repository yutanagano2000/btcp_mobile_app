//
//  CardManagerAndAssistantView.swift
//  btcp_mobile_app
//
//  Created on 2025/12/22.
//
import SwiftUI

struct CardManagerAndAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    private let headerHeight: CGFloat = 50

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
                        Text("カードの管理者と補助者")
                            .foregroundStyle(.white)
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                        Button(action: {}) {
                            Text("編集")
                                .foregroundStyle(.white)
                                .font(.system(size: 17))
                        }
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal)
                    .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))

                    // コンテンツエリア
                    ScrollView {
                        VStack {
                            // ユーザーがいない場合のメッセージ
                            Text("ユーザーがいません")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                                )
                                .padding(.horizontal)
                                .padding(.top, 20)
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
        }
    }
}

#Preview {
    CardManagerAndAssistantView()
}
