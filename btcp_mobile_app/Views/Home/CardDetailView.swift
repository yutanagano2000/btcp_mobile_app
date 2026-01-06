//
//  CardDetailView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/11.
//
import SwiftUI

struct CardDetailView: View {
    @State private var isOn = false
    @State private var showCopyToast = false
    
    // クリップボードにコピーする関数
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        showCopyToast = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒
            showCopyToast = false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 29) {
                ZStack {
                    NavigationLink{
                        CardInformationView()
                    } label: {
                        Image("blank_card")
                            .resizable()
                            .scaledToFit()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray)
                                    .opacity(isOn ? 0.3 : 0)
                            )
                            .padding(.horizontal, 10)
                        
//                        VStack(spacing: 10) {
//                            Image(systemName: "lock")
//                                .font(.system(size: 37))
//                            Text("保有者ロック中")
//                                .font(.system(size: 16))
//                        }
//                        .opacity(isOn ? 1 : 0)
                    }
                    
                    
                    
                }
                
                VStack(spacing: 24) {
                    HStack {
                        Text("カード2")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        Spacer()
                        // 右側の文言は幅が変わりやすいのでZStackで固定化
                        ZStack {
                            HStack {
                                Spacer()
                                Text("保有者ロック中")
                                    .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                    .opacity(isOn ? 1 : 0)
                            }
                            HStack {
                                Spacer()
                                Text("タップして情報を表示")
                                    .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                    .opacity(isOn ? 0 : 1)
                            }
                        }
                    }
                    .padding(.top, 27)
                    .padding(.horizontal)
                    HStack {
                        Text("カード番号")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        Spacer()
                        // 表示/伏せ字をZStackで重ねて横幅を固定
                        ZStack {
                            HStack(spacing: 10) {
                                Spacer()
                                Text("1234 5678 9012 0466")
                                    .monospacedDigit()
                                Button {
                                    copyToClipboard(text: "1234 5678 9012 0466")
                                } label: {
                                    Image(systemName: "document.on.document")
                                }
                                .buttonStyle(.plain)
                                .opacity(isOn ? 0 : 1)
                            }
                            .opacity(isOn ? 0 : 1)
                            HStack(spacing: 10) {
                                Spacer()
                                Text("**** **** **** 0466")
                                    .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                            }
                            .opacity(isOn ? 1 : 0)
                        }
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("CVV(セキュリティコード)")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .lineLimit(1)
                        Spacer()
                        ZStack {
                            HStack(spacing: 10) {
                                Spacer()
                                Text("586")
                                    .monospacedDigit()
                                Button {
                                    copyToClipboard(text: "586")
                                } label: {
                                    Image(systemName: "document.on.document")
                                }
                                .buttonStyle(.plain)
                                .opacity(1)
                            }
                            .opacity(isOn ? 0 : 1)
                            HStack(spacing: 10) {
                                Spacer()
                                Text("***")
                                    .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                            }
                            .opacity(isOn ? 1 : 0)
                        }
                        .frame(maxWidth: 80)
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("有効期限")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        Spacer()
                        ZStack {
                            HStack {
                                Spacer()
                                Text("12/2030")
                                    .monospacedDigit()
                                    .opacity(isOn ? 0 : 1)
                            }
                            .opacity(isOn ? 0 : 1)
                            
                            HStack {
                                Spacer()
                                Text("**" + "/" + "****")
                                    .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                    .monospacedDigit()
                                    .opacity(isOn ? 1 : 0)
                            }
                        }
                    }
                    .padding(.horizontal)
                    HStack {
                        Text("カードを一時ロック")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        Spacer()
                        Toggle("", isOn: $isOn)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color.green))
                            .scaleEffect(1.2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 27)
                }
                .background(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                .cornerRadius(12)
            }
            .foregroundStyle(Color.white)
            .overlay(
                // トーストメッセージ
                Group {
                    if showCopyToast {
                        VStack {
                            Text("クリップボードにコピーされました")
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.8))
                                )
                                .transition(.opacity.combined(with: .scale))
                                .padding(.top, 80)
                            Spacer()
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showCopyToast)
            )
        }
    }
}

#Preview {
    CardDetailView()
}
