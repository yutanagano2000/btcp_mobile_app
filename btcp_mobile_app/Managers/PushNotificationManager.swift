//
//  PushNotificationManager.swift
//  btcp_mobile_app
//

import FirebaseAuth
import FirebaseMessaging
import Foundation
import UIKit
import UserNotifications

/// プッシュ通知の権限リクエスト・FCMトークン取得・Firestore送信を管理
final class PushNotificationManager {
    static let shared = PushNotificationManager()

    private init() {}

    /// 通知権限をリクエストし、リモート通知登録を行う
    func requestPermissionAndRegister() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ 通知権限エラー: \(error.localizedDescription)")
                return
            }
            print(granted ? "✅ 通知権限を許可しました" : "⚠️ 通知権限が拒否されました")

            Task { @MainActor in
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    /// FCMトークンを取得し、ログインユーザーがいればFirestoreに送信
    func uploadFCMTokenIfNeeded() async {
        guard let token = try? await Messaging.messaging().token(), !token.isEmpty else {
            print("📲 FCMトークンがまだ取得できていません")
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            print("📲 未ログインのためFCMトークンは送信しません")
            return
        }

        do {
            try await FirestoreManager.shared.updateFCMToken(firebaseUid: uid, fcmToken: token)
            print("📲 FCMトークンをFirestoreに送信しました")
        } catch {
            print("❌ FCMトークン送信エラー: \(error.localizedDescription)")
        }
    }
}
