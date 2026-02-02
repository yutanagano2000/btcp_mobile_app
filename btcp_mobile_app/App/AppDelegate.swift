//
//  AppDelegate.swift
//  btcp_mobile_app
//

import FirebaseMessaging
import UIKit
import UserNotifications

/// Push Notifications / FCM 用の AppDelegate
/// - FirebaseApp.configure() は App の init で実施済み
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        PushNotificationManager.shared.requestPermissionAndRegister()
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        print("📲 APNs デバイストークン登録完了")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ リモート通知登録失敗: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// フォアグラウンド受信時も通知を表示する
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken, !token.isEmpty else {
            print("📲 FCMトークンが空です")
            return
        }
        print("📲 FCMトークン受信: \(token.prefix(20))...")

        Task {
            await PushNotificationManager.shared.uploadFCMTokenIfNeeded()
        }
    }
}
