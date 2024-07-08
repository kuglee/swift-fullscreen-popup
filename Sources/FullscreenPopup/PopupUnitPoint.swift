import Foundation

/// A 2D point in a view's coordinate space where the components are in the range `[-1 , 1]`.
///
/// > Note: A popup unit point with one or more components outside the range `[-1, 1]`
/// projects to a point outside of the view.
struct PopupUnitPoint {
  let x: CGFloat
  let y: CGFloat
}

extension PopupUnitPoint {
  static func * (_ lhs: Self, _ rhs: CGSize) -> CGSize {
    CGSize(width: lhs.x * rhs.width, height: lhs.y * rhs.height)
  }
}

extension PopupUnitPoint {
  static let topLeading = Self(x: -1, y: -1)
  static let top = Self(x: 0, y: -1)
  static let topTrailing = Self(x: 1, y: -1)
  static let bottomLeading = Self(x: -1, y: 1)
  static let bottom = Self(x: 0, y: 1)
  static let bottomTrailing = Self(x: 1, y: 1)
  static let leading = Self(x: -1, y: 0)
  static let trailing = Self(x: 1, y: 0)
  static let center = Self(x: 0, y: 0)
}
