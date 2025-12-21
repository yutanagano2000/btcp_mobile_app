/// Supabaseとの接続定義
// 認証情報を格納する
struct SupabaseConfig {
    static let supabaseURL = "https://hcomrbvcvcymdyxcfiyr.supabase.co"

    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhjb21yYnZjdmN5bWR5eGNmaXlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NTE2MDIsImV4cCI6MjA4MDIyNzYwMn0.PYd8dD3WJVFA6E6GlsUrjWds4OyZ1OVnrOsbepIRKoQ"
    
    // Supabaseとの連携が重かったのでテスト用アドレスとパスワードを定義
    static let testEmail = "test@example.com"
    static let testPassword = "test1234"
}

