//
//  ContentView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/09.
//

import SwiftUI

struct ContentView: View {
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 110

    var body: some View {
        ZStack {
            // 背景（ワイヤーフレーム）
//            Image("Home_ref")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
//                .clipped()
//                .opacity(0.1)
//                .allowsHitTesting(false)

            // メインコンテンツ領域（ヘッダーの下から始まる）
            VStack(spacing: 0) {
                // ヘッダー分の空き
                Color.clear
                    .frame(height: headerHeight)

                // 角丸カード + 中身スクロール
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(red:28/255, green: 26/255, blue: 27/255))
                        .ignoresSafeArea()

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 8) {
                            RoundedRectangle(cornerRadius: 12)
                                .frame(height: 48)
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 10)
                            VStack(spacing:0){
                                HStack(spacing:0){
                                    Spacer()
                                    Button("すべてのカード >"){}
                                    
                                }
                                .padding(10)
                                Image("blank_card")
                                    .resizable()
                                    .scaledToFit()
                            }
                  
                            RoundedRectangle(cornerRadius: 12)
                                .padding(.top, 10)
                                .frame(height: 400)
                            
                            
                            Text("A")
                                .foregroundStyle(Color.white)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                    }
                   
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 20)
            }
            .ignoresSafeArea(edges: [.top, .bottom])

            // 画面上端にヘッダーを固定表示
            VStack(spacing: 0) {
                HomeHaderView()
                Spacer(minLength: 0)
            }
            .frame(alignment: .top)
            .ignoresSafeArea(edges: .top)
            
            // 画面下端にフッターを固定表示
            VStack(spacing: 0){
                Spacer()
                MainTabBar()
                
            }
            .frame(alignment: .bottom)
            .ignoresSafeArea(edges: .bottom)
//            Image("Home_ref")
//                .resizable()
//                .scaledToFill()
//                .opacity(0.1)
        }
    }
}

#Preview {
    ContentView()
}
