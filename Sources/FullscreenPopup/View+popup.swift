import SwiftUI

extension View {
  /// - Note: The `duration` parameter must be greater than the `duration` of the `animation`.
  ///
  /// - Parameters:
  ///   - isPresented: A binding to a Boolean value that determines whether to present the popup.
  ///   - duration: The duration of the popup animation. Default is 0.35 seconds.
  ///               Ensure this duration is longer than the animation's duration.
  ///   - attachmentAnchor: The positioning anchor that defines the
  ///     attachment point of the popup. The default is
  ///     ``PopupAttachmentAnchor/Source/bounds``.
  ///   - attachmentEdge: The edge of the `attachmentAnchor` that defines
  ///     the location of the popover. The default is ``Edge/top``.
  ///   - alignment: The alignment that the modifier uses to position the
  ///     implicit popup relative to the `attachmentAnchor`. When
  ///    `alignment` is nil, the value gets derived from the `attachmentEdge`.
  ///   - edgeOffset: The distance of the poppver from the `attachmentEdge`.
  ///   - popup: A closure returning the popup content.
  ///   - dismissTapBehavior: A Boolean value that indicates whether the dismiss gesture should
  ///   be processed simultaneously with gestures defined by the view.
  /// - Returns: A view with the popup applied.
  public func popup<Popup: View>(
    isPresented: Binding<Bool>,
    duration: Duration = .seconds(0.35),
    attachmentAnchor: PopupAttachmentAnchor = .rect(.bounds),
    attachmentEdge: Edge = .top,
    edgeOffset: CGFloat = 0,
    alignment: Alignment? = nil,
    dismissTapBehavior: DismissTapBehavior = .exclusive,
    @ViewBuilder content: @escaping () -> Popup
  ) -> some View {
    modifier(
      PopupModifier(
        isPresented: isPresented,
        duration: duration,
        dismissTapBehavior: dismissTapBehavior,
        attachmentAnchor: attachmentAnchor,
        attachmentEdge: attachmentEdge,
        alignment: alignment,
        edgeOffset: edgeOffset,
        popup: content
      )
    )
  }
}

extension View {
  /// - Note: The `duration` parameter must be greater than the `duration` of the `animation`.
  ///
  /// - Parameters:
  ///   - item: A binding to an optional identifiable item that determines whether to present the popup. The popup is presented if the item is non-nil.
  ///   - duration: The duration of the popup animation. Default is 0.35 seconds.
  ///               Ensure this duration is longer than the animation's duration.
  ///   - attachmentAnchor: The positioning anchor that defines the
  ///     attachment point of the popup. The default is
  ///     ``PopupAttachmentAnchor/Source/bounds``.
  ///   - attachmentEdge: The edge of the `attachmentAnchor` that defines
  ///     the location of the popover. The default is ``Edge/top``.
  ///   - alignment: The alignment that the modifier uses to position the
  ///     implicit popup relative to the `attachmentAnchor`. When
  ///    `alignment` is nil, the value gets derived from the `attachmentEdge`.
  ///   - edgeOffset: The distance of the poppver from the `attachmentEdge`.
  ///   - dismissTapBehavior: A Boolean value that indicates whether the dismiss gesture should
  ///   be processed simultaneously with gestures defined by the view.
  ///   - content: A closure returning the popup content. The closure takes the current item as a parameter.
  /// - Returns: A view with the popup applied.
  public func popup<Popup: View, Item: Identifiable & Equatable>(
    item: Binding<Item?>,
    duration: Duration = .seconds(0.35),
    attachmentAnchor: PopupAttachmentAnchor = .rect(.bounds),
    attachmentEdge: Edge = .top,
    edgeOffset: CGFloat = 0,
    alignment: Alignment? = nil,
    dismissTapBehavior: DismissTapBehavior = .exclusive,
    @ViewBuilder content: @escaping (_ item: Item) -> Popup
  ) -> some View {
    modifier(
      PopupItemModifier(
        item: item,
        duration: duration,
        dismissTapBehavior: dismissTapBehavior,
        attachmentAnchor: attachmentAnchor,
        attachmentEdge: attachmentEdge,
        alignment: alignment,
        edgeOffset: edgeOffset,
        popup: content
      )
    )
  }
}
