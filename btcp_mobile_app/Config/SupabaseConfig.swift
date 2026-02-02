/// Supabaseとの接続定義
/// 認証情報は環境変数から取得
struct SupabaseConfig {
    /// Supabase URL（環境変数から取得）
    static var supabaseURL: String {
        AppEnvironment.supabaseURL
    }

    /// Supabase Anonymous Key（環境変数から取得）
    static var supabaseAnonKey: String {
        AppEnvironment.supabaseAnonKey
    }

    /// テスト用メールアドレス（環境変数から取得、オプショナル）
    static var testEmail: String? {
        AppEnvironment.testEmail
    }

    /// テスト用パスワード（環境変数から取得、オプショナル）
    static var testPassword: String? {
        AppEnvironment.testPassword
    }
}
