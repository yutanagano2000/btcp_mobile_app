//
//  memo_icon.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/12.
//
import SwiftUI

struct memoIcon: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "text.document")

            Text("メモ")
        }
        .foregroundColor(Color(red: 122 / 255, green: 122 / 255, blue: 122 / 255))
        .padding(.vertical, 14)
        .padding(.horizontal, 22)
        .background(Color(red: 23 / 255, green: 23 / 255, blue: 23 / 255))
        .cornerRadius(30)
    }
}

#Preview {
    memoIcon()
}
