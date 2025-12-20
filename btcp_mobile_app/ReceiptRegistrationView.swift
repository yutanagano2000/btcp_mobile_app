//
//  ReceiptRegistrationView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/12.
//
import SwiftUI

struct ReceiptRegistrationView: View {
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 50
    @State var searchText: String = ""
    @FocusState var isFocused: Bool
    
    var body: some View{
        ZStack{
            VStack(spacing:20){
                Color.clear.frame(height: headerHeight)
                HStack{
                    Button("2025年12月"){}
                        .foregroundStyle(Color(red:17/255, green: 79/255, blue: 86/255))
                        .font(.system(size:16))
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color(red:17/255, green: 79/255, blue: 86/255))
                        .font(.system(size: 15))
                    Spacer()
                }
                
                HStack(spacing: 20){
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                    TextField(
                        "",
                        text: $searchText,
                        prompt: Text("取引先・金額で検索")
                            .foregroundStyle(.gray.opacity(0.5))
                    )
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red:30/255, green: 30/255, blue: 30/255))
                )
                .focused($isFocused)

                    Text("条件に合致する利用履歴がありません")
                        .font(.system(size: 15))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding()
    
                
    
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(red:28/255, green: 26/255, blue: 27/255))
        .ignoresSafeArea()
    }
}

#Preview {
    ReceiptRegistrationView()
}
