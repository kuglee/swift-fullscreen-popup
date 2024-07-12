import SwiftUI

@available(macOS, unavailable) extension View {
  func animatableFullScreenCover(
    isPresented: Binding<Bool>,
    dismissTapBehavior: DismissTapBehavior,
    content: @escaping () -> some View,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) -> some View {
    #if canImport(UIKit)
      modifier(
        AnimatableFullScreenViewModifier(
          isPresented: isPresented,
          dismissTapBehavior: dismissTapBehavior,
          fullScreenContent: content,
          onAppear: onAppear,
          onDisappear: onDisappear
        )
      )
    #else
      self
    #endif
  }

  func animatableFullScreenCover<Item: Identifiable & Equatable>(
    item: Binding<Item?>,
    dismissTapBehavior: DismissTapBehavior,
    content: @escaping (Item) -> some View,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) -> some View {

    #if canImport(UIKit)
      modifier(
        AnimatableFullScreenItemViewModifier(
          item: item,
          dismissTapBehavior: dismissTapBehavior,
          fullScreenContent: content,
          onAppear: onAppear,
          onDisappear: onDisappear
        )
      )
    #else
      self
    #endif
  }
}

#if canImport(UIKit)
  private struct AnimatableFullScreenItemViewModifier<
    FullScreenContent: View,
    Item: Identifiable & Equatable
  >: ViewModifier {
    @Binding var isUserInstructToPresentItem: Item?
    @State var isActualPresented: Item?
    @State var dismissAnimationCompletionTrigger: UUID = .init()

    var animation: Animation? { $isUserInstructToPresentItem.transaction.animation }

    func onAnimationCompletion() { isActualPresented = isUserInstructToPresentItem }

    let dismissTapBehavior: DismissTapBehavior
    let fullScreenContent: (Item) -> (FullScreenContent)
    let onAppear: () -> Void
    let onDisappear: () -> Void

    init(
      item: Binding<Item?>,
      dismissTapBehavior: DismissTapBehavior,
      fullScreenContent: @escaping (Item) -> FullScreenContent,
      onAppear: @escaping () -> Void,
      onDisappear: @escaping () -> Void
    ) {
      self._isUserInstructToPresentItem = item
      self.dismissTapBehavior = dismissTapBehavior
      self.fullScreenContent = fullScreenContent
      self.onAppear = onAppear
      self.onDisappear = onDisappear
      self.isActualPresented = item.wrappedValue
    }

    func body(content: Content) -> some View {
      content.onChange(of: isUserInstructToPresentItem) {
        UIView.setAnimationsEnabled(false)

        if isUserInstructToPresentItem == nil {
          withAnimation(animation) {
            dismissAnimationCompletionTrigger = .init()
          } completion: {
            onAnimationCompletion()
          }
        } else {
          onAnimationCompletion()
        }
      }
      .fullScreenCover(item: $isActualPresented) { item in
        fullScreenContent(item).presentationBackground(.clear)
          .background(DismissTapView(dismissTapBehavior: dismissTapBehavior))
          .onAppear {
            if !UIView.areAnimationsEnabled {
              UIView.setAnimationsEnabled(true)
              withAnimation(animation) { onAppear() }
            }
          }
          .onDisappear {
            if !UIView.areAnimationsEnabled {
              UIView.setAnimationsEnabled(true)
              onDisappear()
            }
          }
      }
      .background { dismissAnimationCompletionTriggerView }
      // this is for when in a presentation isUserInstructToPresent is set to nil from the outside
      .animation(animation, value: isUserInstructToPresentItem != nil)
    }

    var dismissAnimationCompletionTriggerView: some View {
      Color.clear.hidden().id(dismissAnimationCompletionTrigger)
    }
  }

  private struct AnimatableFullScreenViewModifier<FullScreenContent: View>: ViewModifier {
    @Binding var isUserInstructToPresent: Bool
    @State var isActualPresented: Bool
    @State var dismissAnimationCompletionTrigger: UUID = .init()

    var animation: Animation? { $isUserInstructToPresent.transaction.animation }

    func onAnimationCompletion() { isActualPresented = isUserInstructToPresent }

    let dismissTapBehavior: DismissTapBehavior
    let fullScreenContent: () -> (FullScreenContent)
    let onAppear: () -> Void
    let onDisappear: () -> Void

    init(
      isPresented: Binding<Bool>,
      dismissTapBehavior: DismissTapBehavior,
      fullScreenContent: @escaping () -> FullScreenContent,
      onAppear: @escaping () -> Void,
      onDisappear: @escaping () -> Void
    ) {
      self._isUserInstructToPresent = isPresented
      self.dismissTapBehavior = dismissTapBehavior
      self.fullScreenContent = fullScreenContent
      self.onAppear = onAppear
      self.onDisappear = onDisappear
      self.isActualPresented = isPresented.wrappedValue
    }

    func body(content: Content) -> some View {
      content.onChange(of: isUserInstructToPresent) {
        UIView.setAnimationsEnabled(false)

        if !isUserInstructToPresent {
          withAnimation(animation) {
            dismissAnimationCompletionTrigger = .init()
          } completion: {
            onAnimationCompletion()
          }
        } else {
          onAnimationCompletion()
        }
      }
      .fullScreenCover(isPresented: $isActualPresented) {
        fullScreenContent().presentationBackground(.clear)
          .background(DismissTapView(dismissTapBehavior: dismissTapBehavior))
          .onAppear {
            if !UIView.areAnimationsEnabled {
              UIView.setAnimationsEnabled(true)
              withAnimation(animation) { onAppear() }
            }
          }
          .onDisappear {
            if !UIView.areAnimationsEnabled {
              UIView.setAnimationsEnabled(true)
              onDisappear()
            }
          }
      }
      .background { dismissAnimationCompletionTriggerView }
      // this is for when in a presentation isUserInstructToPresent is set to false from the outside
      .animation(animation, value: isUserInstructToPresent)
    }

    var dismissAnimationCompletionTriggerView: some View {
      Color.clear.hidden().id(dismissAnimationCompletionTrigger)
    }
  }

  private struct DismissTapView: UIViewRepresentable {
    let dismissTapBehavior: DismissTapBehavior

    final class View: UIView {
      let dismissTapBehavior: DismissTapBehavior

      init(dismissTapBehavior: DismissTapBehavior) {
        self.dismissTapBehavior = dismissTapBehavior
        super.init(frame: .zero)
      }

      @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
      }

      override func didMoveToWindow() {
        super.didMoveToWindow()

        if dismissTapBehavior == .simultaneous {
          if let contentView = superview, let uiTransitionView = contentView.superview?.superview {
            uiTransitionView.frame = contentView.frame
          }
        }
      }
    }

    func makeUIView(context: Context) -> View { .init(dismissTapBehavior: dismissTapBehavior) }

    func updateUIView(_ uiView: View, context: Context) {}
  }
#endif

public enum DismissTapBehavior {
  case exclusive
  case simultaneous
}
