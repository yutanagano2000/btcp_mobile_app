//
//  LoginBackScreen.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/20.
//
import SwiftUI

struct LoginBackScreen: View {
    private let headerHeigth: CGFloat = 150
    var body: some View {
        ZStack {
//            Image("Login_ref")
//                .resizable()
//                .scaledToFill()
//                .opacity(0.5)
//                .ignoresSafeArea()

            VStack {
                Color.clear.frame(height: headerHeigth)
                HStack {
                    Spacer()
                    Image("btcp_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .padding(.leading, 50)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

#Preview {
    LoginBackScreen()
}
