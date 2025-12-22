//
//  CardInformationView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/22.
//
import SwiftUI

struct CardInformationView: View {
    @Environment(\.dismiss) private var dismiss
    private let headerHeight: CGFloat = 50

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 固定ヘッダー
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal)
                    .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))

                    // スクロールする内容
                    ScrollView {
                        VStack(spacing: 20) {
                            Image("blank_card")
                            HStack {
                                Text("カード4")
                                    .foregroundStyle(Color.white)
                                // ここがナビゲーションリンク
                                NavigationLink {
                                    Text("カード詳細")
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 14))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                            NavigationLink{
                                Text("グループを設定画面")
                            } label: {
                                Text("グループを設定")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 14))
                                    
                                    
                            }
                            .padding(8)
                            .buttonStyle(.plain)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
    }
}



#Preview {
    CardInformationView()
}
