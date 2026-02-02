# カードシークレット取得機能

## 概要

このモジュールは、Rain Cards APIからカード番号（PAN）とCVCコードを安全に取得するための実装です。
RSA + AES-GCM暗号化による厳格なセキュリティフローを使用しています。

## セキュリティフロー

### 1. セッションキーの生成
クライアント側で256ビット（32バイト）の秘密鍵（セッションキー）を生成します。

```swift
let secretKeyData = SymmetricKey(size: .bits256)
```

### 2. RSA暗号化によるSessionIdの作成
生成した秘密鍵をRain APIの公開鍵で暗号化し、Base64エンコードしてSessionIdとして使用します。

```swift
// 公開鍵で暗号化 (OAEP with SHA-1)
let encryptedSessionId = try encryptWithRSA(data: secretKeyBase64.data(using: .utf8)!)
let sessionId = encryptedSessionId.base64EncodedString()
```

### 3. APIリクエスト
SessionIdをヘッダーに含めてRain APIにリクエストを送信します。

```swift
request.setValue(sessionId, forHTTPHeaderField: "SessionId")
request.setValue(RainAPIConfig.apiKey, forHTTPHeaderField: "Api-Key")
```

### 4. AES-GCM復号化
APIから返された暗号化データ（カード番号とCVC）を、最初に生成した秘密鍵で復号化します。

```swift
let cardNumber = try decryptAESGCM(iv: panIV, ciphertext: panData, key: secretKeyBytes)
let cvc = try decryptAESGCM(iv: cvcIV, ciphertext: cvcData, key: secretKeyBytes)
```

## セットアップ

### 1. 公開鍵の設定

`RainAPIConfig.swift`の`publicKeyPEM`を、Rain APIドキュメントから取得した実際の公開鍵に置き換えてください。

```swift
static let publicKeyPEM = """
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
-----END PUBLIC KEY-----
"""
```

### 2. カードIDの自動取得

カードIDは以下のフローで自動的に取得・保存されます：

1. **カード作成時**: `KYBCardCreationView`でカードを作成
2. **Firestoreに保存**: 作成されたカードIDが自動的にFirestoreに保存
3. **自動取得**: `CardDetailView`と`CardInformationView`がFirestoreからカードIDを取得
4. **カードシークレット取得**: 取得したカードIDでRain APIからカード番号・CVCを取得

```swift
// カード作成時（KYBCardCreationView.swift）
if let cardId = cardInfo?["id"] as? String {
    try await FirestoreManager.shared.saveCardId(
        firebaseUid: firebaseUid,
        cardId: cardId
    )
}

// カード情報表示時（CardDetailView.swift / CardInformationView.swift）
let firestoreUser = try await FirestoreManager.shared.getUser(firebaseUid: firebaseUid)
guard let cardId = firestoreUser.cardId else {
    throw RainAPIError.apiError("カードIDが見つかりません")
}
let secrets = try await RainAPIManager.shared.getCardSecrets(cardId: cardId)
```

## 使用方法

### 完全な自動フロー

1. **ユーザーがKYB申請を完了**
2. **カード作成画面でカードを作成**（`KYBCardCreationView`）
3. **カードIDが自動的にFirestoreに保存**
4. **ホーム画面を開く**（`CardDetailView` / `CardInformationView`）
5. **カードIDがFirestoreから自動取得**
6. **カード番号・CVCが自動的に表示**

### RainAPIManagerでの直接呼び出し

```swift
do {
    let secrets = try await RainAPIManager.shared.getCardSecrets(cardId: "card_id")
    print("カード番号: \(secrets.cardNumber)")
    print("CVC: \(secrets.cvc)")
} catch {
    print("エラー: \(error.localizedDescription)")
}
```

### ビューでの使用

`CardDetailView`と`CardInformationView`は自動的にカードシークレットを取得します。

```swift
struct CardDetailView: View {
    @State private var cardSecrets: CardSecrets?
    @State private var cardId: String?
    
    var body: some View {
        // カード番号の表示
        if let secrets = cardSecrets {
            Text(formatCardNumber(secrets.cardNumber))
        }
    }
    
    .task {
        // ビューが表示されたときに自動取得
        await fetchCardSecrets() // Firestore → Rain API
    }
}
```

### Firestoreのデータ構造

```
users/{firebaseUid}/
  ├─ email: String
  ├─ walletAddress: String
  ├─ rainUserId: String?
  ├─ organizationId: String?
  ├─ cardId: String?          ← カードID（カード作成時に保存）
  ├─ kycStatus: String?
  ├─ createdAt: Timestamp
  └─ updatedAt: Timestamp
```

## エラーハンドリング

```swift
enum RainAPIError: Error, LocalizedError {
    case invalidURL           // 無効なURL
    case invalidResponse      // 無効なレスポンス
    case apiError(String)     // APIエラー（詳細メッセージ付き）
    case networkError(Error)  // ネットワークエラー
    case missingData          // 必要なデータ不足
}
```

## セキュリティ上の注意事項

1. **公開鍵の管理**: 公開鍵は安全に管理し、バージョン管理システムにコミットする際は注意してください。

2. **カードシークレットのメモリ管理**: カード番号とCVCは機密情報です。使用後は適切にクリアすることを推奨します。

3. **通信の暗号化**: すべての通信はHTTPSで行われます（`https://api-dev.raincards.xyz`）。

4. **ローカルストレージの禁止**: カード番号やCVCはローカルストレージに保存しないでください。

5. **ログ出力の制限**: 本番環境ではカード番号やCVCのログ出力を無効にしてください。

## 実装の参考（Pythonスクリプト）

元のPythonスクリプトとの対応関係：

| Python | Swift |
|--------|-------|
| `secrets.token_hex(16)` | `SymmetricKey(size: .bits256)` |
| `rsa.encrypt(..., padding.OAEP)` | `SecKeyCreateEncryptedData(..., .rsaEncryptionOAEPSHA1, ...)` |
| `AESGCM.decrypt(...)` | `AES.GCM.open(sealedBox, using: symmetricKey)` |

## トラブルシューティング

### 1. 復号化エラー

```
エラー: 復号化されたデータの変換に失敗しました
```

**原因**: AES-GCMのタグサイズが正しくない可能性があります。
**解決**: `decryptAESGCM`メソッドの`tagSize`を確認してください（通常は16バイト）。

### 2. 公開鍵エラー

```
エラー: 公開鍵の作成に失敗しました
```

**原因**: PEM形式の公開鍵が正しくありません。
**解決**: Rain APIドキュメントから正しい公開鍵をコピーしてください。

### 3. APIエラー

```
ステータスコード: 403
```

**原因**: APIキーが無効、またはカードIDが存在しません。
**解決**: `RainAPIConfig.apiKey`と`cardId`を確認してください。

## テスト

実装のテストには、Rain APIのサンドボックス環境を使用してください。

```swift
// テストコード例
func testGetCardSecrets() async {
    do {
        let secrets = try await RainAPIManager.shared.getCardSecrets(cardId: "test_card_id")
        XCTAssertFalse(secrets.cardNumber.isEmpty)
        XCTAssertFalse(secrets.cvc.isEmpty)
    } catch {
        XCTFail("エラー: \(error)")
    }
}
```

## ライセンスと著作権

このコードは、Rain Cards APIの公式ドキュメントに基づいて実装されています。
