//
//  CardInformationView.swift
//  btcp_mobile_app
//
//  Created by 永野佑太 on 2025/12/22.
//
import SwiftUI

struct CardInformationView: View {
    @Environment(\.dismiss) private var dismiss
    private let headerHeight: CGFloat = 50
    @State private var isCardLocked = false
    @State private var isPaymentNotificationDisabled = false
    @State private var isReceiptRegistrationNotRequired = false
    @State private var isInformationVisible = true
    @State private var selectedTab: TabType = .cardInfo
    @State private var showCopyToast = false

    // タブの種類を定義
    enum TabType {
        case history
        case cardInfo
    }

    // クリップボードにコピーする関数
    private func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
        showCopyToast = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒
            showCopyToast = false
        }
    }

    var body: some View {
        // 画面ビュー
        NavigationStack {
            ZStack {
                Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 固定ヘッダー
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .frame(height: headerHeight)
                    .padding(.horizontal)
                    .background(Color(red: 28 / 255, green: 26 / 255, blue: 27 / 255))

                    // スクロールする内容
                    ScrollView {
                        VStack(spacing: 20) {
                            Image("blank_card")
                            HStack {
                                Text("カード4")
                                    .foregroundStyle(Color.white)
                                // ここがナビゲーションリンク
                                NavigationLink {
                                    CardNameEditView()
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 14))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal)
                            NavigationLink {
                                CardGroupSettingView()
                            } label: {
                                Text("グループを設定")
                                    .foregroundStyle(Color.white)
                                    .font(.system(size: 14))
                            }
                            .padding(8)
                            .buttonStyle(.plain)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray, lineWidth: 1)
                            )

                            // タブバー
                            TabBarView(selectedTab: $selectedTab)

                            // タブの内容に応じて表示を切り替え
                            if selectedTab == .history {
                                HistoryContent
                                    .padding()
                            } else {
                                CardInfoContent
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true) // デフォルトの戻るボタンを非表示
            .overlay(
                // トーストメッセージ
                Group {
                    if showCopyToast {
                        VStack {
                            Text("クリップボードにコピーされました")
                                .foregroundStyle(.white)
                                .font(.system(size: 16))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.8))
                                )
                                .transition(.opacity.combined(with: .scale))
                                .padding(.top, headerHeight + 20)
                            Spacer()
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: showCopyToast)
            )
        }
    }

    // 利用履歴のコンテンツ
    private var HistoryContent: some View {
        VStack(spacing: 20) {
            // 日付選択と検索欄を同じ行に配置
            HStack(spacing: 12) {
                Button("2025年12月") {}
                    .foregroundStyle(Color(red: 17 / 255, green: 79 / 255, blue: 86 / 255))
                    .font(.system(size: 16))
                Image(systemName: "chevron.down")
                    .foregroundStyle(Color(red: 17 / 255, green: 79 / 255, blue: 86 / 255))
                    .font(.system(size: 15))

                // 検索欄
                HStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                    TextField(
                        "",
                        text: .constant(""),
                        prompt: Text("取引先・金額で検索")
                            .foregroundStyle(.gray.opacity(0.5))
                    )
                    .textFieldStyle(.plain)
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255))
                )
            }

            Text("条件に合致する利用履歴がありません")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.7))
                .padding()
        }
    }

    // カード情報のコンテンツ（元のContentをリネーム）
    private var CardInfoContent: some View {
        VStack(spacing: 20) {
            // 最初のブロック
            VStack(spacing: 16) {
                HStack {
                    Text("カードを一時ロック")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                    Spacer()
                    Toggle("", isOn: $isCardLocked)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        .scaleEffect(1.2)
                }
                HStack {
                    Text("このカードのアプリ決済通知を無効にする")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    Toggle("", isOn: $isPaymentNotificationDisabled)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        .scaleEffect(1.2)
                }
                HStack {
                    Text("領収書登録が不要なカードとして扱う")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    Toggle("", isOn: $isReceiptRegistrationNotRequired)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        .scaleEffect(1.2)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 0.3))

            // 2つ目のブロック
            VStack(spacing: 16) {
                HStack {
                    Button {
                        isInformationVisible.toggle()
                    } label: {
                        Text(isInformationVisible ? "タップして情報を非表示" : "タップして情報を表示")
                            .foregroundStyle(Color.blue)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                HStack {
                    Text("カード名")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    ZStack {
                        HStack {
                            Spacer()
                            Text("カード4")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 1 : 0)
                        HStack {
                            Spacer()
                            Text("****")
                                .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 0 : 1)
                    }
                }
                HStack {
                    Text("カード種別")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    ZStack {
                        HStack {
                            Spacer()
                            Text("バーチャルカード")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 1 : 0)
                        HStack {
                            Spacer()
                            Text("****")
                                .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 0 : 1)
                    }
                }
                HStack {
                    Text("カード番号")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    ZStack {
                        HStack(spacing: 10) {
                            Spacer()
                            Text("4531 7400 0279 1474")
                                .monospacedDigit()
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                            Button {
                                copyToClipboard(text: "4531 7400 0279 1474")
                            } label: {
                                Image(systemName: "document.on.document")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.plain)
                        }
                        .opacity(isInformationVisible ? 1 : 0)
                        HStack(spacing: 10) {
                            Spacer()
                            Text("**** **** **** 1474")
                                .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 0 : 1)
                    }
                }
                HStack {
                    Text("カード名義人")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    ZStack {
                        HStack(spacing: 10) {
                            Spacer()
                            Text("SATOSHI NAKAMOTO")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                            Button {
                                copyToClipboard(text: "SATOSHI NAKAMOTO")
                            } label: {
                                Image(systemName: "document.on.document")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.plain)
                        }
                        .opacity(isInformationVisible ? 1 : 0)
                        HStack(spacing: 10) {
                            Spacer()
                            Text("****")
                                .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 0 : 1)
                    }
                }
                HStack {
                    Text("有効期限")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    ZStack {
                        HStack {
                            Spacer()
                            Text("12/2030")
                                .monospacedDigit()
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 1 : 0)
                        HStack {
                            Spacer()
                            Text("**" + "/****")
                                .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                .monospacedDigit()
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 0 : 1)
                    }
                }
                HStack {
                    Text("CVV(セキュリティコード)")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    ZStack {
                        HStack(spacing: 10) {
                            Spacer()
                            Text("586")
                                .monospacedDigit()
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                            Button {
                                copyToClipboard(text: "586")
                            } label: {
                                Image(systemName: "document.on.document")
                                    .foregroundStyle(Color.white)
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.plain)
                        }
                        .opacity(isInformationVisible ? 1 : 0)
                        HStack(spacing: 10) {
                            Spacer()
                            Text("***")
                                .foregroundStyle(Color(red: 59 / 255, green: 59 / 255, blue: 59 / 255))
                                .font(.system(size: 16))
                        }
                        .opacity(isInformationVisible ? 0 : 1)
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 0.3))

            // 3つ目のブロック
            VStack(spacing: 16) {
                HStack {
                    Text("月間リミット")
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.system(size: 16))
                    Spacer()
                    NavigationLink {
                        MonthlyLimitView()
                    } label: {
                        HStack {
                            Text("¥5,000")
                                .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                                .font(.system(size: 16))
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
                NavigationLink {
                    DailyLimitView()
                } label: {
                    HStack {
                        Text("日次リミット")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 14))
                    }
                }
                .buttonStyle(.plain)
                NavigationLink {
                    TransactionLimitView()
                } label: {
                    HStack {
                        Text("取引あたりのリミット")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 14))
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 0.3))

            // 4つ目のブロック
            VStack(spacing: 16) {
                NavigationLink {
                    CardHolderView()
                } label: {
                    HStack {
                        Text("カード保有者")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                        Spacer()
                        HStack {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                NavigationLink {
                    CardManagerAndAssistantView()
                } label: {
                    HStack {
                        Text("カードの管理者と補助者")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.plain)
                NavigationLink {
                    CardAccessibleUsersView()
                } label: {
                    HStack {
                        Text("このカードにアクセスできるユーザー")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.white)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 0.3))

            // 5つ目のブロック
            VStack(spacing: 16) {
                HStack {
                    HStack {
                        Text("請求書回収メールアドレス")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                        Image(systemName: "info.circle")
                            .foregroundStyle(Color.white)
                            .fontWeight(.thin)
                    }
                    Spacer()
                    NavigationLink {
                        Text("請求書回収メールアドレス設定画面")
                    } label: {
                        Text("発行する")
                            .foregroundStyle(Color.white)
                            .fontWeight(.thin)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                            .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 0.3))

            // 6つ目のブロック
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    HStack {
                        Text("決済できない場合")
                            .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("ロックを解除しても決済できない場合は、")
                            Text("お問い合わせフォームよりご連絡ください。")
                        }
                        .foregroundStyle(Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                        .font(.footnote)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 0.3))

            // 7つ目のブロック
            VStack(spacing: 16) {
                HStack {
                    Button {} label: {
                        Text("カードの解約")
                            .foregroundStyle(Color.red)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray, lineWidth: 0.3))
        }
    }
}

// タブバーコンポーネント（グレーの長方形で囲み、選択タブの背景をより黒く）
struct TabBarView: View {
    @Binding var selectedTab: CardInformationView.TabType

    var body: some View {
        HStack(spacing: 0) {
            // 利用履歴タブ
            Button {
                selectedTab = .history
            } label: {
                Text("利用履歴")
                    .foregroundStyle(selectedTab == .history ? Color.white : Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                    .font(.system(size: 16))
                    .fontWeight(selectedTab == .history ? .semibold : .regular)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8) // 12から8に変更（約30%細く）
                    .background(
                        selectedTab == .history
                            ? Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255) // 選択時はより黒い背景
                            : Color.clear
                    )
            }

            // カード情報タブ
            Button {
                selectedTab = .cardInfo
            } label: {
                Text("カード情報")
                    .foregroundStyle(selectedTab == .cardInfo ? Color.white : Color(red: 161 / 255, green: 161 / 255, blue: 161 / 255))
                    .font(.system(size: 16))
                    .fontWeight(selectedTab == .cardInfo ? .semibold : .regular)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8) // 12から8に変更（約30%細く）
                    .background(
                        selectedTab == .cardInfo
                            ? Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255) // 選択時はより黒い背景
                            : Color.clear
                    )
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 30 / 255, green: 30 / 255, blue: 30 / 255)) // グレーの長方形で囲む
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    CardInformationView()
}
