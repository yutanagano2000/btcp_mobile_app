//
//  KYBCompanyInfoView.swift
//  btcp_mobile_app
//
//  会社情報入力画面
//

import SwiftUI

struct KYBCompanyInfoView: View {
    @State private var companyName = "株式会社サンプル"
    @State private var companyNameEn = "Sample Inc."
    @State private var corporateNumber = "1234567890123"
    @State private var establishedDate = Date()
    @State private var industry = "IT・通信"
    @State private var businessDescription = "システム開発、クラウドサービス提供"
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    private var isFormValid: Bool {
        !companyName.isEmpty && !companyNameEn.isEmpty && !corporateNumber.isEmpty
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // プログレス表示
                    KYBProgressBar(currentStep: 1, totalSteps: 4)
                        .padding(.top, 20)
                    
                    // フォーム
                    VStack(spacing: 20) {
                        KYBTextField(
                            title: "会社名（正式名称）",
                            placeholder: "例: 株式会社〇〇",
                            text: $companyName,
                            isRequired: true
                        )
                        
                        KYBTextField(
                            title: "会社名（英語）",
                            placeholder: "例: Example Inc.",
                            text: $companyNameEn,
                            isRequired: true
                        )
                        
                        KYBTextField(
                            title: "法人番号",
                            placeholder: "13桁の数字",
                            text: $corporateNumber,
                            isRequired: true,
                            keyboardType: .numberPad
                        )
                        
                        // 設立年月日
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("設立年月日")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                Text("*")
                                    .foregroundStyle(.red)
                            }
                            
                            DatePicker("", selection: $establishedDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(accentColor)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(cardBackground)
                                .cornerRadius(8)
                        }
                        
                        KYBTextField(
                            title: "業種",
                            placeholder: "例: IT・通信",
                            text: $industry,
                            isRequired: false
                        )
                        
                        // 事業内容
                        VStack(alignment: .leading, spacing: 8) {
                            Text("事業内容")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            
                            TextEditor(text: $businessDescription)
                                .frame(height: 100)
                                .padding(8)
                                .background(cardBackground)
                                .cornerRadius(8)
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // 次へボタン
            VStack {
                Spacer()
                NavigationLink(destination: KYBAddressView()) {
                    Text("次へ")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isFormValid ? accentColor : secondaryText.opacity(0.3))
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .background(
                    LinearGradient(
                        colors: [backgroundColor.opacity(0), backgroundColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .allowsHitTesting(false)
                )
            }
        }
        .navigationTitle("会社情報")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        KYBCompanyInfoView()
    }
}
