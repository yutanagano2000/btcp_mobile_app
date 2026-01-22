//
//  EmailInputView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/20.
//
import SwiftUI

struct EmailInputView: View {
    @State private var email: String = ""
    @State private var isEmailSent: Bool = false
    @State private var errorMessage: String?
    @State private var showLoginView: Bool = false
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        ZStack {
            // シンプルな背景色
            Color.gray.opacity(0.05)
                .ignoresSafeArea()

            if showLoginView {
                LoginView()
            } else if isEmailSent {
                // メール送信完了画面
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 20) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.tint)
                            .symbolEffect(.bounce, value: isEmailSent)

                        Text("メールを送信しました")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text("\(email)にマジックリンクを送信しました。\nメールをご確認ください。")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    Button {
                        showLoginView = true
                    } label: {
                        Text("ログイン画面へ")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            } else {
                // メールアドレス入力画面
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 40) {
                        // タイトルセクション
                        VStack(spacing: 8) {
                            Text("メールアドレスを入力")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text("ログイン用のマジックリンクを送信します")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                        // 入力フィールド
                        VStack(spacing: 12) {
                            TextField("your@email.com", text: $email)
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .focused($isEmailFocused)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(isEmailFocused ? Color.accentColor : Color(.separator), lineWidth: isEmailFocused ? 2 : 1)
                                        )
                                )
                                .padding(.horizontal, 20)

                            if let errorMessage = errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.caption)
                                    Text(errorMessage)
                                        .font(.caption)
                                }
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            }
                        }

                        // ボタンセクション
                        VStack(spacing: 12) {
                            Button {
                                sendMagicLink()
                            } label: {
                                Text("続ける")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(email.isEmpty ? Color(.systemGray4) : Color.accentColor)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                            .disabled(email.isEmpty)

                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // 画面表示時にキーボードを自動表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isEmailFocused = true
            }
        }
    }

    private func sendMagicLink() {
        guard !email.isEmpty else { return }
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "有効なメールアドレスを入力してください"
            return
        }

        errorMessage = nil
        isEmailFocused = false
        FirebaseAuthManager.shared.sendSignInLink(email: email)
        isEmailSent = true
    }
}

#Preview {
    EmailInputView()
}
