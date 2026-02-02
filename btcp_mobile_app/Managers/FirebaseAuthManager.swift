import FirebaseAuth
import Foundation

final class FirebaseAuthManager {
    static let shared = FirebaseAuthManager()
    private init() {}

    func sendSignInLink(email: String) {
        let settings = ActionCodeSettings()
        settings.url = URL(string: "https://btcp-swift.firebaseapp.com")
        settings.handleCodeInApp = true
        settings.setIOSBundleID(Bundle.main.bundleIdentifier!)

        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: settings) {
            error in if let error = error {
                print("sendSignInLink error:", error)
                return
            }
            UserDefaults.standard.set(email, forKey: "emailForSignIn")
            print("Magic link sent")
        }
    }
}
