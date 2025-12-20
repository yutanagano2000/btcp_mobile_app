//
//  ReceiptRegistrationView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/18.
//
import SwiftUI

struct NotificationView: View {
    enum Tab: String, CaseIterable{
        case message = "メッセージ",
        history = "通知履歴"
    }
    // 暫定のヘッダー高さ（HomeHaderViewの見た目に合わせて調整）
    private let headerHeight: CGFloat = 28
    @State var searchText: String = ""
    @FocusState var isFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var tab: Tab = .message
    
    var body: some View{
        ZStack{
//            Image("CardGroup_ref")
//                .resizable()
//                .opacity(0.5)
            VStack(spacing:18){
                Color.clear.frame(height: headerHeight)
                header
                tabBar
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Color(red:28/255, green: 26/255, blue: 27/255))
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
    private var header: some View {
        HStack(spacing: 30){
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25, weight: .light))
                }
                .foregroundStyle(Color.white)
            }
            Text("お知らせ")
                .foregroundStyle(Color.white)
                .font(.system(size: 28))
                .fontWeight(.medium)
            Spacer()

        }
    }
    
    private var tabBar: some View {
        HStack(spacing: 12){
            ForEach(Tab.allCases, id:\.self){ t in
                Button{
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.9)){
                        tab = t} }label: {
                    Text(t.rawValue)
                        .font(.system(size: 15, weight: .light))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .foregroundStyle(tab == t ? .black : .white.opacity(0.9))
                        .background(
                            Capsule().fill(tab == t ? .white.opacity(0.9) : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
    private var content: some View {
        switch tab {
        case .message:
            VStack{
                Text("お知らせはありません")
                    .foregroundStyle(Color.white)
            }
        case .history:
            VStack{
                Text("履歴はありません")
                    .foregroundStyle(Color.white)
            }
        }
    }
}



#Preview {
    NotificationView()
}
