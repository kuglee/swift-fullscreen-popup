import OnTapOutsideGesture
import SwiftUI

struct PopupItemModifier<Popup: View, Item: Identifiable & Equatable>: ViewModifier {
  @Binding var isUserInstructToPresent: Item?
  @Binding var item: Item?
  @State var isViewAppeared: Bool = false
  @State var contentFrame: CGRect = .zero

  var presentationAnimationTrigger: Bool { isUserInstructToPresent != nil ? isViewAppeared : false }

  let duration: Duration
  let dismissTapBehavior: DismissTapBehavior
  let attachmentAnchor: PopupAttachmentAnchor
  let attachmentEdge: Edge
  let edgeOffset: CGFloat
  let alignment: Alignment?
  let popup: (Item) -> Popup

  init(
    item: Binding<Item?>,
    duration: Duration,
    dismissTapBehavior: DismissTapBehavior,
    attachmentAnchor: PopupAttachmentAnchor,
    attachmentEdge: Edge,
    alignment: Alignment?,
    edgeOffset: CGFloat,
    @ViewBuilder popup: @escaping (_ item: Item) -> Popup
  ) {

    self._isUserInstructToPresent = item
    self._item = item
    self.duration = duration
    self.dismissTapBehavior = dismissTapBehavior
    self.attachmentAnchor = attachmentAnchor
    self.attachmentEdge = attachmentEdge
    self.alignment = alignment
    self.edgeOffset = edgeOffset
    self.popup = popup
  }

  func body(content: Content) -> some View {
    content.onGeometryChange(for: CGRect.self) {
      $0.frame(in: .global)
    } action: {
      contentFrame = $0
    }
    .animatableFullScreenCover(
      item: $isUserInstructToPresent,
      duration: duration,
      dismissTapBehavior: dismissTapBehavior
    ) { item in
      popup(item).onTapOutsideGesture { isUserInstructToPresent = nil }
        .scaleEffect(presentationAnimationTrigger ? 1 : 0)
        .visualEffect { [contentFrame, attachmentAnchor] content, geometry in
          content.offset(
            calcPopupOffset(
              contentFrame: contentFrame,
              popupFrame: geometry.frame(in: .global),
              attachmentAnchor: attachmentAnchor,
              alignment: self.alignment,
              edge: self.attachmentEdge,
              offset: self.edgeOffset
            )
          )
        }
        .animation(
          $isUserInstructToPresent.transaction.animation,
          value: presentationAnimationTrigger
        )
    } onAppear: {
      isViewAppeared = true
    } onDisappear: {
      isViewAppeared = false
    }
  }
}
