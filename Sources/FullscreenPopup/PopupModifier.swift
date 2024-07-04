import OnTapOutsideGesture
import SwiftUI

struct PopupModifier<Popup: View>: ViewModifier {
  @Binding var isUserInstructToPresent: Bool
  @State var isViewAppeared: Bool = false

  var presentationAnimationTrigger: Bool { isUserInstructToPresent ? isViewAppeared : false }

  let animation: Animation
  let duration: Duration
  let dismissTapBehavior: DismissTapBehavior
  let popup: () -> Popup

  init(
    isPresented: Binding<Bool>,
    duration: Duration,
    animation: Animation,
    dismissTapBehavior: DismissTapBehavior,
    @ViewBuilder popup: @escaping () -> Popup
  ) {
    self._isUserInstructToPresent = isPresented
    self.duration = duration
    self.animation = animation
    self.dismissTapBehavior = dismissTapBehavior
    self.popup = popup
  }

  func body(content: Content) -> some View {
    content.animatableFullScreenCover(
      isPresented: $isUserInstructToPresent,
      duration: duration,
      dismissTapBehavior: dismissTapBehavior
    ) {
      popup().onTapOutsideGesture { isUserInstructToPresent = false }
        .scaleEffect(presentationAnimationTrigger ? 1 : 0)
        .animation(animation, value: presentationAnimationTrigger)
    } onAppear: {
      isViewAppeared = isUserInstructToPresent
    } onDisappear: {
      isViewAppeared = isUserInstructToPresent
    }
  }
}
