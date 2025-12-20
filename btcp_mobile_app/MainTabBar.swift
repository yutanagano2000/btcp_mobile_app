//
//  MainTabBar.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//
// アプリ画面のフッターをコンポーネント化しています。
import SwiftUI

struct MainTabBar: View {
    // 親に選択結果を伝える
    var onSelect: (MainTab) -> Void = { _ in }
    // 選択中表示のため（色や太さを変えたい場合に利用）
    var selectedTab: MainTab? = nil

    var body: some View {
        ZStack {
            HStack(spacing: 54) {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    Button {
                        onSelect(tab)
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 18))
                                .foregroundStyle(Color.white.opacity(selectedTab == tab ? 1.0 : 0.7))
                            Text(tab.rawValue)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.white.opacity(selectedTab == tab ? 1.0 : 0.7))
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 21.5)
            .background(Color(red:22/255, green: 20/255, blue: 21/255))
        }
    }
}

#Preview {
    MainTabBar()
}
