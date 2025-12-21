//
//  AppSettingView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/18.
//
import SwiftUI

struct ColorThemeView: View {
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 28
    @State private var isOn1 = true
    @State private var isOn2 = false
    @State private var isOn3 = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                //            Image("CardGroup_ref")
                //                .resizable()
                //                .opacity(0.5)
                VStack(spacing: 18) {
                    Color.clear.frame(height: headerHeight)
                    HStack(spacing: 8) {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 25, weight: .light))
                            }
                            .foregroundStyle(Color.white)
                        }
                        Spacer()
                    }
                    VStack(spacing: 32) {
                        HStack {
                            Text("システムデフォルト")
                                .foregroundStyle(Color.white)
                                .fontWeight(.light)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(red: 60 / 255, green: 184 / 255, blue: 230 / 255))
                        }
                        HStack {
                            Text("ライトモード")
                                .foregroundStyle(Color.white)
                                .fontWeight(.light)
                            Spacer()
                        }
                        HStack {
                            Text("ダークモード")
                                .foregroundStyle(Color.white)
                                .fontWeight(.light)
                            Spacer()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                    )
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ColorThemeView()
}
