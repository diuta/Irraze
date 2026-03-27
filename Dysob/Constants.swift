import Foundation
import SwiftUI

public enum Constants {
    static let size: CGFloat = 25
    static let spacing: CGFloat = 5
    static let rows: Int = 81
    static let cols: Int = 11
    static let maxRowView: Int = 10
    static let cameraBoundary: Int = 5
    
    static var step: CGFloat { spacing + size }
    static var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    static var maxY: CGFloat { CGFloat(maxRowView - 1) / 2 * step }
    
    static let bodyColor = Color(red: 168/255, green: 211/255, blue: 174/255, opacity: 1.0)
    static let secondaryBodyColor = Color(red: 158/255, green: 201/255, blue: 164/255, opacity: 1.0)
}
