//
//  RainAPIManager.swift
//  btcp_mobile_app
//
//  Rain API操作を管理するクラス
//

import Foundation
import CryptoKit
import Security

/// Rain API エラー
enum RainAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case networkError(Error)
    case missingData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .apiError(let message):
            return "APIエラー: \(message)"
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .missingData:
            return "必要なデータが不足しています"
        }
    }
}

/// Rain API レスポンス（法人アカウント作成）
struct CreateCorporateAccountResponse: Codable {
    let userId: String  // rainUserId
    let status: String
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case status
        case message
    }
}

/// 法人アカウント作成結果
struct CorporateAccountResult {
    let organizationId: String  // 組織ID（application ID）
    let organizationName: String  // 組織名
    let initialUserId: String?  // initialUserのID（UBOのIDの可能性）
    let status: String
    let uboKYCVerificationLink: String?  // UBOのKYC検証リンク
    let uboKYCCompletionLink: String?  // UBOのKYC完了リンク
    let uboKYCStatus: String?  // UBOのKYCステータス
}

/// カードシークレット（カード番号とCVC）
struct CardSecrets {
    let cardNumber: String  // カード番号
    let cvc: String  // CVCコード
}

/// GET all users の1ユーザー
struct RainUser: Codable {
    let id: String
    let firstName: String?
    let lastName: String?
    let email: String?
    let companyId: String?
    let applicationStatus: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case email
        case companyId
        case applicationStatus
    }
}

/// GET all users レスポンス（users キーで包まれる場合）
private struct GetUsersResponse: Codable {
    let users: [RainUser]?
}

/// カード作成リクエストパラメータ
struct CreateCardRequest {
    let type: String  // "physical" または "virtual"
    let status: String  // "notActivated" など
    let limit: CardLimit?
    let configuration: CardConfiguration?
    let shipping: ShippingAddress?
    let billing: BillingAddress?
    let bulkShippingGroupId: String?
}

struct CardLimit {
    let amount: Int
    let frequency: String  // "per24HourPeriod" など
}

struct CardConfiguration {
    let displayName: String?
    let productId: String?
    let productRef: String?
    let virtualCardArt: String?
}

struct ShippingAddress {
    let line1: String
    let city: String
    let postalCode: String
    let countryCode: String
    let phoneNumber: String?
    let line2: String?
    let region: String?
    let method: String?  // "standard" など
    let firstName: String?
    let lastName: String?
}

struct BillingAddress {
    let line1: String
    let city: String
    let region: String?
    let postalCode: String
    let countryCode: String
    let line2: String?
    let country: String?
}

/// Rain API操作を管理するクラス
@MainActor
final class RainAPIManager {
    static let shared = RainAPIManager()
    
    private init() {}
    
