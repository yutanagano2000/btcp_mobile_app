//
//  AccountsView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/16.
//
import SwiftUI

struct AccountsView: View {
    private let headerHeight: CGFloat = 10

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 40) {
                        Color.clear.frame(height: headerHeight)
                        CardUsageCardView(progress: 0.8)
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "building.2")
                                Spacer()
                                Text("BitcoinPay株式会社")
                            }
                            HStack {
                                Image(systemName: "person")
                                Spacer()
                                Text("Yuta Nagano")
                            }
                            HStack {
                                Image(systemName: "envelope")
                                Spacer()
                                Text(verbatim:"yuta.nagano2000@gmail.com")

                            }
                        }
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                        .cornerRadius(12)
                        
                        VStack {
                            HStack {
                                Text("カードグループ設定")
                                Spacer()
                                NavigationLink {
                                    CardGroupSettingView()
                                } label:{
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                        }
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                        .cornerRadius(12)
                        VStack {
                            HStack {
                                Text("アプリ設定")
                                Spacer()
                                NavigationLink {
                                   AppSettingView()
                                } label:{
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                        }
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                        .cornerRadius(12)
                        
                        VStack(spacing: 40) {
                            HStack {
                                Text("よくある質問")
                                Spacer()
                                NavigationLink {
                                    Text("よくある質問画面")
                                } label:{
                                    Image(systemName: "chevron.right")
                                }
                            }
                            HStack {
                                Text("アプリ利用規約")
                                Spacer()
                                NavigationLink{
                                    Text("アプリ利用規約画面")
                                } label :{
                                    Image(systemName: "chevron.right")
                                }
                            }
                            HStack {
                                Text("その他の利用規約")
                                Spacer()
                                NavigationLink{
                                    Text("その他の利用規約画面")
                                } label :{
                                    Image(systemName: "chevron.right")
                                }
                            }
                            HStack {
                                Text("プライバシーポリシー")
                                Spacer()
                                NavigationLink{
                                    Text("プライバシーポリシー画面")
                                } label :{
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                        }
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                        .cornerRadius(12)
                        
                        VStack(spacing: 40) {
                            HStack {
                                Text("バージョン")
                                Spacer()
                                Text("1.32.0")
                            }
                            HStack {
                                Text("ソフトウェア・ライセンス")
                                Spacer()
                                NavigationLink{
                                    Text("ソフトウェアライセンス画面")
                                } label :{
                                    Image(systemName: "chevron.right")
                                }
                            }
                            
                        }
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                        .cornerRadius(12)
                        VStack() {
                            HStack {
                                Image(systemName: "document.on.document")
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("ユーザー情報をコピーする")
                                    Text("問い合わせの際はこちらの情報を添付してください")
                                        .font(.caption)
                                        .foregroundStyle(Color.gray)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
        
            
                            }
                            
                        }
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
                        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                        .cornerRadius(12)
                        VStack {
                            HStack {
                                Text("ログアウト")
                                    .foregroundStyle(Color(red:255/255, green: 107/255, blue: 77/255))
                                Spacer()
                            }
                            
                        }
                        .padding()
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 30/255, green: 30/255, blue: 30/255))
                        .cornerRadius(12)
                        
                    }
                    .padding()
                    .padding(.bottom, 60)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .background(Color(red: 28/255, green: 26/255, blue: 27/255))
            // .ignoresSafeArea()

        }
    }
}

#Preview {
    AccountsView()
}
