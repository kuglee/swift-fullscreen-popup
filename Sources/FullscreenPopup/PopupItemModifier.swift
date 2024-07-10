import OnTapOutsideGesture
import SwiftUI

struct PopupItemModifier<Popup: View, Item: Identifiable & Equatable>: ViewModifier {
  @Binding var isUserInstructToPresent: Item?
  @Binding var item: Item?
  @State var isViewAppeared: Bool = false
  @State var contentFrame: CGRect = .zero

  var presentationAnimationTrigger: Bool { isUserInstructToPresent != nil ? isViewAppeared : false }

  let dismissTapBehavior: DismissTapBehavior
  let attachmentAnchor: PopupAttachmentAnchor
  let attachmentEdge: Edge
  let edgeOffset: CGFloat
  let alignment: Alignment?
  let popup: (Item, Bool) -> Popup

  init(
    item: Binding<Item?>,
    dismissTapBehavior: DismissTapBehavior,
    attachmentAnchor: PopupAttachmentAnchor,
    attachmentEdge: Edge,
    alignment: Alignment?,
    edgeOffset: CGFloat,
    @ViewBuilder popup: @escaping (_ item: Item, _ isPresented: Bool) -> Popup
  ) {
    self._isUserInstructToPresent = item
    self._item = item
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
      dismissTapBehavior: dismissTapBehavior
    ) { item in
      popup(item, presentationAnimationTrigger)
        .onTapOutsideGesture { isUserInstructToPresent = nil }
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
    } onAppear: {
      isViewAppeared = true
    } onDisappear: {
      isViewAppeared = false
    }
  }
}
