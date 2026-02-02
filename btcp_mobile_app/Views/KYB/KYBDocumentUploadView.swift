//
//  KYBDocumentUploadView.swift
//  btcp_mobile_app
//
//  Bブロック：書類アップロード画面（パスポート / 運転免許証 / 住民基本カード）
//

import SwiftUI
import PhotosUI

// MARK: - 書類種別（Rain CardType 分岐は現時点では未実装）
enum DocumentUploadType: String, CaseIterable {
    case passport = "パスポート"
    case driverLicense = "運転免許証"
    case residentCard = "住民基本カード"
    
    /// Rain API の type に渡す値（idCard, passport, drivers, residencePermit, … のいずれか）
    var apiDocType: String {
        switch self {
        case .passport: return "passport"
        case .driverLicense: return "drivers"
        case .residentCard: return "residencePermit"
        }
    }
}

struct KYBDocumentUploadView: View {
    let companyId: String
    let uboId: String
    
    @State private var selectedDocumentType: DocumentUploadType?
    @State private var passportImageData: Data?
    @State private var driverLicenseFrontData: Data?
    @State private var driverLicenseBackData: Data?
    @State private var residentCardImageData: Data?
    
    @State private var passportPickerItem: PhotosPickerItem?
    @State private var driverFrontPickerItem: PhotosPickerItem?
    @State private var driverBackPickerItem: PhotosPickerItem?
    @State private var residentPickerItem: PhotosPickerItem?
    
    @State private var isUploading = false
    @State private var errorMessage: String?
    @State private var uploadSuccess = false
    
    private let backgroundColor = Color(red: 28/255, green: 26/255, blue: 27/255)
    private let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    private let secondaryText = Color(red: 161/255, green: 161/255, blue: 161/255)
    private let accentColor = Color(red: 100/255, green: 180/255, blue: 190/255)
    
    private var canSubmit: Bool {
        guard let type = selectedDocumentType else { return false }
        switch type {
        case .passport: return passportImageData != nil
        case .driverLicense: return driverLicenseFrontData != nil && driverLicenseBackData != nil
        case .residentCard: return residentCardImageData != nil
        }
    }
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // プログレス
                    KYBProgressBar(currentStep: 1, totalSteps: 1)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
                    
