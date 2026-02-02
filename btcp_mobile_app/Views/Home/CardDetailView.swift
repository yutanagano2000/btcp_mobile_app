//
//  CardDetailView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/11.
//
import SwiftUI
import UIKit
import FirebaseAuth

struct CardDetailView: View {
    @State private var isOn = false
    @State private var showCopyToast = false
    @State private var cardSecrets: CardSecrets?
    @State private var isLoadingSecrets = false
    @State private var errorMessage: String?
    @State private var cardId: String?
    
    // クリップボードにコピーする関数
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        showCopyToast = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒
            showCopyToast = false
        }
    }
    
    // FirestoreからカードIDを取得してカードシークレットを取得する関数
    private func fetchCardSecrets() async {
        guard !isLoadingSecrets else { return }
        
        isLoadingSecrets = true
        errorMessage = nil
        
        do {
            // 1. FirestoreからカードIDを取得
            guard let firebaseUid = FirebaseAuth.Auth.auth().currentUser?.uid else {
                throw RainAPIError.apiError("ユーザーが認証されていません")
            }
            
            let firestoreUser = try await FirestoreManager.shared.getUser(firebaseUid: firebaseUid)
            
            guard let fetchedCardId = firestoreUser.cardId else {
                throw RainAPIError.apiError("カードIDが見つかりません。カードを作成してください。")
            }
            
            await MainActor.run {
                cardId = fetchedCardId
            }
            
            print("💳 FirestoreからカードID取得: \(fetchedCardId)")
            
            // 2. カードシークレットを取得
            let secrets = try await RainAPIManager.shared.getCardSecrets(cardId: fetchedCardId)
            await MainActor.run {
                cardSecrets = secrets
            }
            print("✅ カードシークレット取得成功")
        } catch {
            print("❌ カードシークレット取得エラー: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
        
        await MainActor.run {
            isLoadingSecrets = false
        }
    }
    
    // カード番号を4桁ごとにスペースで区切る関数
    private func formatCardNumber(_ cardNumber: String) -> String {
        let digits = cardNumber.replacingOccurrences(of: " ", with: "")
        var formatted = ""
        for (index, char) in digits.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted.append(char)
        }
        return formatted
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
                                if let secrets = cardSecrets {
                                    Text(formatCardNumber(secrets.cardNumber))
                                        .monospacedDigit()
                                    Button {
                                        copyToClipboard(text: secrets.cardNumber)
                                    } label: {
                                        Image(systemName: "document.on.document")
                                    }
                                    .buttonStyle(.plain)
                                } else if isLoadingSecrets {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("読み込み中...")
                                        .monospacedDigit()
                                        .foregroundStyle(.gray)
                                }
                            }
                            .opacity(isOn ? 0 : 1)
                            HStack(spacing: 10) {
                                Spacer()
                                if let secrets = cardSecrets {
                                    let lastFour = String(secrets.cardNumber.suffix(4))
                                    Text("**** **** **** \(lastFour)")
                                        .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                } else {
                                    Text("**** **** **** ****")
                                        .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                }
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
                                if let secrets = cardSecrets {
                                    Text(secrets.cvc)
                                        .monospacedDigit()
                                    Button {
                                        copyToClipboard(text: secrets.cvc)
                                    } label: {
                                        Image(systemName: "document.on.document")
                                    }
                                    .buttonStyle(.plain)
                                } else if isLoadingSecrets {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("***")
                                        .monospacedDigit()
                                        .foregroundStyle(.gray)
                                }
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
            .task {
                // ビューが表示されたときにカードシークレットを取得
                await fetchCardSecrets()
            }
        }
    }
}

#Preview {
    CardDetailView()
}
