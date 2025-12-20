//
//  AppSettingView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/18.
//
import SwiftUI

struct AppSettingView: View {
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 28
    @State private var isOn1 = true
    @State private var isOn2 = false
    @State private var isOn3 = true
    @Environment(\.dismiss) private var dismiss
    
    var body: some View{
        NavigationStack {
            ZStack{
                //            Image("CardGroup_ref")
                //                .resizable()
                //                .opacity(0.5)
                VStack(spacing:18){
                    Color.clear.frame(height: headerHeight)
                    HStack(spacing: 8){
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 25, weight: .light))
                            }
                            .foregroundStyle(Color.white)
                        }
                        Spacer()
                    }
                    VStack(spacing: 45) {
                        HStack{
                            VStack(alignment: .leading) {
                                Text("生体認証でログインする")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.light)
                                Text("ログイン設定を変更するとログアウトされます")
                                    .foregroundStyle(Color(red:240/255, green: 135/255, blue: 70/255))
                                    .font(.footnote)
                            }
                            Spacer()
                            Toggle("", isOn: $isOn1)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red:66/255, green: 200/255, blue: 200/255)))
                                .scaleEffect(1.2)
                            
                            
                            
                        }
                        HStack{
                            Text("ログイン時に生体認証を求めない")
                                .foregroundStyle(Color.white)
                                .fontWeight(.light)
                            Spacer()
                            Toggle("", isOn: $isOn2)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red:66/255, green: 200/255, blue: 200/255)))
                                .scaleEffect(1.2)
                            
                        }
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red:30/255, green: 30/255, blue: 30/255))
                    )
                    VStack{
                        HStack {
                            Text("ダークモード")
                                .foregroundStyle(Color.white)
                                .fontWeight(.light)
                            Spacer()
                            HStack {
                                Text("システムデフォルト")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.light)
                                NavigationLink{
                                    ColorThemeView()
                                } label:{
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(Color.white)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red:30/255, green: 30/255, blue: 30/255))
                    )
                    VStack{
                        HStack {
                            Text("領収書未登録の取引をホームで通知する")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.white)
                                .fontWeight(.light)
                            Spacer()
                            Toggle("", isOn: $isOn3)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red:66/255, green: 200/255, blue: 200/255)))
                                .scaleEffect(1.2)
                            
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red:30/255, green: 30/255, blue: 30/255))
                    )
                    
                    
                    
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .background(Color(red:28/255, green: 26/255, blue: 27/255))
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    AppSettingView()
}
