//
//  CardUsageCardView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/17.
//
import SwiftUI

struct CardUsageCardView:View {
    let progress: Double
    var height: CGFloat = 10
    
    private var clamped: Double {min(max(progress,0), 1)}
    var body: some View {
        VStack(spacing: 13) {
            HStack {
                Text("利用可能額")
                    
                Spacer()
            }
            .foregroundStyle(.white)
            HStack{
                Text("¥1,353,747")
                    .font(.title)
                    .fontWeight(.medium)
                Text("/")
                Text("¥1,700,000")
                Spacer()
            }
            .foregroundStyle(.white)
            GeometryReader { geo in
                ZStack(alignment: .leading){
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red:38/255, green: 88/255, blue: 89/255).opacity(0.5))
                        .frame(minHeight: 16)
                    
                    RoundedRectangle(cornerRadius:3)
                        .fill(Color(red:60/255, green: 184/255, blue: 230/255))
                        .frame(width: geo.size.width * clamped)
                    
                }
            }
            .frame(height: height)
        }
    }
}

#Preview {
    CardUsageCardView(progress: 0.80, height: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
}
