//
//  NoticeStatus+UI.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/20.
//
import SwiftUI

struct BadgeStyle{
    let text: LocalizedStringKey
    let foreground: Color
    let background: Color
}

extension NoticeStatus {
    var badgeStyle: BadgeStyle? {
        switch self {
        case .unread:
            return .init(text: "未読", foreground: .pink, background: .pink.opacity(0.2))
        case .important:
            return .init(text: "重要", foreground: .orange, background: .orange.opacity(0.2))
        case .read:
            return nil
        }
    }
}

struct BadgeView: View {
    let style: BadgeStyle
    var body: some View {
        Text(style.text)
            .font(.caption2)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .foregroundStyle(style.foreground)
            .background(RoundedRectangle(cornerRadius: 4).fill(style.background))
    }
}

#Preview {
    if let style = NoticeStatus.important.badgeStyle {
        BadgeView(style: style)
            .padding()
    }
}
