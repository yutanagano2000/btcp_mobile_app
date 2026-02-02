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
    var rainUserId: String? // KYC後に設定（UBOの場合）
    var kycStatus: String? // pending, approved, rejected (UBOのKYCステータス)
    var organizationId: String? // 所属する組織ID
    var cardId: String? // カード作成後に設定
    var kybStatus: String? { // 後方互換性のため（kycStatusと同じ値を使用）
        get { kycStatus }
        set { kycStatus = newValue }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case walletAddress
        case createdAt
        case updatedAt
        case rainUserId
        case kycStatus
        case organizationId
        case cardId
        case kybStatus // 後方互換性のため
    }
    
    init(id: String, email: String, walletAddress: String, createdAt: Date, updatedAt: Date, rainUserId: String? = nil, kycStatus: String? = nil, organizationId: String? = nil, cardId: String? = nil) {
        self.id = id
        self.email = email
        self.walletAddress = walletAddress
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.rainUserId = rainUserId
        self.kycStatus = kycStatus
        self.organizationId = organizationId
        self.cardId = cardId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        walletAddress = try container.decode(String.self, forKey: .walletAddress)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        rainUserId = try container.decodeIfPresent(String.self, forKey: .rainUserId)
        // kycStatusとkybStatusの両方をチェック（後方互換性）
        if let kyc = try? container.decodeIfPresent(String.self, forKey: .kycStatus) {
            kycStatus = kyc
        } else if let kyb = try? container.decodeIfPresent(String.self, forKey: .kybStatus) {
            kycStatus = kyb
        } else {
            kycStatus = nil
        }
        organizationId = try container.decodeIfPresent(String.self, forKey: .organizationId)
        cardId = try container.decodeIfPresent(String.self, forKey: .cardId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(walletAddress, forKey: .walletAddress)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(rainUserId, forKey: .rainUserId)
        // kycStatusとkybStatusの両方を保存（後方互換性）
        if let kyc = kycStatus {
            try container.encode(kyc, forKey: .kycStatus)
            try container.encode(kyc, forKey: .kybStatus) // 後方互換性のため
        }
        try container.encodeIfPresent(organizationId, forKey: .organizationId)
        try container.encodeIfPresent(cardId, forKey: .cardId)
    }
}

/// Firestore組織モデル
struct FirestoreOrganization: Codable {
    let id: String // 組織ID（Rain APIのapplication ID）
    let name: String // 会社名
    let rainApplicationId: String // Rain APIのapplication ID
    let createdAt: Date
    let updatedAt: Date
    var kybStatus: String? // pending, approved, rejected
    var uboRainUserId: String? // UBOのRain User ID（KYC完了後に設定）

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case rainApplicationId
        case createdAt
        case updatedAt
        case kybStatus
        case uboRainUserId
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
    private let organizationsCollection = "organizations"

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

            // kycStatusとkybStatusの両方をチェック（後方互換性）
            let kycStatusValue = data["kycStatus"] as? String ?? data["kybStatus"] as? String
            
