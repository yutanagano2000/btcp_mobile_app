//
//  LoginBackScreen.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/20.
//
import SwiftUI

struct LoginView: View {
    private let headerHeigth: CGFloat = 120
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginErrorMessage: String?

    // Appファイルで環境注入したAuthManagerを取り出す
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        ZStack {
            LoginBackScreen()
            VStack(spacing: 20) {
                Color.clear.frame(height: headerHeigth)

                HStack(spacing: 12) {
                    Image(systemName: "envelope")
                        .foregroundStyle(Color.gray)
                    TextField("メールアドレス", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        // メールアドレスの@を入力するために追加
                        .autocorrectionDisabled(true)
                        .padding(.vertical, 18)
                }
                .padding(.leading, 8)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(.black, lineWidth: 0.4)
                )
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .foregroundStyle(Color.gray)
                    SecureField("パスワード", text: $password)
                        .textContentType(.password)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding(.vertical, 18)
                }
                .padding(.leading, 8)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(.black, lineWidth: 0.4)
                )

                HStack {
                    Spacer()
                    Text("ログインでお困りの方")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.gray)
                }

                Button {
                    //ログインボタンを押下することでauthManagerのログイン処理を呼び出す
                    Task {
                        await authManager.login(email: email, password: password)
                    }
                } label: {
                    Text("ログイン")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(7)
                        .foregroundStyle(Color.white)
                }
                .buttonStyle(.plain)

                VStack(spacing: 20) {
                    Image(systemName: "faceid")
                        .font(.system(size: 70))
                        .fontWeight(.thin)
                    Text("FaceIDでログイン")
                        .font(.callout)
                        .foregroundStyle(Color.gray)
                }
                .padding(.top, 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    // プレビュー用にAuthManagerを注入
    LoginView()
    .environmentObject(AuthManager())
}
