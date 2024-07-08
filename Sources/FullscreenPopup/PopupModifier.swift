import OnTapOutsideGesture
import SwiftUI

struct PopupModifier<Popup: View>: ViewModifier {
  @Binding var isUserInstructToPresent: Bool
  @State var isViewAppeared: Bool = false
  @State var contentFrame: CGRect = .zero
  @State var popupSize: CGSize = .zero

  var presentationAnimationTrigger: Bool { isUserInstructToPresent ? isViewAppeared : false }

  let animation: Animation
  let duration: Duration
  let dismissTapBehavior: DismissTapBehavior
  let attachmentAnchor: PopupAttachmentAnchor
  let attachmentEdge: Edge
  let edgeOffset: CGFloat
  let alignment: Alignment?
  let popup: () -> Popup

  init(
    isPresented: Binding<Bool>,
    duration: Duration,
    animation: Animation,
    dismissTapBehavior: DismissTapBehavior,
    attachmentAnchor: PopupAttachmentAnchor,
    attachmentEdge: Edge,
    alignment: Alignment?,
    edgeOffset: CGFloat,
    @ViewBuilder popup: @escaping () -> Popup
  ) {
    self._isUserInstructToPresent = isPresented
    self.duration = duration
    self.animation = animation
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
      duration: duration,
      dismissTapBehavior: dismissTapBehavior
    ) {
      popup()
        .onGeometryChange(for: CGSize.self) {
          $0.size
        } action: {
          popupSize = $0
        }
        .onTapOutsideGesture { isUserInstructToPresent = false }
        .scaleEffect(presentationAnimationTrigger ? 1 : 0)
        .position(
          calcPopupPosition(
            contentFrame: self.contentFrame,
            popupSize: self.popupSize,
            attachmentAnchor: self.attachmentAnchor,
            alignment: self.alignment,
            edge: self.attachmentEdge,
            offset: self.edgeOffset
          )
        )
        .ignoresSafeArea().animation(animation, value: presentationAnimationTrigger)
    } onAppear: {
      isViewAppeared = isUserInstructToPresent
    } onDisappear: {
      isViewAppeared = isUserInstructToPresent
    }
  }
}