            let user = FirestoreUser(
                id: data["id"] as? String ?? firebaseUid,
                email: data["email"] as? String ?? "",
                walletAddress: data["walletAddress"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                rainUserId: data["rainUserId"] as? String,
                kycStatus: kycStatusValue,
                organizationId: data["organizationId"] as? String,
                cardId: data["cardId"] as? String
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

    // MARK: - Save Card ID
    
    /// カード作成後にカードIDを保存
    /// - Parameters:
    ///   - firebaseUid: Firebase ユーザーID
    ///   - cardId: Rain APIから取得したカードID
    func saveCardId(firebaseUid: String, cardId: String) async throws {
        print("💾 Firestore カードID 保存...")
        print("👤 Firebase UID: \(firebaseUid)")
        print("💳 Card ID: \(cardId)")
        
        let updateData: [String: Any] = [
            "cardId": cardId,
            "updatedAt": Date()
        ]
        
        do {
            try await db.collection(usersCollection).document(firebaseUid).setData(updateData, merge: true)
            print("✅ Firestore カードID 保存完了")
        } catch {
            print("❌ Firestore カードID 保存エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }

    /// KYB申請後にRain User IDを保存
    /// - Parameters:
    ///   - firebaseUid: Firebase ユーザーID
    ///   - rainUserId: Rain APIから取得したユーザーID
    ///   - kybStatus: KYBステータス
    func updateRainUserId(firebaseUid: String, rainUserId: String, kybStatus: String = "approved") async throws {
        print("💾 Firestore Rain User ID 更新...")
        print("👤 Firebase UID: \(firebaseUid)")
        print("🌧️ Rain User ID: \(rainUserId)")
        print("📊 KYB Status: \(kybStatus)")

        let updateData: [String: Any] = [
            "rainUserId": rainUserId,
            "kybStatus": kybStatus,
            "updatedAt": Date()
        ]

        do {
            // updateDataはドキュメントが存在しない場合にエラーになるため、
            // setData(merge: true)を使用してドキュメントが存在しない場合も対応
            try await db.collection(usersCollection).document(firebaseUid).setData(updateData, merge: true)
            print("✅ Firestore Rain User ID 更新完了")
            
            // 更新が成功したことを確認
            let updatedUser = try await getUser(firebaseUid: firebaseUid)
            print("🔍 更新確認:")
            print("   - Rain User ID: \(updatedUser.rainUserId ?? "なし")")
            print("   - KYB Status: \(updatedUser.kybStatus ?? "なし")")
        } catch {
            print("❌ Firestore 更新エラー: \(error.localizedDescription)")
            print("🔍 エラー詳細: \(error)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }

    // MARK: - FCM Token

    /// FCMトークンをユーザードキュメントに保存（プッシュ通知送信用）
    /// - Parameters:
    ///   - firebaseUid: Firebase ユーザーID
    ///   - fcmToken: FCM デバイストークン
    func updateFCMToken(firebaseUid: String, fcmToken: String) async throws {
        print("📲 Firestore FCMトークン更新...")
        print("👤 Firebase UID: \(firebaseUid)")

        let updateData: [String: Any] = [
            "fcmToken": fcmToken,
            "updatedAt": Date()
        ]

        do {
            try await db.collection(usersCollection).document(firebaseUid).setData(updateData, merge: true)
            print("✅ Firestore FCMトークン更新完了")
        } catch {
            print("❌ Firestore FCMトークン更新エラー: \(error.localizedDescription)")
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

            // kycStatusとkybStatusの両方をチェック（後方互換性）
            let kycStatusValue = data["kycStatus"] as? String ?? data["kybStatus"] as? String
            
            let user = FirestoreUser(
                id: data["id"] as? String ?? document.documentID,
                email: data["email"] as? String ?? "",
                walletAddress: data["walletAddress"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                rainUserId: data["rainUserId"] as? String,
                kycStatus: kycStatusValue,
                organizationId: data["organizationId"] as? String
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
    
    // MARK: - Organization Management
    
    /// 組織を保存（法人アカウント作成後）
    /// - Parameters:
    ///   - organizationId: 組織ID（Rain APIのapplication ID）
    ///   - name: 会社名
    ///   - rainApplicationId: Rain APIのapplication ID
    ///   - kybStatus: KYBステータス
    func saveOrganization(
        organizationId: String,
        name: String,
        rainApplicationId: String,
        kybStatus: String = "approved"
    ) async throws {
        print("💾 Firestore 組織保存開始...")
        print("🏢 Organization ID: \(organizationId)")
        print("📛 Name: \(name)")
        print("🌧️ Rain Application ID: \(rainApplicationId)")
        print("📊 KYB Status: \(kybStatus)")
        
        let now = Date()
        
        let organizationData: [String: Any] = [
            "id": organizationId,
            "name": name,
            "rainApplicationId": rainApplicationId,
            "createdAt": now,
            "updatedAt": now,
            "kybStatus": kybStatus
        ]
        
        do {
            try await db.collection(organizationsCollection).document(organizationId).setData(organizationData, merge: true)
            print("✅ Firestore 組織保存完了")
        } catch {
            print("❌ Firestore 組織保存エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }
    
    /// 組織情報を取得
    /// - Parameter organizationId: 組織ID
    /// - Returns: FirestoreOrganization
    func getOrganization(organizationId: String) async throws -> FirestoreOrganization {
        print("📖 Firestore 組織取得: \(organizationId)")
        
        do {
            let document = try await db.collection(organizationsCollection).document(organizationId).getDocument()
            
            guard document.exists, let data = document.data() else {
                throw FirestoreManagerError.userNotFound
            }
            
            let organization = FirestoreOrganization(
                id: data["id"] as? String ?? organizationId,
                name: data["name"] as? String ?? "",
                rainApplicationId: data["rainApplicationId"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date(),
                kybStatus: data["kybStatus"] as? String,
                uboRainUserId: data["uboRainUserId"] as? String
            )
            
            print("✅ Firestore 組織取得完了")
            return organization
        } catch let error as FirestoreManagerError {
            throw error
        } catch {
            print("❌ Firestore 組織取得エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.fetchFailed(error.localizedDescription)
        }
    }
    
    /// UBOのRain User IDを組織に保存
    /// - Parameters:
    ///   - organizationId: 組織ID
    ///   - uboRainUserId: UBOのRain User ID
    func updateOrganizationUBO(organizationId: String, uboRainUserId: String) async throws {
        print("💾 Firestore 組織UBO更新...")
        print("🏢 Organization ID: \(organizationId)")
        print("👤 UBO Rain User ID: \(uboRainUserId)")
        
        let updateData: [String: Any] = [
            "uboRainUserId": uboRainUserId,
            "updatedAt": Date()
        ]
        
        do {
            try await db.collection(organizationsCollection).document(organizationId).setData(updateData, merge: true)
            print("✅ Firestore 組織UBO更新完了")
        } catch {
            print("❌ Firestore 組織UBO更新エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }
    
    // MARK: - UBO (User) Management
    
    /// UBO（ユーザー）を保存（KYC完了後）
    /// - Parameters:
    ///   - firebaseUid: Firebase UID
    ///   - email: メールアドレス
    ///   - walletAddress: ウォレットアドレス
    ///   - rainUserId: Rain APIのユーザーID（UBOのID）
    ///   - organizationId: 所属する組織ID
    ///   - kycStatus: KYCステータス
    func saveUBO(
        firebaseUid: String,
        email: String,
        walletAddress: String,
        rainUserId: String,
        organizationId: String,
        kycStatus: String = "approved"
    ) async throws {
        print("💾 Firestore UBO保存開始...")
        print("👤 Firebase UID: \(firebaseUid)")
        print("📧 Email: \(email)")
        print("📍 Wallet: \(walletAddress)")
        print("🌧️ Rain User ID: \(rainUserId)")
        print("🏢 Organization ID: \(organizationId)")
        print("📊 KYC Status: \(kycStatus)")
        
        let now = Date()
        
        // 既存ユーザーをチェック
        let existingUser = try? await getUser(firebaseUid: firebaseUid)
        
        let userData: [String: Any] = [
            "id": firebaseUid,
            "email": email,
            "walletAddress": walletAddress,
            "createdAt": existingUser?.createdAt ?? now,
            "updatedAt": now,
            "rainUserId": rainUserId,
            "kycStatus": kycStatus,
            "kybStatus": kycStatus, // 後方互換性のため
            "organizationId": organizationId
        ]
        
        do {
            try await db.collection(usersCollection).document(firebaseUid).setData(userData, merge: true)
            print("✅ Firestore UBO保存完了")
        } catch {
            print("❌ Firestore UBO保存エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }
    
    /// UBOのKYCステータスを更新
    /// - Parameters:
    ///   - firebaseUid: Firebase UID
    ///   - rainUserId: Rain APIのユーザーID
    ///   - kycStatus: KYCステータス
    func updateUBOKYCStatus(
        firebaseUid: String,
        rainUserId: String,
        kycStatus: String
    ) async throws {
        print("💾 Firestore UBO KYCステータス更新...")
        print("👤 Firebase UID: \(firebaseUid)")
        print("🌧️ Rain User ID: \(rainUserId)")
        print("📊 KYC Status: \(kycStatus)")
        
        let updateData: [String: Any] = [
            "rainUserId": rainUserId,
            "kycStatus": kycStatus,
            "kybStatus": kycStatus, // 後方互換性のため
            "updatedAt": Date()
        ]
        
        do {
            try await db.collection(usersCollection).document(firebaseUid).setData(updateData, merge: true)
            print("✅ Firestore UBO KYCステータス更新完了")
        } catch {
            print("❌ Firestore UBO KYCステータス更新エラー: \(error.localizedDescription)")
            throw FirestoreManagerError.saveFailed(error.localizedDescription)
        }
    }
}
