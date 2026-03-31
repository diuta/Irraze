import Foundation
import SwiftUI

public enum Constants {
    static let size: CGFloat = 25
    static let spacing: CGFloat = 5
    static let rows: Int = 81
    static let cols: Int = 9
    static let maxRowView: Int = 10
    static let cameraBoundary: Int = 5
    
    static var step: CGFloat { spacing + size }
    static var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    static var maxY: CGFloat { CGFloat(maxRowView - 1) / 2 * step }
    
    static let bodyColor = Color(red: 121/255, green: 186/255, blue: 170/255)
    static let secondaryBodyColor = Color(red: 101/255, green: 166/255, blue: 150/255)
    static let screenColor = Color(red: 198/255, green: 227/255, blue: 189.255)
    static let catridgeColor = Color(red: 84/255, green: 109/255, blue: 102/255)
    static let moveButtonColor = Color(red: 252/255, green: 232/255, blue: 80/255)
    static let freezeColor = Color(red: 122/255, green: 191/255, blue: 186/255)
}
