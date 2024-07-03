import SwiftUI

extension View {
  /// Presents a popup with customizable content. Available from macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0.
  ///
  /// - Note: The `duration` parameter must be greater than the `duration` of the `animation`.
  ///
  /// - Parameters:
  ///   - isPresented: A binding to a Boolean value that determines whether to present the popup.
  ///   - duration: The duration of the popup animation. Default is 0.35 seconds.
  ///               Ensure this duration is longer than the animation's duration.
  ///   - animation: The animation to use when presenting the popup. Default is a spring animation.
  ///   - popup: A closure returning the popup content.
  /// - Returns: A view with the popup applied.
  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) @_disfavoredOverload
  public func popup<Popup: View>(
    isPresented: Binding<Bool>,
    duration: Duration = .seconds(0.35),
    animation: Animation = .spring(duration: 0.3, bounce: 0.25, blendDuration: 0.1),
    @ViewBuilder content: @escaping () -> Popup
  ) -> some View {
    modifier(
      PopupModifier(
        isPresented: isPresented,
        duration: duration.nanoseconds,
        animation: animation,
        popup: content
      )
    )
  }
}

extension View {
  /// Presents a popup with customizable content based on an identifiable item. Available from macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0.
  ///
  /// - Note: The `duration` parameter must be greater than the `duration` of the `animation`.
  ///
  /// - Parameters:
  ///   - item: A binding to an optional identifiable item that determines whether to present the popup. The popup is presented if the item is non-nil.
  ///   - duration: The duration of the popup animation. Default is 0.35 seconds.
  ///               Ensure this duration is longer than the animation's duration.
  ///   - animation: The animation to use when presenting the popup. Default is a spring animation.
  ///   - content: A closure returning the popup content. The closure takes the current item as a parameter.
  /// - Returns: A view with the popup applied.
  @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, *) @_disfavoredOverload
  public func popup<Popup: View, Item: Identifiable & Equatable>(
    item: Binding<Item?>,
    duration: Duration = .seconds(0.35),
    animation: Animation = .spring(duration: 0.3, bounce: 0.25, blendDuration: 0.1),
    @ViewBuilder content: @escaping (_ item: Item) -> Popup
  ) -> some View {
    modifier(
      PopupItemModifier(
        item: item,
        duration: duration.nanoseconds,
        animation: animation,
        popup: content
      )
    )
  }
}
