//
//  MainTabBar.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//
// アプリ画面のフッターをコンポーネント化しています。
import SwiftUI

struct MainTabBar: View {
    var body: some View {
        ZStack {
//            #if DEBUG
//            Image("Home_ref")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//                .frame(height:85, alignment: .bottom)
//                .opacity(0.8)
//            #endif

            HStack(spacing: 54) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    VStack(spacing: 5) {
                        Image(systemName: tab.iconName)
                            .font(.system(size: 18))
                            .foregroundStyle(Color.white)
                        Text(tab.rawValue)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 21.5)
            .padding(.bottom, 14)
            .background(Color(red:22/255, green: 20/255, blue: 21/255))
        }
    }
}

#Preview {
    MainTabBar()
}
