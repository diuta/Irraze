import Foundation
import SwiftUI

public enum Constants {
    static let size: CGFloat = 25
    static let spacing: CGFloat = 5
    static let rows: Int = 9
    static let cols: Int = 5
    static let maxRowView: Int = 5
    static let cameraBoundary: Int = 3
    
    static var step: CGFloat { spacing + size }
    static var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    static var maxY: CGFloat { CGFloat(maxRowView - 1) / 2 * step }
}
