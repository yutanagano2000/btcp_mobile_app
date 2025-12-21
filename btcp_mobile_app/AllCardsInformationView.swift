//
//  AllCardsInformationView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/14.
//

//
//  ReceiptRegistrationView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/12.
//
import SwiftUI

struct AllCardsInformationView: View {
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 50
    @State var searchText: String = ""
    @FocusState var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Color.clear.frame(height: headerHeight)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.white)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }

                HStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                    TextField(
                        "",
                        text: $searchText,
                        prompt: Text("カード名・グループ名を検索")
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
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true) // ← デフォルトの戻るボタンを非表示
    }
}

#Preview {
    AllCardsInformationView()
}
