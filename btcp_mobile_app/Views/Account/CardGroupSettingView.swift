//
//  ReceiptRegistrationView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/18.
//
import SwiftUI

struct CardGroupSettingView: View {
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 28
    @State var searchText: String = ""
    @FocusState var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
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
                    Text("グループ")
                        .foregroundStyle(Color.white)
                        .font(.system(size: 18))
                        .fontWeight(.light)
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 25, weight: .light))
                        .foregroundStyle(Color(red: 17 / 255, green: 79 / 255, blue: 86 / 255))
                }

                HStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                    TextField(
                        "",
                        text: $searchText,
                        prompt: Text("グループ名で検索")
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
                .focused($isFocused)

                VStack {
                    Text("該当するグループがありません")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding()
                }
                .padding(.vertical)
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

#Preview {
    CardGroupSettingView()
}
