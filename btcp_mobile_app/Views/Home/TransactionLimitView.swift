//
//  TransactionLimitView.swift
//  btcp_mobile_app
//
//  Created on 2025/12/22.
//
import SwiftUI

struct TransactionLimitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var limitAmount: String = ""
    @State private var isUnlimited: Bool = true
    private let headerHeight: CGFloat = 50
    private let currentLimit: String = "限度なし"
    
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
                        Text("取引あたりのリミットの設定")
                            .foregroundStyle(.white)
                            .font(.system(size: 17, weight: .semibold))
                        Spacer()
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal)
                    .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))
                    
                    // ヘッダー下のラベル
                    HStack {
                        HStack(spacing: 8) {
                            Text("現在の取引あたりのリミット")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                            Image(systemName: "info.circle")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 14))
                        }
                        Spacer()
                        Text(currentLimit)
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    
                    // コンテンツエリア
                    ScrollView {
                        VStack(spacing: 20) {
                            // リミット設定入力フィールド
                            if !isUnlimited {
                                HStack {
                                    Spacer()
                                    TextField("", text: $limitAmount, prompt: Text("¥0").foregroundStyle(.gray.opacity(0.5)))
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16))
                                        .multilineTextAlignment(.trailing)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                                )
                            }
                            
                            // 「限度なし」トグル
                            HStack {
                                Text("限度なし")
                                    .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                    .font(.system(size: 16))
                                Spacer()
                                Toggle("", isOn: $isUnlimited)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                                    .scaleEffect(1.2)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                            )
                            
                            // 注意書き
                            Text("UPSIDERにおける利用額の合計が貴社の利用可能枠を超える、または当月利用額の合計がカードに設定された取引あたりのリミットを超える場合は、ここで設定する取引あたりのリミットに関わらず決済は失敗しますのでご注意ください。")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 12))
                                .lineSpacing(4)
                                .padding(.horizontal)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // 確定ボタン
                    Button {
                        // 保存処理をここに実装
                        dismiss()
                    } label: {
                        Text("確定")
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
    TransactionLimitView()
}