    /// 法人アカウントを作成（KYB申請 - 簡易版）
    /// - Parameters:
    ///   - walletAddress: Web3Authのウォレットアドレス
    ///   - email: メールアドレス
    ///   - dummyData: ダミーデータ（会社情報など）
    /// - Returns: CorporateAccountResult（組織ID、組織名、initialUser IDを含む）
    func createCorporateAccount(
        walletAddress: String,
        email: String,
        dummyData: [String: Any] = [:]
    ) async throws -> CorporateAccountResult {
        print("🌧️ Rain API: 法人アカウント作成開始...")
        print("📍 Wallet: \(walletAddress)")
        print("📧 Email: \(email)")
        
        guard let url = URL(string: "\(RainAPIConfig.baseURL)\(RainAPIConfig.createCorporateAccountEndpoint)") else {
            throw RainAPIError.invalidURL
        }
        
        // initialUserオブジェクト（必須）
        let initialUserAddress: [String: Any] = [
            "line1": dummyData["addressLine1"] as? String ?? "1-1-1 Shibuya",
            "city": dummyData["city"] as? String ?? "Shibuya-ku",
            "region": dummyData["prefecture"] as? String ?? "Tokyo",
            "postalCode": dummyData["postalCode"] as? String ?? "150-0001",
            "countryCode": "JP"
        ]
        
        var initialUser: [String: Any] = [
            "firstName": dummyData["firstName"] as? String ?? "YutaSwiftApproved",
            "lastName": dummyData["lastName"] as? String ?? "NaganoSwiftApproved",
            "birthDate": dummyData["birthDate"] as? String ?? "1990-02-01",
            "nationalId": dummyData["nationalId"] as? String ?? "123456789012",
            "countryOfIssue": "JP",
            "email": email,
            "address": initialUserAddress,
            "ipAddress": dummyData["ipAddress"] as? String ?? "203.0.113.1",
            "isTermsOfServiceAccepted": true,
            "phoneCountryCode": "81",
            "phoneNumber": dummyData["phoneNumber"] as? String ?? "9012345678",
            "walletAddress": walletAddress
        ]
        
        // 会社の住所
        let companyAddress: [String: Any] = [
            "line1": dummyData["companyAddressLine1"] as? String ?? "1-1-1 Shibuya",
            "city": dummyData["city"] as? String ?? "Shibuya-ku",
            "region": dummyData["prefecture"] as? String ?? "Tokyo",
            "postalCode": dummyData["postalCode"] as? String ?? "150-0001",
            "countryCode": "JP"
        ]
        
        // entity（会社情報）
        let entity: [String: Any] = [
            "name": dummyData["companyName"] as? String ?? "BTC Pay Japan Inc. Approved",
            "type": "INC",
            "description": dummyData["description"] as? String ?? "Virtual card issuing service for cryptocurrency payments",
            "industry": dummyData["industry"] as? String ?? "Financial Transactions Processing, Reserve, and Clearinghouse Activities",
            "registrationNumber": dummyData["corporateNumber"] as? String ?? "0100-01-123456",
            "taxId": dummyData["taxId"] as? String ?? "1234567890123",
            "website": dummyData["website"] as? String ?? "https://btcpay.jp",
            "expectedSpend": dummyData["expectedSpend"] as? String ?? "10000"
        ]
        
        // ultimateBeneficialOwners（実質的受益者）
        let uboAddress: [String: Any] = [
            "line1": dummyData["uboAddressLine1"] as? String ?? "1-1-1 Shibuya",
            "city": dummyData["city"] as? String ?? "Shibuya-ku",
            "region": dummyData["prefecture"] as? String ?? "Tokyo",
            "postalCode": dummyData["postalCode"] as? String ?? "150-0001",
            "countryCode": "JP"
        ]
        
        let ultimateBeneficialOwner: [String: Any] = [
            "firstName": dummyData["uboFirstName"] as? String ?? "YutaApproved",
            "lastName": dummyData["uboLastName"] as? String ?? "NaganoApproved",
            "birthDate": dummyData["uboBirthDate"] as? String ?? "1990-02-01",
            "nationalId": dummyData["uboNationalId"] as? String ?? "123456789012",
            "countryOfIssue": "JP",
            "email": dummyData["uboEmail"] as? String ?? "nagano@btcpay.jp",
            "address": uboAddress
        ]
        
        // リクエストボディ（Rain APIの仕様に合わせる）
        var requestBody: [String: Any] = [
            "initialUser": initialUser,
            "name": dummyData["companyName"] as? String ?? "BTC Approved",
            "address": companyAddress,
            "entity": entity,
            "representatives": [],  // サンプルでは空配列
            "ultimateBeneficialOwners": [ultimateBeneficialOwner]
        ]
        
        // ダミーデータをマージ（上書き可能）
        requestBody.merge(dummyData) { (_, new) in new }
        
        // リクエストボディをJSON形式で出力
        if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("📤 法人アカウント作成リクエスト（JSON形式）:")
            print(jsonString)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw RainAPIError.apiError("リクエストボディの作成に失敗しました: \(error.localizedDescription)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RainAPIError.invalidResponse
            }
            
            print("📡 Rain API レスポンス: ステータスコード \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "不明なエラー"
                print("❌ Rain API エラー: \(errorMessage)")
                throw RainAPIError.apiError("ステータスコード: \(httpResponse.statusCode), \(errorMessage)")
            }
            
            // レスポンスデータをログに出力（デバッグ用）
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Rain API レスポンスデータ: \(responseString)")
            }
            
