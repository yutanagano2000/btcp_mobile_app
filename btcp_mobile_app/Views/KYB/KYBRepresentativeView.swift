//
//  KYBRepresentativeView.swift
//  btcp_mobile_app
//
//  代表者情報入力画面
//

import SwiftUI

struct KYBRepresentativeView: View {
    @State private var lastName = ""
    @State private var firstName = ""
    @State private var lastNameRomaji = ""
    @State private var firstNameRomaji = ""
    @State private var title = ""
    @State private var birthDate = Date()
    @State private var email = ""
    @State private var phoneNumber = ""
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    private var isFormValid: Bool {
        !lastName.isEmpty && !firstName.isEmpty && !lastNameRomaji.isEmpty &&
        !firstNameRomaji.isEmpty && !email.isEmpty && !phoneNumber.isEmpty
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // プログレス表示
                    KYBProgressBar(currentStep: 3, totalSteps: 5)
                        .padding(.top, 20)
                    
                    // フォーム
                    VStack(spacing: 20) {
                        HStack(spacing: 12) {
                            KYBTextField(
                                title: "姓",
                                placeholder: "山田",
                                text: $lastName,
                                isRequired: true
                            )
                            
                            KYBTextField(
                                title: "名",
                                placeholder: "太郎",
                                text: $firstName,
                                isRequired: true
                            )
                        }
                        
                        HStack(spacing: 12) {
                            KYBTextField(
                                title: "姓（ローマ字）",
                                placeholder: "Yamada",
                                text: $lastNameRomaji,
                                isRequired: true
                            )
                            
                            KYBTextField(
                                title: "名（ローマ字）",
                                placeholder: "Taro",
                                text: $firstNameRomaji,
                                isRequired: true
                            )
                        }
                        
                        KYBTextField(
                            title: "役職",
                            placeholder: "例: 代表取締役",
                            text: $title,
                            isRequired: false
                        )
                        
                        // 生年月日
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("生年月日")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                Text("*")
                                    .foregroundStyle(.red)
                            }
                            
                            DatePicker("", selection: $birthDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(accentColor)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(cardBackground)
                                .cornerRadius(8)
                        }
                        
                        KYBTextField(
                            title: "メールアドレス",
                            placeholder: "example@company.com",
                            text: $email,
                            isRequired: true,
                            keyboardType: .emailAddress
                        )
                        
                        KYBTextField(
                            title: "電話番号",
                            placeholder: "090-0000-0000",
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
                NavigationLink(destination: KYBDocumentUploadView()) {
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
        .navigationTitle("代表者情報")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        KYBRepresentativeView()
    }
}
