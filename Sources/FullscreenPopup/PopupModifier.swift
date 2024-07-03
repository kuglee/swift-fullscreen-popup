import SwiftUI

struct PopupModifier<Popup: View>: ViewModifier {
  @Binding var isUserInstructToPresent: Bool
  @State var isViewAppeared: Bool = false

  var presentationAnimationTrigger: Bool { isUserInstructToPresent ? isViewAppeared : false }

  let animation: Animation
  let duration: Duration
  let popup: () -> Popup

  init(
    isPresented: Binding<Bool>,
    duration: Duration,
    animation: Animation,
    @ViewBuilder popup: @escaping () -> Popup
  ) {
    self._isUserInstructToPresent = isPresented
    self.duration = duration
    self.animation = animation
    self.popup = popup
  }

  func body(content: Content) -> some View {
    content.animatableFullScreenCover(isPresented: $isUserInstructToPresent, duration: duration) {
      popup().scaleEffect(presentationAnimationTrigger ? 1 : 0)
        .animation(animation, value: presentationAnimationTrigger)
    } onAppear: {
      isViewAppeared = isUserInstructToPresent
    } onDisappear: {
      isViewAppeared = isUserInstructToPresent
    }
  }
}
