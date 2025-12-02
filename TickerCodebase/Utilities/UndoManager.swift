import Foundation
import SwiftUI

class UndoManager: ObservableObject {
    @Published var showUndoBanner = false
    @Published var lastSwipedCard: Investment?
    @Published var lastSwipeDirection: SwipeDirection?
    
    private var undoTimer: Timer?
    
    func registerSwipe(card: Investment, direction: SwipeDirection) {
        lastSwipedCard = card
        lastSwipeDirection = direction
        showUndoBanner = true
        
        // Cancel existing timer
        undoTimer?.invalidate()
        
        // Auto-hide after 3 seconds
        undoTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] timer in
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.showUndoBanner = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self?.lastSwipedCard = nil
                    self?.lastSwipeDirection = nil
                }
            }
        }
        
        FirebaseManager.shared.logEvent("swipe_registered_for_undo")
    }
    
    func performUndo() -> (card: Investment, direction: SwipeDirection)? {
        guard let card = lastSwipedCard, let direction = lastSwipeDirection else {
            return nil
        }
        
        undoTimer?.invalidate()
        showUndoBanner = false
        
        let result = (card, direction)
        
        lastSwipedCard = nil
        lastSwipeDirection = nil
        
        FirebaseManager.shared.logEvent("swipe_undone", parameters: [
            "direction": direction.rawValue
        ])
        
        return result
    }
    
    func cancelUndo() {
        undoTimer?.invalidate()
        showUndoBanner = false
        lastSwipedCard = nil
        lastSwipeDirection = nil
    }
}