                    // ========== 上カラム：書類種別トグル ==========
                    VStack(alignment: .leading, spacing: 12) {
                        Text("書類の種類を選択")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                        
                        HStack(spacing: 10) {
                            ForEach(DocumentUploadType.allCases, id: \.self) { type in
                                DocumentTypeToggleButton(
                                    title: type.rawValue,
                                    isSelected: selectedDocumentType == type,
                                    accentColor: accentColor,
                                    cardBackground: cardBackground,
                                    secondaryText: secondaryText
                                ) {
                                    selectedDocumentType = type
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // ========== 下カラム：アップロードボックス ==========
                    if selectedDocumentType != nil {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("写真をアップロード")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                            
                            uploadSection
                        }
                    }
                    
                    Spacer(minLength: 140)
                }
            }
            
            // 提出ボタン
            VStack {
                Spacer()
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
                Button {
                    Task { await submitDocument() }
                } label: {
                    Group {
                        if isUploading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(height: 56)
                        } else {
                            HStack {
                                Image(systemName: "doc.fill")
                                Text(uploadSuccess ? "提出完了" : "書類を提出する")
                            }
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .background(canSubmit && !isUploading ? accentColor : secondaryText.opacity(0.3))
                .cornerRadius(12)
                .disabled(!canSubmit || isUploading)
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
    
    // MARK: - アップロードセクション（1 or 2 ボックス）
    
    @ViewBuilder
    private var uploadSection: some View {
        switch selectedDocumentType {
        case .passport:
            SingleUploadBox(
                title: "パスポート",
                imageData: $passportImageData,
                pickerItem: $passportPickerItem,
                isUploading: isUploading,
                accentColor: accentColor,
                cardBackground: cardBackground,
                secondaryText: secondaryText,
                onLoadImage: loadImageData
            )
            .padding(.horizontal, 20)
            
        case .driverLicense:
            VStack(spacing: 16) {
                SingleUploadBox(
                    title: "運転免許証（表）",
                    imageData: $driverLicenseFrontData,
                    pickerItem: $driverFrontPickerItem,
                    isUploading: isUploading,
                    accentColor: accentColor,
                    cardBackground: cardBackground,
                    secondaryText: secondaryText,
                    onLoadImage: loadImageData
                )
                SingleUploadBox(
                    title: "運転免許証（裏）",
                    imageData: $driverLicenseBackData,
                    pickerItem: $driverBackPickerItem,
                    isUploading: isUploading,
                    accentColor: accentColor,
                    cardBackground: cardBackground,
                    secondaryText: secondaryText,
                    onLoadImage: loadImageData
                )
            }
            .padding(.horizontal, 20)
            
        case .residentCard:
            SingleUploadBox(
                title: "住民基本カード",
                imageData: $residentCardImageData,
                pickerItem: $residentPickerItem,
                isUploading: isUploading,
                accentColor: accentColor,
                cardBackground: cardBackground,
                secondaryText: secondaryText,
                onLoadImage: loadImageData
            )
            .padding(.horizontal, 20)
            
        case .none:
            EmptyView()
        }
    }
    
    // MARK: - 画像読み込み
    
    private func loadImageData(from item: PhotosPickerItem?, into binding: Binding<Data?>) async {
        guard let item = item else {
            await MainActor.run { binding.wrappedValue = nil }
            return
        }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run { binding.wrappedValue = data }
            } else {
                await MainActor.run {
                    binding.wrappedValue = nil
                    errorMessage = "画像の読み込みに失敗しました"
                }
            }
        } catch {
            await MainActor.run {
                binding.wrappedValue = nil
                errorMessage = "画像の読み込みに失敗しました: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - 提出処理（Rain API）
    
    private func submitDocument() async {
        await MainActor.run {
            isUploading = true
            errorMessage = nil
        }
        
        defer { Task { @MainActor in isUploading = false } }
        
        guard let type = selectedDocumentType else {
            await MainActor.run { errorMessage = "書類の種類を選択してください" }
            return
        }
        
        do {
            switch type {
            case .passport:
                guard let data = passportImageData else {
                    await MainActor.run { errorMessage = "パスポートの写真を選択してください" }
                    return
                }
                try await RainAPIManager.shared.uploadUBODocument(
                    companyId: companyId,
                    uboId: uboId,
                    imageData: data,
                    docType: type.apiDocType,
                    side: "front",
                    country: "JPN",
                    countryCode: "JP"
                )
            case .driverLicense:
                guard let front = driverLicenseFrontData, let back = driverLicenseBackData else {
                    await MainActor.run { errorMessage = "表・裏の写真を両方選択してください" }
                    return
                }
                try await RainAPIManager.shared.uploadUBODocument(
                    companyId: companyId,
                    uboId: uboId,
                    imageData: front,
                    docType: type.apiDocType,
                    side: "front",
                    country: "JPN",
                    countryCode: "JP"
                )
                try await RainAPIManager.shared.uploadUBODocument(
                    companyId: companyId,
                    uboId: uboId,
                    imageData: back,
                    docType: type.apiDocType,
                    side: "back",
                    country: "JPN",
                    countryCode: "JP"
                )
            case .residentCard:
                guard let data = residentCardImageData else {
                    await MainActor.run { errorMessage = "住民基本カードの写真を選択してください" }
                    return
                }
                try await RainAPIManager.shared.uploadUBODocument(
                    companyId: companyId,
                    uboId: uboId,
                    imageData: data,
                    docType: type.apiDocType,
                    side: "front",
                    country: "JPN",
                    countryCode: "JP"
                )
            }
            await MainActor.run { uploadSuccess = true }
        } catch let error as RainAPIError {
            await MainActor.run { errorMessage = error.localizedDescription }
        } catch {
            await MainActor.run { errorMessage = "アップロードに失敗しました: \(error.localizedDescription)" }
        }
    }
}

// MARK: - 書類種別トグルボタン（常に3選択肢が見えるデザイン）

struct DocumentTypeToggleButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let cardBackground: Color
    let secondaryText: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? accentColor : cardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? accentColor : secondaryText.opacity(0.4), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 単一アップロードボックス（直感的な1ボックス）

struct SingleUploadBox: View {
    let title: String
    @Binding var imageData: Data?
    @Binding var pickerItem: PhotosPickerItem?
    let isUploading: Bool
    let accentColor: Color
    let cardBackground: Color
    let secondaryText: Color
    let onLoadImage: (PhotosPickerItem?, Binding<Data?>) async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(secondaryText)
            
            PhotosPicker(selection: $pickerItem, matching: .images) {
                Group {
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentColor.opacity(0.6), lineWidth: 2)
                            )
                            .overlay(
                                Text("タップして変更")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(6)
                                    .background(.black.opacity(0.5))
                                    .cornerRadius(6),
                                alignment: .bottomTrailing
                            )
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 36))
                                .foregroundStyle(accentColor)
                            Text("タップして写真を選択")
                                .font(.subheadline)
                                .foregroundStyle(secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 160)
                        .background(cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6]))
                        )
                    }
                }
            }
            .onChange(of: pickerItem) { _, newValue in
                Task {
                    await onLoadImage(newValue, $imageData)
                }
            }
            .disabled(isUploading)
        }
    }
}

// MARK: - プレビュー

#Preview {
    NavigationStack {
        KYBDocumentUploadView(companyId: "comp_sample", uboId: "ubo_sample")
    }
}
