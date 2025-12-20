//
//  ContentView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//

import SwiftUI

struct ContentView: View {
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 100
    @State private var selectedTab : MainTab = .home

    var body: some View {
        NavigationStack {
            ZStack {
                // メインコンテンツ領域（ヘッダーの下から始まる）
                
                VStack(spacing: 0) {
                    // ヘッダー分の空きは Home のときだけ入れる
                    if selectedTab == .home {
                        Color.clear
                            .frame(height: headerHeight)
                    }

                    // 角丸カード + 中身スクロール
                    ZStack(alignment: .top) {
                        // タブに応じて切替え
                        Group {
                            switch selectedTab {
                            case .home:
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: 8) {
                                        VStack(spacing:0){
                                            HStack(spacing:0){
                                                Spacer()
                                                NavigationLink {
                                                    AllCardsInformationView()
                                                } label: {
                                                    HStack(spacing: 4) {
                                                        Text("すべてのカード ")
                                                            .foregroundStyle(Color(red:17/255, green: 79/255, blue: 86/255))
                                                        Image(systemName: "chevron.right")
                                                            .foregroundStyle(Color(red:17/255, green: 79/255, blue: 86/255))
                                                    }
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            .padding(10)
                                        }
                                        
                                        CardDetailView()
                    
                                        Spacer()
                        
                                    }
                                    .padding(.top, 20)
                                    .padding(.horizontal, 20)
                                }
                                .background(Color(red:28/255,green: 26/255, blue: 27/255))
                                .cornerRadius(12)
                                
                            
                            case .receipt:
                                ReceiptRegistrationView()
                                    .background(Color.clear)
                            case .history:
                                HistoryView()
                              
                            case .account:
                                AccountsView()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.vertical, 20)
                }
                .ignoresSafeArea(edges: [.top, .bottom])
               
                // 画面上端ヘッダーは Home のときだけ表示
                if selectedTab == .home {
                    VStack(spacing: 0) {
                        HomeHaderView()
                        Spacer(minLength: 0)
                    }
                    .frame(alignment: .top)
                    .ignoresSafeArea(edges: .top)
                }
                
                // 画面下端にフッターを固定表示
                VStack(spacing: 0){
                    Spacer()
                    MainTabBar(onSelect: { tab in
                            selectedTab = tab
                        },
                     selectedTab: selectedTab)
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    ContentView()
}
