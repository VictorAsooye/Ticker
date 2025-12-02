import SwiftUI

struct DeviceHelper {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var cardMaxWidth: CGFloat {
        isIPad ? 600 : .infinity
    }
    
    static var horizontalPadding: CGFloat {
        isIPad ? 48 : 24
    }
    
    static var fontSize: (title: CGFloat, body: CGFloat, caption: CGFloat) {
        if isIPad {
            return (title: 38, body: 18, caption: 14)
        } else {
            return (title: 32, body: 16, caption: 12)
        }
    }
}



