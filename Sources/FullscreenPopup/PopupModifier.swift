import OnTapOutsideGesture
import SwiftUI

@available(macOS, unavailable) struct PopupModifier<Popup: View>: ViewModifier {
  @Binding var isUserInstructToPresent: Bool
  @State var isViewAppeared: Bool = false
  @State var contentFrame: CGRect = .zero

  var presentationAnimationTrigger: Bool { isUserInstructToPresent ? isViewAppeared : false }

  let dismissTapBehavior: DismissTapBehavior
  let attachmentAnchor: PopupAttachmentAnchor
  let attachmentEdge: Edge
  let edgeOffset: CGFloat
  let alignment: Alignment?
  let popup: (Bool) -> Popup

  init(
    isPresented: Binding<Bool>,
    dismissTapBehavior: DismissTapBehavior,
    attachmentAnchor: PopupAttachmentAnchor,
    attachmentEdge: Edge,
    alignment: Alignment?,
    edgeOffset: CGFloat,
    @ViewBuilder popup: @escaping (_ isPresented: Bool) -> Popup
  ) {
    self._isUserInstructToPresent = isPresented
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
      isPresented: $isUserInstructToPresent,
      dismissTapBehavior: dismissTapBehavior
    ) {
      popup(presentationAnimationTrigger).onTapOutsideGesture { isUserInstructToPresent = false }
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
      isViewAppeared = isUserInstructToPresent
    } onDisappear: {
      isViewAppeared = isUserInstructToPresent
    }
  }
}
