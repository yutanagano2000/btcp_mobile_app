//
//  FirestoreManager.swift
//  btcp_mobile_app
//
//  Created on 2025/01/19.
//

import FirebaseFirestore
import Foundation

/// Firestoreユーザーモデル
struct FirestoreUser: Codable {
    let id: String // Firebase UID
    let email: String
    let walletAddress: String
    let createdAt: Date
    let updatedAt: Date
    var rainUserId: String? // KYB後に設定
    var kybStatus: String? // pending, approved, rejected

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case walletAddress
        case createdAt
        case updatedAt
        case rainUserId
        case kybStatus
    }
}

/// Firestoreエラー
enum FirestoreManagerError: Error, LocalizedError {
    case userNotFound
    case saveFailed(String)
    case fetchFailed(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "ユーザーが見つかりません"
        case .saveFailed(let message):
            return "保存失敗: \(message)"
        case .fetchFailed(let message):
            return "取得失敗: \(message)"
        }
    }
}

/// Firestore操作を管理するクラス
final class FirestoreManager {
    static let shared = FirestoreManager()

    private let db = Firestore.firestore()
    private let usersCollection = "users"

    private init() {}

    // MARK: - Save User

    /// ユーザー情報を保存（新規作成 or 更新）
    /// - Parameters:
    ///   - firebaseUid: Firebase ユーザーID
    ///   - email: メールアドレス
    ///   - walletAddress: ウォレットアドレス
    func saveUser(firebaseUid: String, email: String, walletAddress: String) async throws {
        print("💾 Firestore ユーザー保存開始...")
        print("👤 Firebase UID: \(firebaseUid)")
        print("📧 Email: \(email)")
        print("📍 Wallet: \(walletAddress)")

        let now = Date()

        // 既存ユーザーをチェック
        let existingUser = try? await getUser(firebaseUid: firebaseUid)

        let userData: [String: Any] = [
            "id": firebaseUid,
            "email": email,
            "walletAddress": walletAddress,
            "createdAt": existingUser?.createdAt ?? now, // 既存なら元のcreatedAtを保持
            "updatedAt": now
        ]

        do {
            try await db.collection(usersCollection).document(firebaseUid).setData(userData, merge: true)
            print("✅ Firestore ユーザー保存完了")
        } catch {
            print("❌ Firestore 保存エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Get User

    /// ユーザー情報を取得
    /// - Parameter firebaseUid: Firebase ユーザーID
    /// - Returns: FirestoreUser
    func getUser(firebaseUid: String) async throws -> FirestoreUser {
        print("📖 Firestore ユーザー取得: \(firebaseUid)")

        do {
            let document = try await db.collection(usersCollection).document(firebaseUid).getDocument()

            guard document.exists, let data = document.data() else {
                throw FirestoreManagerError.userNotFound
            }

            let user = FirestoreUser(
                id: data["id"] as? String ?? firebaseUid,
                email: data["email"] as? String ?? "",
                walletAddress: data["walletAddress"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                rainUserId: data["rainUserId"] as? String,
                kybStatus: data["kybStatus"] as? String
            )

            print("✅ Firestore ユーザー取得完了")
            return user
        } catch let error as FirestoreManagerError {
            throw error
        } catch {
            print("❌ Firestore 取得エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.fetchFailed(error.localizedDescription)
        }
    }

    // MARK: - Update Rain User ID

    /// KYB申請後にRain User IDを保存
    /// - Parameters:
    ///   - firebaseUid: Firebase ユーザーID
    ///   - rainUserId: Rain APIから取得したユーザーID
    ///   - kybStatus: KYBステータス
    func updateRainUserId(firebaseUid: String, rainUserId: String, kybStatus: String = "approved") async throws {
        print("💾 Firestore Rain User ID 更新...")
        print("👤 Firebase UID: \(firebaseUid)")
        print("🌧️ Rain User ID: \(rainUserId)")

        let updateData: [String: Any] = [
            "rainUserId": rainUserId,
            "kybStatus": kybStatus,
            "updatedAt": Date()
        ]

        do {
            try await db.collection(usersCollection).document(firebaseUid).updateData(updateData)
            print("✅ Firestore Rain User ID 更新完了")
        } catch {
            print("❌ Firestore 更新エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Reset KYB Status
    
    /// KYBステータスをリセット（開発・テスト用）
    /// - Parameter firebaseUid: Firebase ユーザーID
    func resetKYBStatus(firebaseUid: String) async throws {
        print("🔄 Firestore KYBステータス リセット...")
        print("👤 Firebase UID: \(firebaseUid)")
        
        let updateData: [String: Any] = [
            "kybStatus": "not_started",
            "rainUserId": FieldValue.delete(), // rainUserIdも削除
            "updatedAt": Date()
        ]
        
        do {
            try await db.collection(usersCollection).document(firebaseUid).updateData(updateData)
            print("✅ Firestore KYBステータス リセット完了")
        } catch {
            print("❌ Firestore リセットエラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }

    // MARK: - Get User by Rain User ID

    /// Rain User IDからユーザーを検索
    /// - Parameter rainUserId: Rain APIのユーザーID
    /// - Returns: FirestoreUser
    func getUserByRainUserId(rainUserId: String) async throws -> FirestoreUser {
        print("🔍 Firestore Rain User ID で検索: \(rainUserId)")

        do {
            let snapshot = try await db.collection(usersCollection)
                .whereField("rainUserId", isEqualTo: rainUserId)
                .limit(to: 1)
                .getDocuments()

            guard let document = snapshot.documents.first, let data = document.data() as? [String: Any] else {
                throw FirestoreManagerError.userNotFound
            }

            let user = FirestoreUser(
                id: data["id"] as? String ?? document.documentID,
                email: data["email"] as? String ?? "",
                walletAddress: data["walletAddress"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                rainUserId: data["rainUserId"] as? String,
                kybStatus: data["kybStatus"] as? String
            )

            print("✅ Firestore ユーザー検索完了")
            return user
        } catch let error as FirestoreManagerError {
            throw error
        } catch {
            print("❌ Firestore 検索エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.fetchFailed(error.localizedDescription)
        }
    }
}
