import SwiftUI

extension View {
  func animatableFullScreenCover(
    isPresented: Binding<Bool>,
    dismissTapBehavior: DismissTapBehavior,
    content: @escaping () -> some View,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) -> some View {
    modifier(
      AnimatableFullScreenViewModifier(
        isPresented: isPresented,
        dismissTapBehavior: dismissTapBehavior,
        fullScreenContent: content,
        onAppear: onAppear,
        onDisappear: onDisappear
      )
    )
  }

  func animatableFullScreenCover<Item: Identifiable & Equatable>(
    item: Binding<Item?>,
    dismissTapBehavior: DismissTapBehavior,
    content: @escaping (Item) -> some View,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) -> some View {
    modifier(
      AnimatableFullScreenItemViewModifier(
        item: item,
        dismissTapBehavior: dismissTapBehavior,
        fullScreenContent: content,
        onAppear: onAppear,
        onDisappear: onDisappear
      )
    )
  }
}

private struct AnimatableFullScreenItemViewModifier<
  FullScreenContent: View,
  Item: Identifiable & Equatable
>: ViewModifier {
  @Binding var isUserInstructToPresentItem: Item?
  @State var isActualPresented: Item?
  @State var dismissAnimationCompletionTrigger: UUID = .init()

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
      if isUserInstructToPresentItem != nil {
        isActualPresented = isUserInstructToPresentItem
      } else {
        withAnimation(animation) {
          dismissAnimationCompletionTrigger = .init()
        } completion: {
          isActualPresented = isUserInstructToPresentItem
        }
      }
    }
    .fullScreenCover(item: $isActualPresented) { item in
      fullScreenContent(item)
        .background(BackgroundTransparentView(dismissTapBehavior: dismissTapBehavior))
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
  }

  var animation: Animation? { $isUserInstructToPresentItem.transaction.animation }

  var dismissAnimationCompletionTriggerView: some View {
    EmptyView().id(dismissAnimationCompletionTrigger)
  }
}

private struct AnimatableFullScreenViewModifier<FullScreenContent: View>: ViewModifier {
  @Binding var isUserInstructToPresent: Bool
  @State var isActualPresented: Bool
  @State var dismissAnimationCompletionTrigger: UUID = .init()

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
      if isUserInstructToPresent {
        isActualPresented = isUserInstructToPresent
      } else {
        withAnimation(animation) {
          dismissAnimationCompletionTrigger = .init()
        } completion: {
          isActualPresented = isUserInstructToPresent
        }
      }
    }
    .fullScreenCover(isPresented: $isActualPresented) {
      fullScreenContent()
        .background(BackgroundTransparentView(dismissTapBehavior: dismissTapBehavior))
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
  }

  var animation: Animation? { $isUserInstructToPresent.transaction.animation }

  var dismissAnimationCompletionTriggerView: some View {
    EmptyView().id(dismissAnimationCompletionTrigger)
  }
}

private struct BackgroundTransparentView: UIViewRepresentable {
  let dismissTapBehavior: DismissTapBehavior

  func makeUIView(context _: Context) -> UIView {
    TransparentView(dismissTapBehavior: dismissTapBehavior)
  }

  func updateUIView(_: UIView, context _: Context) {}

  private class TransparentView: UIView {
    let dismissTapBehavior: DismissTapBehavior

    init(dismissTapBehavior: DismissTapBehavior) {
      self.dismissTapBehavior = dismissTapBehavior
      super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      superview?.superview?.backgroundColor = .clear

      if dismissTapBehavior == .simultaneous {
        if let contentView = superview, let uiTransitionView = contentView.superview?.superview {
          uiTransitionView.frame = contentView.frame
        }
      }
    }
  }
}

public enum DismissTapBehavior {
  case exclusive
  case simultaneous
}
