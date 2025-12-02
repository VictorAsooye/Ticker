import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseAnalytics

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private var _auth: Auth?
    private var _db: Firestore?
    private var _functions: Functions?
    
    var auth: Auth {
        guard let auth = _auth else {
            fatalError("Firebase must be configured before accessing Auth. Call FirebaseManager.shared.configure() first.")
        }
        return auth
    }
    
    var db: Firestore {
        guard let db = _db else {
            fatalError("Firebase must be configured before accessing Firestore. Call FirebaseManager.shared.configure() first.")
        }
        return db
    }
    
    var functions: Functions {
        guard let functions = _functions else {
            fatalError("Firebase must be configured before accessing Functions. Call FirebaseManager.shared.configure() first.")
        }
        return functions
    }
    
    private init() {
        // Properties will be initialized after configure() is called
    }
    
    private var isConfigured = false
    
    func configure() {
        // Only configure once
        guard !isConfigured else { return }
        
        FirebaseApp.configure()
        _auth = Auth.auth()
        _db = Firestore.firestore()
        _functions = Functions.functions()
        isConfigured = true
    }
    
    // Analytics helpers
    func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func setUserProperty(_ value: String, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}