            // まずJSONオブジェクトとして解析を試みる
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ レスポンスがJSONオブジェクトではありません")
                throw RainAPIError.apiError("レスポンスの形式が正しくありません")
            }
            
            print("📋 レスポンスJSON: \(jsonObject)")
            print("🔍 レスポンスの全キー: \(jsonObject.keys.joined(separator: ", "))")
            
            // レスポンス全体を詳細にログ出力（デバッグ用）
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📄 レスポンス全体（整形済み）:")
                print(jsonString)
            }
            
            // user_idまたはuserIdを探す（柔軟に対応）
            // 注意: レスポンスのルートレベルの"id"はアプリケーションIDや会社IDの可能性があるため、
            // initialUser.idを優先的にチェックする
            var rainUserId: String?
            
            // 組織ID（application ID）を取得
            var organizationId: String?
            var organizationName: String?
            var initialUserId: String?
            
            // パターン1: id（組織ID/application ID）
            if let id = jsonObject["id"] as? String {
                organizationId = id
                print("✅ 組織ID (id) で取得: \(id)")
            }
            
            // パターン2: applicationId
            if let appId = jsonObject["applicationId"] as? String {
                organizationId = appId
                print("✅ 組織ID (applicationId) で取得: \(appId)")
            }
            
            // 組織名を取得
            if let name = jsonObject["name"] as? String {
                organizationName = name
                print("✅ 組織名: \(name)")
            }
            
            // initialUser.id を取得（UBOのIDの可能性）
            if let initialUserDict = jsonObject["initialUser"] as? [String: Any] {
                if let userId = initialUserDict["id"] as? String {
                    initialUserId = userId
                    print("✅ initialUser.id で取得: \(userId)")
                } else if let userId = initialUserDict["user_id"] as? String {
                    initialUserId = userId
                    print("✅ initialUser.user_id で取得: \(userId)")
                } else if let userId = initialUserDict["userId"] as? String {
                    initialUserId = userId
                    print("✅ initialUser.userId で取得: \(userId)")
                } else {
                    print("⚠️ initialUser辞書は存在しますが、id/user_id/userIdが見つかりません")
                    print("🔍 initialUserのキー: \(initialUserDict.keys.joined(separator: ", "))")
                }
            } else {
                print("⚠️ initialUserがレスポンスに含まれていません")
            }
            
            // ultimateBeneficialOwners配列からUBOのIDを取得（フォールバック）
            if initialUserId == nil {
                if let uboArray = jsonObject["ultimateBeneficialOwners"] as? [[String: Any]] {
                    print("🔍 ultimateBeneficialOwners配列を確認中...")
                    for (index, ubo) in uboArray.enumerated() {
                        print("   UBO[\(index)]のキー: \(ubo.keys.joined(separator: ", "))")
                        if let userId = ubo["id"] as? String {
                            initialUserId = userId
                            print("✅ ultimateBeneficialOwners[\(index)].id で取得: \(userId)")
                            break
                        } else if let userId = ubo["user_id"] as? String {
                            initialUserId = userId
                            print("✅ ultimateBeneficialOwners[\(index)].user_id で取得: \(userId)")
                            break
                        } else if let userId = ubo["userId"] as? String {
                            initialUserId = userId
                            print("✅ ultimateBeneficialOwners[\(index)].userId で取得: \(userId)")
                            break
                        }
                    }
                } else {
                    print("⚠️ ultimateBeneficialOwnersもレスポンスに含まれていません")
                }
            }
            
            // users配列から最初のユーザーIDを取得（フォールバック）
            if initialUserId == nil {
                if let usersArray = jsonObject["users"] as? [[String: Any]] {
                    print("🔍 users配列を確認中...")
                    if let firstUser = usersArray.first {
                        if let userId = firstUser["id"] as? String {
                            initialUserId = userId
                            print("✅ users[0].id で取得: \(userId)")
                        } else if let userId = firstUser["user_id"] as? String {
                            initialUserId = userId
                            print("✅ users[0].user_id で取得: \(userId)")
                        } else if let userId = firstUser["userId"] as? String {
                            initialUserId = userId
                            print("✅ users[0].userId で取得: \(userId)")
                        }
                    }
                }
            }
            
            // ルートレベルのuser_idやuserIdを確認（最後のフォールバック）
            if initialUserId == nil {
                if let userId = jsonObject["user_id"] as? String {
                    initialUserId = userId
                    print("✅ ルートレベルのuser_id で取得: \(userId)")
                } else if let userId = jsonObject["userId"] as? String {
                    initialUserId = userId
                    print("✅ ルートレベルのuserId で取得: \(userId)")
                }
            }
            
            // デバッグ: レスポンスの全構造を出力
            if initialUserId == nil {
                print("⚠️ UBOのIDが見つかりませんでした。レスポンス構造を確認してください:")
                print("📋 レスポンスの全キー: \(jsonObject.keys.joined(separator: ", "))")
            }
            
            guard let orgId = organizationId else {
                print("❌ レスポンスに組織IDが見つかりません")
                print("🔍 利用可能なキー: \(jsonObject.keys.joined(separator: ", "))")
                throw RainAPIError.apiError("レスポンスに組織IDが含まれていません")
            }
            
            let orgName = organizationName ?? dummyData["companyName"] as? String ?? "Unknown Organization"
            
            print("✅ Rain API: 法人アカウント作成完了")
            print("🏢 組織ID: \(orgId)")
            print("📛 組織名: \(orgName)")
            if let uboId = initialUserId {
                print("👤 Initial User ID (UBO): \(uboId)")
            }
            
            // UBOのKYCリンク情報を取得
            var uboKYCVerificationLink: String?
            var uboKYCCompletionLink: String?
            var uboKYCStatus: String?
            
            if let uboArray = jsonObject["ultimateBeneficialOwners"] as? [[String: Any]],
               let firstUBO = uboArray.first {
                // applicationExternalVerificationLink（KYC開始用）
                if let verificationLink = firstUBO["applicationExternalVerificationLink"] as? [String: Any],
                   let url = verificationLink["url"] as? String {
                    uboKYCVerificationLink = url
                    print("🔗 UBO KYC検証リンク: \(url)")
                }
                
                // applicationCompletionLink（KYC完了用）
                if let completionLink = firstUBO["applicationCompletionLink"] as? [String: Any],
                   let url = completionLink["url"] as? String {
                    uboKYCCompletionLink = url
                    print("🔗 UBO KYC完了リンク: \(url)")
                }
                
                // UBOのapplicationStatusを確認
                if let status = firstUBO["applicationStatus"] as? String {
                    uboKYCStatus = status
                    print("📊 UBO KYCステータス: \(status)")
                }
            }
            
            return CorporateAccountResult(
                organizationId: orgId,
                organizationName: orgName,
                initialUserId: initialUserId,
                status: jsonObject["status"] as? String ?? "approved",
                uboKYCVerificationLink: uboKYCVerificationLink,
                uboKYCCompletionLink: uboKYCCompletionLink,
                uboKYCStatus: uboKYCStatus
            )
        } catch let error as RainAPIError {
            throw error
        } catch {
            print("❌ 予期しないエラー: \(error.localizedDescription)")
            throw RainAPIError.networkError(error)
        }
    }

    /// 指定組織の全ユーザー一覧を取得（GET all users）
    /// - Parameters:
    ///   - organizationId: 組織ID（companyId）。この値でフィルタする。
    ///   - limit: 取得件数（デフォルト 20）
    /// - Returns: RainUser の配列
    func getAllUsers(organizationId: String, limit: Int = 20) async throws -> [RainUser] {
        let path = "\(RainAPIConfig.getUsersEndpoint)?companyId=\(organizationId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? organizationId)&limit=\(limit)"
        guard let url = URL(string: "\(RainAPIConfig.baseURL)\(path)") else {
            throw RainAPIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RainAPIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "不明なエラー"
            throw RainAPIError.apiError("ステータスコード: \(httpResponse.statusCode), \(message)")
        }

        // レスポンスは配列そのまま、または { "users": [...] } のどちらか
        var users: [RainUser] = []
        if let decoded = try? JSONDecoder().decode([RainUser].self, from: data) {
            users = decoded
        } else if let wrapper = try? JSONDecoder().decode(GetUsersResponse.self, from: data), let decoded = wrapper.users {
            users = decoded
        }
        print("📋 Rain API GET all users: \(users.count)件取得 (companyId=\(organizationId))")
        return users
    }

    /// 組織の初期ユーザーIDを取得（GET all users の先頭1件の id）
    /// 法人アカウント作成直後に呼び、initial user の ID を取得する想定
    /// - Parameter organizationId: 組織ID
    /// - Returns: 先頭ユーザーの id。0件なら nil
    func getInitialUserId(organizationId: String) async throws -> String? {
        let users = try await getAllUsers(organizationId: organizationId, limit: 20)
        return users.first?.id
    }

    /// UBOのKYC手続きを開始
    /// 注意: このメソッドは実際にはKYCリンクを返すだけです
    /// 実際のKYC手続きは、applicationExternalVerificationLinkのURLを開いて行う必要があります
    /// - Parameters:
    ///   - organizationId: 組織ID（Rain APIのapplication ID）
    ///   - uboUserId: UBOのRain User ID
    /// - Returns: KYCステータス情報（実際にはKYCリンクが含まれる）
    func startUBOKYC(
        organizationId: String,
        uboUserId: String
    ) async throws -> [String: Any] {
        print("🌧️ Rain API: UBO KYC開始...")
        print("🏢 Organization ID: \(organizationId)")
        print("👤 UBO User ID: \(uboUserId)")
        print("⚠️ 注意: UBOのKYC手続きは、applicationExternalVerificationLinkのURLを開いて行う必要があります")
        print("💡 このメソッドは、KYCリンクを取得するために組織情報を再取得します")
        
        // 組織情報を再取得してKYCリンクを取得
        // 実際の実装では、createCorporateAccountのレスポンスから既に取得しているはず
        // ここでは簡易的に、KYCリンクが提供されていることを示すだけ
        return [
            "message": "UBOのKYC手続きは、applicationExternalVerificationLinkのURLを開いて行ってください",
            "uboUserId": uboUserId,
            "organizationId": organizationId
        ]
    }
    
    /// UBO書類（写真）をアップロード
    /// - Parameters:
    ///   - companyId: Aブロック申請で取得した組織ID（application ID）
    ///   - uboId: Aブロック申請で取得したUBOのID
    ///   - imageData: アップロードする画像データ（JPEG推奨）
    ///   - docType: 書類種別（デフォルト: idCard）
    ///   - side: 表裏（デフォルト: front）
    ///   - country: 国名（デフォルト: JPN）
    ///   - countryCode: 国コード（デフォルト: JP）
    func uploadUBODocument(
        companyId: String,
        uboId: String,
        imageData: Data,
        docType: String = "idCard",
        side: String = "front",
        country: String = "JPN",
        countryCode: String = "JP"
    ) async throws {
        let path = "/applications/company/\(companyId)/ubo/\(uboId)/document"
        guard let url = URL(string: RainAPIConfig.baseURL + path) else {
            throw RainAPIError.invalidURL
        }
        
        print("🌧️ Rain API: UBO書類アップロード開始...")
        print("🏢 Company ID: \(companyId)")
        print("👤 UBO ID: \(uboId)")
        print("📷 画像サイズ: \(imageData.count) bytes")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // type
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"type\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(docType)\r\n".data(using: .utf8)!)
        
        // side
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"side\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(side)\r\n".data(using: .utf8)!)
        
        // country
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"country\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(country)\r\n".data(using: .utf8)!)
        
        // countryCode
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"countryCode\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(countryCode)\r\n".data(using: .utf8)!)
        
        // document (画像)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"document\"; filename=\"identity_card.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RainAPIError.invalidResponse
        }
        
        print("📡 Rain API UBO書類アップロード レスポンス: ステータスコード \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "不明なエラー"
            print("❌ Rain API UBO書類アップロード エラー: \(errorMessage)")
            throw RainAPIError.apiError("ステータスコード: \(httpResponse.statusCode), \(errorMessage)")
        }
        
        print("✅ Rain API: UBO書類アップロード完了")
    }
    
    /// UBOのKYCステータスを確認
    /// - Parameters:
    ///   - organizationId: 組織ID
    ///   - uboUserId: UBOのRain User ID
    /// - Returns: KYCステータス情報
    func checkUBOKYCStatus(
        organizationId: String,
        uboUserId: String
    ) async throws -> [String: Any] {
        print("🌧️ Rain API: UBO KYCステータス確認...")
        print("🏢 Organization ID: \(organizationId)")
        print("👤 UBO User ID: \(uboUserId)")
        
        // UBOのKYCステータスを確認するエンドポイント（実際のエンドポイントに合わせて調整が必要）
        // 例: /applications/{organizationId}/users/{uboUserId}/kyc/status
        guard let url = URL(string: "\(RainAPIConfig.baseURL)/applications/\(organizationId)/users/\(uboUserId)/kyc/status") else {
            throw RainAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue(uboUserId, forHTTPHeaderField: "X-Rain-User-Id")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RainAPIError.invalidResponse
            }
            
            print("📡 Rain API レスポンス: ステータスコード \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "不明なエラー"
                print("❌ Rain API エラー: \(errorMessage)")
                throw RainAPIError.apiError("ステータスコード: \(httpResponse.statusCode), \(errorMessage)")
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw RainAPIError.apiError("レスポンスの形式が正しくありません")
            }
            
            print("✅ Rain API: UBO KYCステータス確認完了")
            print("📋 レスポンスJSON: \(jsonObject)")
            
            return jsonObject
        } catch let error as RainAPIError {
            throw error
        } catch {
            print("❌ 予期しないエラー: \(error.localizedDescription)")
            throw RainAPIError.networkError(error)
        }
    }
    
    /// その他のRain API呼び出し（rainUserIdを使用）
    /// - Parameters:
    ///   - rainUserId: Firestoreから取得したrainUserId
    ///   - endpoint: APIエンドポイント
    ///   - method: HTTPメソッド（デフォルト: GET）
    ///   - body: リクエストボディ（オプション）
    /// - Returns: レスポンスデータ
    func callRainAPI(
        rainUserId: String,
        endpoint: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> [String: Any] {
        guard let url = URL(string: "\(RainAPIConfig.baseURL)\(endpoint)") else {
            throw RainAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue(rainUserId, forHTTPHeaderField: "X-Rain-User-Id")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw RainAPIError.apiError("リクエストボディの作成に失敗しました")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RainAPIError.invalidResponse
        }
        
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw RainAPIError.invalidResponse
        }
        
        return jsonObject
    }
    
    /// カード番号とCVCを安全に取得（RSA + AES-GCM暗号化）
    /// - Parameter cardId: カードID
    /// - Returns: カード番号とCVCを含む辞書
    func getCardSecrets(cardId: String) async throws -> CardSecrets {
        print("🔐 Rain API: カードシークレット取得開始...")
        print("💳 Card ID: \(cardId)")
        
        // 1. 秘密鍵を生成（32バイト = 256ビット）
        let secretKeyData = SymmetricKey(size: .bits256)
        let secretKeyBytes = secretKeyData.withUnsafeBytes { Data($0) }
        let secretKeyBase64 = secretKeyBytes.base64EncodedString()
        
        print("🔑 秘密鍵生成完了（\(secretKeyBytes.count)バイト）")
        
        // 2. 公開鍵で秘密鍵を暗号化してSessionIdを作成
        let encryptedSessionId = try encryptWithRSA(data: secretKeyBase64.data(using: .utf8)!)
        let sessionId = encryptedSessionId.base64EncodedString()
        
        print("🔐 SessionId作成完了")
        
        // 3. APIリクエスト送信
        guard let url = URL(string: "https://api-dev.raincards.xyz/v1/issuing/cards/\(cardId)/secrets") else {
            throw RainAPIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue(sessionId, forHTTPHeaderField: "SessionId")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("📡 リクエスト送信中...")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RainAPIError.invalidResponse
        }
        
        print("📥 レスポンス受信: ステータスコード \(httpResponse.statusCode)")
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "不明なエラー"
            print("❌ Rain API エラー: \(errorMessage)")
            throw RainAPIError.apiError("ステータスコード: \(httpResponse.statusCode), \(errorMessage)")
        }
        
        // 4. レスポンスをパース
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw RainAPIError.apiError("レスポンスの形式が正しくありません")
        }
        
        guard let encryptedPan = jsonObject["encryptedPan"] as? [String: Any],
              let panIV = encryptedPan["iv"] as? String,
              let panData = encryptedPan["data"] as? String,
              let encryptedCvc = jsonObject["encryptedCvc"] as? [String: Any],
              let cvcIV = encryptedCvc["iv"] as? String,
              let cvcData = encryptedCvc["data"] as? String else {
            throw RainAPIError.apiError("必要なフィールドが不足しています")
        }
        
        print("🔓 復号化開始...")
        
        // 5. AES-GCMで復号
        let cardNumber = try decryptAESGCM(iv: panIV, ciphertext: panData, key: secretKeyBytes)
        let cvc = try decryptAESGCM(iv: cvcIV, ciphertext: cvcData, key: secretKeyBytes)
        
        print("✅ カードシークレット取得完了")
        print("💳 カード番号: \(cardNumber)")
        print("🔢 CVC: \(cvc)")
        
        return CardSecrets(cardNumber: cardNumber, cvc: cvc)
    }
    
    /// RSA公開鍵でデータを暗号化
    private func encryptWithRSA(data: Data) throws -> Data {
        // PEM形式の公開鍵をSecKeyに変換
        let publicKeyString = RainAPIConfig.publicKeyPEM
            .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        guard let publicKeyData = Data(base64Encoded: publicKeyString) else {
            throw RainAPIError.apiError("公開鍵のデコードに失敗しました")
        }
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 2048
        ]
        
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(publicKeyData as CFData, attributes as CFDictionary, &error) else {
            if let error = error?.takeRetainedValue() {
                throw RainAPIError.apiError("公開鍵の作成に失敗しました: \(error)")
            }
            throw RainAPIError.apiError("公開鍵の作成に失敗しました")
        }
        
        // OAEP with SHA-1で暗号化
        guard let encryptedData = SecKeyCreateEncryptedData(
            secKey,
            .rsaEncryptionOAEPSHA1,
            data as CFData,
            &error
        ) as Data? else {
            if let error = error?.takeRetainedValue() {
                throw RainAPIError.apiError("RSA暗号化に失敗しました: \(error)")
            }
            throw RainAPIError.apiError("RSA暗号化に失敗しました")
        }
        
        return encryptedData
    }
    
    /// AES-GCMで復号
    private func decryptAESGCM(iv: String, ciphertext: String, key: Data) throws -> String {
        guard let ivData = Data(base64Encoded: iv),
              let combinedData = Data(base64Encoded: ciphertext) else {
            throw RainAPIError.apiError("Base64デコードに失敗しました")
        }
        
        // AES-GCMのタグは通常16バイト（128ビット）
        // combinedDataの最後の16バイトがタグ、残りが暗号文
        let tagSize = 16
        guard combinedData.count >= tagSize else {
            throw RainAPIError.apiError("暗号文のサイズが不正です")
        }
        
        let ciphertextData = combinedData.prefix(combinedData.count - tagSize)
        let tagData = combinedData.suffix(tagSize)
        
        let symmetricKey = SymmetricKey(data: key)
        let nonce = try AES.GCM.Nonce(data: ivData)
        
        // SealedBoxを作成
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertextData, tag: tagData)
        
        // 復号化
        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
        
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw RainAPIError.apiError("復号化されたデータの変換に失敗しました")
        }
        
        return decryptedString
    }
    
    /// 承認済みユーザーのカードを作成
    /// - Parameters:
    ///   - userId: Rain APIのユーザーID
    ///   - cardRequest: カード作成リクエストパラメータ
    /// - Returns: 作成されたカード情報
    func createCard(
        userId: String,
        cardRequest: CreateCardRequest
    ) async throws -> [String: Any] {
        print("🌧️ Rain API: カード作成開始...")
        print("👤 User ID: \(userId)")
        print("🔗 カード作成URL: \(RainAPIConfig.baseURL)/users/\(userId)/cards")
        
        guard let url = URL(string: "\(RainAPIConfig.baseURL)/users/\(userId)/cards") else {
            throw RainAPIError.invalidURL
        }
        
        print("📡 リクエストURL: \(url.absoluteString)")
        
        // リクエストボディを構築
        var requestBody: [String: Any] = [
            "type": cardRequest.type,
            "status": cardRequest.status
        ]
        
        // limit
        if let limit = cardRequest.limit {
            requestBody["limit"] = [
                "amount": limit.amount,
                "frequency": limit.frequency
            ]
        }
        
        // configuration
        if let config = cardRequest.configuration {
            var configDict: [String: Any] = [:]
            if let displayName = config.displayName {
                configDict["displayName"] = displayName
            }
            if let productId = config.productId {
                configDict["productId"] = productId
            }
            if let productRef = config.productRef {
                configDict["productRef"] = productRef
            }
            if let virtualCardArt = config.virtualCardArt {
                configDict["virtualCardArt"] = virtualCardArt
            }
            if !configDict.isEmpty {
                requestBody["configuration"] = configDict
            }
        }
        
        // shipping
        if let shipping = cardRequest.shipping {
            var shippingDict: [String: Any] = [
                "line1": shipping.line1,
                "city": shipping.city,
                "postalCode": shipping.postalCode,
                "countryCode": shipping.countryCode
            ]
            if let phoneNumber = shipping.phoneNumber {
                shippingDict["phoneNumber"] = phoneNumber
            }
            if let line2 = shipping.line2 {
                shippingDict["line2"] = line2
            }
            if let region = shipping.region {
                shippingDict["region"] = region
            }
            if let method = shipping.method {
                shippingDict["method"] = method
            }
            if let firstName = shipping.firstName {
                shippingDict["firstName"] = firstName
            }
            if let lastName = shipping.lastName {
                shippingDict["lastName"] = lastName
            }
            requestBody["shipping"] = shippingDict
        }
        
        // billing
        if let billing = cardRequest.billing {
            var billingDict: [String: Any] = [
                "line1": billing.line1,
                "city": billing.city,
                "postalCode": billing.postalCode,
                "countryCode": billing.countryCode
            ]
            if let region = billing.region {
                billingDict["region"] = region
            }
            if let line2 = billing.line2 {
                billingDict["line2"] = line2
            }
            if let country = billing.country {
                billingDict["country"] = country
            }
            requestBody["billing"] = billingDict
        }
        
        // bulkShippingGroupId
        if let bulkShippingGroupId = cardRequest.bulkShippingGroupId {
            requestBody["bulkShippingGroupId"] = bulkShippingGroupId
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")
        request.setValue(userId, forHTTPHeaderField: "X-Rain-User-Id")
        print("📋 リクエストヘッダー:")
        print("   - Api-Key: \(RainAPIConfig.apiKey.prefix(10))...")
        print("   - X-Rain-User-Id: \(userId)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw RainAPIError.apiError("リクエストボディの作成に失敗しました: \(error.localizedDescription)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RainAPIError.invalidResponse
            }
            
            print("📡 Rain API レスポンス: ステータスコード \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "不明なエラー"
                print("❌ Rain API エラー: \(errorMessage)")
                throw RainAPIError.apiError("ステータスコード: \(httpResponse.statusCode), \(errorMessage)")
            }
            
            // レスポンスデータをログに出力（デバッグ用）
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Rain API レスポンスデータ: \(responseString)")
            }
            
            // JSONオブジェクトとして解析
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("❌ レスポンスがJSONオブジェクトではありません")
                throw RainAPIError.apiError("レスポンスの形式が正しくありません")
            }
            
            print("✅ Rain API: カード作成完了")
            print("📋 レスポンスJSON: \(jsonObject)")
            
            return jsonObject
        } catch let error as RainAPIError {
            throw error
        } catch {
            print("❌ 予期しないエラー: \(error.localizedDescription)")
            throw RainAPIError.networkError(error)
        }
    }
}
