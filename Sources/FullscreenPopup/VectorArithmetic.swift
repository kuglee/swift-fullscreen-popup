import SwiftUI

extension CGPoint {
  static func + (_ lhs: Self, _ rhs: Self) -> Self { Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y) }

  static func - (_ lhs: Self, _ rhs: Self) -> Self { Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y) }

  static func + (_ lhs: Self, _ rhs: CGSize) -> Self {
    Self(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
  }

  var cgSize: CGSize {
    .init(width: self.x, height: self.y)
  }
}

extension UnitPoint {
  static func * (_ lhs: Self, _ rhs: CGSize) -> CGSize {
    CGSize(width: lhs.x * rhs.width, height: lhs.y * rhs.height)
  }
}

extension CGSize {
  static func + (_ lhs: Self, _ rhs: Self) -> Self {
    Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
  }

  static func * (_ lhs: Self, _ rhs: Self) -> Self {
    Self(width: lhs.width * rhs.width, height: lhs.height * rhs.height)
  }

  static func * (_ lhs: Self, _ rhs: CGFloat) -> Self {
    Self(width: lhs.width * rhs, height: lhs.height * rhs)
  }
}

extension Edge {
  var unitPoint: UnitPoint {
    switch self {
    case .top: .top
    case .bottom: .bottom
    case .leading: .leading
    case .trailing: .trailing
    }
  }
}

extension Edge {
  var popupUnitPoint: PopupUnitPoint {
    switch self {
    case .top: .top
    case .bottom: .bottom
    case .leading: .leading
    case .trailing: .trailing
    }
  }
}

extension Alignment {
  var popupUnitPoint: PopupUnitPoint {
    switch self {
    case .topLeading: .topLeading
    case .top: .top
    case .topTrailing: .topTrailing
    case .bottomLeading: .bottomLeading
    case .bottom: .bottom
    case .bottomTrailing: .bottomTrailing
    case .leading: .leading
    case .trailing: .trailing
    case .center: .center
    default: .center
    }
  }
}
