//
//  KYBComponents.swift
//  btcp_mobile_app
//
//  KYB画面共通コンポーネント
//

import SwiftUI

// MARK: - プログレスバー

struct KYBProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(1...totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep ? accentColor : secondaryText.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            
            Text("ステップ \(currentStep) / \(totalSteps)")
                .font(.caption)
                .foregroundStyle(secondaryText)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - テキストフィールド

struct KYBTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isRequired: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                
                if isRequired {
                    Text("*")
                        .foregroundStyle(.red)
                }
            }
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(cardBackground)
                .cornerRadius(8)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - プレビュー

#Preview("Progress Bar") {
    ZStack {
        Color(red: 28/255, green: 26/255, blue: 27/255).ignoresSafeArea()
        VStack(spacing: 20) {
            KYBProgressBar(currentStep: 1, totalSteps: 5)
            KYBProgressBar(currentStep: 3, totalSteps: 5)
            KYBProgressBar(currentStep: 5, totalSteps: 5)
        }
    }
}

#Preview("Text Field") {
    ZStack {
        Color(red: 28/255, green: 26/255, blue: 27/255).ignoresSafeArea()
        VStack(spacing: 20) {
            KYBTextField(
                title: "会社名",
                placeholder: "例: 株式会社〇〇",
                text: .constant(""),
                isRequired: true
            )
            KYBTextField(
                title: "業種",
                placeholder: "例: IT・通信",
                text: .constant("IT・通信"),
                isRequired: false
            )
        }
        .padding()
    }
}
