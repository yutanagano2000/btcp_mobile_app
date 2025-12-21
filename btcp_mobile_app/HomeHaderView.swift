//
//  HomeHaderView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//
// ホーム画面のヘッダーコンポーネントです。
import SwiftUI

struct HomeHaderView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                //            #if DEBUG
                //            VStack {
                //                Spacer()
                //                Image("Home_ref")
                //                    .resizable()
                //                    .scaledToFill()
                //                    .frame(height: 85, alignment: .top)
                //                Spacer()
                //            }
                //            .ignoresSafeArea()
                //            #endif
                HStack {
                    Image("btcp_logo")
                    Spacer()
                    NavigationLink {
                        NotificationView()
                    } label: {
                        Image(systemName: "bell")
                            .foregroundStyle(Color(red: 69 / 255, green: 69 / 255, blue: 69 / 255))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.trailing, 7)
                .padding(.top, 70)
            }
        }
    }
}

#Preview {
    HomeHaderView()
}
