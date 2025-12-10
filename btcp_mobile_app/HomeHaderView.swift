//
//  HomeHaderView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//
// ホーム画面のヘッダーコンポーネントです。
import SwiftUI

struct HomeHaderView: View {
    var body: some View{
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
                Image(systemName: "bell")
                    .foregroundStyle(Color(red:69/255, green: 69/255, blue: 69/255))
            }
            .padding(.horizontal, 8)
            .padding(.trailing,7)
            .padding(.top, 85)
        }
    }
}

#Preview {
    HomeHaderView()
}
