# 環境変数設定ガイド

このプロジェクトでは機密情報を環境変数として管理しています。

## セットアップ手順

### 1. Secrets.xcconfig の作成

`Secrets.xcconfig.template` をコピーして `Secrets.xcconfig` を作成：

```bash
cd btcp_mobile_app/Config
cp Secrets.xcconfig.template Secrets.xcconfig
```

### 2. 認証情報の設定

`Secrets.xcconfig` を開き、各値を実際の認証情報に置き換えてください。

### 3. Xcodeプロジェクトへの設定

1. Xcodeでプロジェクトを開く
2. プロジェクトナビゲーターで **btcp_mobile_app** プロジェクト（青いアイコン）を選択
3. **Info** タブを選択
4. **Configurations** セクションを展開
5. **Debug** の横にある「btcp_mobile_app」をクリック
6. ドロップダウンから **Secrets** を選択（表示されない場合は下記参照）
7. **Release** にも同様に設定

#### Secrets.xcconfig が表示されない場合

1. Xcodeのプロジェクトナビゲーターで **Config** フォルダを右クリック
2. **Add Files to "btcp_mobile_app"...** を選択
3. `Secrets.xcconfig` を選択して追加
4. 上記手順3-7を再度実行

### 4. 本番リリース前の対応

`Environment.swift` 内の `Fallback` enum を削除してください。
これにより、環境変数が未設定の場合はアプリがクラッシュし、
機密情報のハードコードが防止されます。

## ファイル構成

```
Config/
├── Environment.swift          # 環境変数アクセス用ユーティリティ
├── Secrets.xcconfig           # 実際の認証情報（.gitignore対象）
├── Secrets.xcconfig.template  # テンプレート（git管理対象）
├── RainAPIConfig.swift        # Rain API設定
├── SupabaseConfig.swift       # Supabase設定
└── SECRETS_SETUP.md           # このファイル
```

## 環境変数一覧

| 変数名 | 説明 |
|--------|------|
| RAIN_API_KEY | Rain API認証キー |
| RAIN_API_BASE_URL | Rain APIベースURL |
| SUPABASE_URL | SupabaseプロジェクトURL |
| SUPABASE_ANON_KEY | Supabase匿名キー |
| WEB3AUTH_CLIENT_ID | Web3Authクライアントid |
| WEB3AUTH_VERIFIER_NAME | Web3Auth Verifier名 |
| WEB3AUTH_REDIRECT_URL | Web3Authリダイレクトurl |
| TEST_EMAIL | テスト用メール（オプション） |
| TEST_PASSWORD | テスト用パスワード（オプション） |

## セキュリティ注意事項

- `Secrets.xcconfig` は絶対にgitにコミットしない
- チームメンバーには安全な方法（1Password、AWS Secrets Manager等）で共有
- CI/CDでは環境変数としてビルドシステムに注入
