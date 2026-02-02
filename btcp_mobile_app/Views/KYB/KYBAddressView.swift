//
//  KYBAddressView.swift
//  btcp_mobile_app
//
//  住所入力画面
//

import SwiftUI

struct KYBAddressView: View {
    @State private var postalCode = "150-0001"
    @State private var prefecture = "東京都"
    @State private var city = "渋谷区"
    @State private var street = "神宮前1-2-3"
    @State private var building = "サンプルビル 5F"
    @State private var phoneNumber = "03-1234-5678"
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    private var isFormValid: Bool {
        !postalCode.isEmpty && !prefecture.isEmpty && !city.isEmpty && !street.isEmpty && !phoneNumber.isEmpty
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // プログレス表示
                    KYBProgressBar(currentStep: 2, totalSteps: 4)
                        .padding(.top, 20)
                    
                    // フォーム
                    VStack(spacing: 20) {
                        KYBTextField(
                            title: "郵便番号",
                            placeholder: "000-0000",
                            text: $postalCode,
                            isRequired: true,
                            keyboardType: .numberPad
                        )
                        
                        KYBTextField(
                            title: "都道府県",
                            placeholder: "例: 東京都",
                            text: $prefecture,
                            isRequired: true
                        )
                        
                        KYBTextField(
                            title: "市区町村",
                            placeholder: "例: 渋谷区",
                            text: $city,
                            isRequired: true
                        )
                        
                        KYBTextField(
                            title: "町名・番地",
                            placeholder: "例: 神宮前1-2-3",
                            text: $street,
                            isRequired: true
                        )
                        
                        KYBTextField(
                            title: "建物名・部屋番号",
                            placeholder: "例: 〇〇ビル 5F",
                            text: $building,
                            isRequired: false
                        )
                        
                        KYBTextField(
                            title: "電話番号",
                            placeholder: "03-0000-0000",
                            text: $phoneNumber,
                            isRequired: true,
                            keyboardType: .phonePad
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // 次へボタン
            VStack {
                Spacer()
                NavigationLink(destination: KYBRepresentativeView()) {
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
        .navigationTitle("住所")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        KYBAddressView()
    }
}
