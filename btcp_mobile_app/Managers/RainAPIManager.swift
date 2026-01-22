//
//  RainAPIManager.swift
//  btcp_mobile_app
//
//  Rain API操作を管理するクラス
//

import Foundation

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
    /// - Returns: rainUserId
    func createCorporateAccount(
        walletAddress: String,
        email: String,
        dummyData: [String: Any] = [:]
    ) async throws -> String {
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
            "uniqueIdentifier": dummyData["uboUniqueIdentifier"] as? String ?? "ubo-001",
            "firstName": dummyData["uboFirstName"] as? String ?? "Yuta Approved",
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
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let result = try decoder.decode(CreateCorporateAccountResponse.self, from: data)
            
            print("✅ Rain API: 法人アカウント作成完了")
            print("🌧️ Rain User ID: \(result.userId)")
            print("📊 Status: \(result.status)")
            
            return result.userId
        } catch let error as RainAPIError {
            throw error
        } catch let decodingError as DecodingError {
            let errorMessage = "レスポンスのデコードに失敗しました: \(decodingError.localizedDescription)"
            print("❌ \(errorMessage)")
            throw RainAPIError.apiError(errorMessage)
        } catch {
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
}
