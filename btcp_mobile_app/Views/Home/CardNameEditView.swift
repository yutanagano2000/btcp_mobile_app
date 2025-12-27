//
//  CardNameEditView.swift
//  btcp_mobile_app
//
//  Created on 2025/12/22.
//
import SwiftUI

struct CardNameEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cardName: String = "カード4"
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
                        Text("カード")
                            .foregroundStyle(.white)
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal)
                    .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))
                    
                    // コンテンツエリア
                    VStack(alignment: .leading, spacing: 16) {
                        // カード名ラベル
                        Text("カード名")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                            .padding(.top, 20)
                        
                        // テキスト入力フィールド
                        TextField("", text: $cardName)
                            .foregroundStyle(.white)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255), lineWidth: 1)
                                    )
                            )
                    }
                    .padding(.horizontal)
                    
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
                                    .fill(Color(red: 200 / 255, green: 200 / 255, blue: 200 / 255)) // ライトグレー
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
    CardNameEditView()
}

