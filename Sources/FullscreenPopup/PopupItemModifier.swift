import SwiftUI

struct PopupItemModifier<Popup: View, Item: Identifiable & Equatable>: ViewModifier {
  @Binding var isUserInstructToPresent: Item?
  @Binding var item: Item?
  @State var isViewAppeared: Bool = false

  var presentationAnimationTrigger: Bool { isUserInstructToPresent != nil ? isViewAppeared : false }

  let animation: Animation
  let duration: UInt64
  let popup: (Item) -> Popup

  init(
    item: Binding<Item?>,
    duration nanoseconds: UInt64,
    animation: Animation,
    @ViewBuilder popup: @escaping (_ item: Item) -> Popup
  ) {

    self._isUserInstructToPresent = item
    self._item = item
    self.duration = nanoseconds
    self.animation = animation
    self.popup = popup
  }

  func body(content: Content) -> some View {
    content.animatableFullScreenCover(item: $isUserInstructToPresent, duration: duration) { item in
      popup(item).scaleEffect(presentationAnimationTrigger ? 1 : 0)
        .animation(animation, value: presentationAnimationTrigger)
    } onAppear: {
      isViewAppeared = true
    } onDisappear: {
      isViewAppeared = false
    }
  }
}
