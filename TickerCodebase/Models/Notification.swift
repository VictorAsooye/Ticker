import Foundation

struct AppNotification: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
    let time: String
    var isNew: Bool
    
    init(id: UUID = UUID(), title: String, message: String, time: String, isNew: Bool = true) {
        self.id = id
        self.title = title
        self.message = message
        self.time = time
        self.isNew = isNew
    }
}
