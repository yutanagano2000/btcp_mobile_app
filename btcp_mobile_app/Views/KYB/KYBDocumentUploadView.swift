//
//  KYBDocumentUploadView.swift
//  btcp_mobile_app
//
//  書類アップロード画面
//

import SwiftUI

struct KYBDocumentUploadView: View {
    @State private var registrationCertUploaded = false
    @State private var representativeIdUploaded = false
    @State private var articlesUploaded = false
    
    // カラー定義
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    private var isFormValid: Bool {
        registrationCertUploaded && representativeIdUploaded
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // プログレス表示
                    KYBProgressBar(currentStep: 4, totalSteps: 5)
                        .padding(.top, 20)
                    
                    // 説明
                    Text("以下の書類をアップロードしてください")
                        .font(.subheadline)
                        .foregroundStyle(secondaryText)
                        .padding(.horizontal, 20)
                    
                    // 書類リスト
                    VStack(spacing: 16) {
                        DocumentUploadRow(
                            title: "登記簿謄本",
                            subtitle: "発行から3ヶ月以内",
                            isRequired: true,
                            isUploaded: $registrationCertUploaded
                        )
                        
                        DocumentUploadRow(
                            title: "代表者の本人確認書類",
                            subtitle: "運転免許証 / パスポート / マイナンバーカード",
                            isRequired: true,
                            isUploaded: $representativeIdUploaded
                        )
                        
                        DocumentUploadRow(
                            title: "定款",
                            subtitle: "会社の定款（任意）",
                            isRequired: false,
                            isUploaded: $articlesUploaded
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // 次へボタン
            VStack {
                Spacer()
                NavigationLink(destination: KYBReviewView()) {
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
        .navigationTitle("書類アップロード")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// 書類アップロード行コンポーネント
struct DocumentUploadRow: View {
    let title: String
    let subtitle: String
    let isRequired: Bool
    @Binding var isUploaded: Bool
    
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                
                if isRequired {
                    Text("*")
                        .foregroundStyle(.red)
                }
                
                Spacer()
                
                if isUploaded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(secondaryText)
            
            Button {
                // アップロード処理（シミュレーション）
                isUploaded = true
            } label: {
                HStack {
                    Image(systemName: isUploaded ? "checkmark" : "arrow.up.doc")
                    Text(isUploaded ? "アップロード済み" : "ファイルを選択")
                }
                .font(.subheadline)
                .foregroundStyle(isUploaded ? .green : accentColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isUploaded ? Color.green.opacity(0.5) : accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: isUploaded ? [] : [5]))
                )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        KYBDocumentUploadView()
    }
}
