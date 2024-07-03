import SwiftUI

extension View {
  func animatableFullScreenCover(
    isPresented: Binding<Bool>,
    duration: Duration,
    content: @escaping () -> some View,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) -> some View {
    modifier(
      AnimatableFullScreenViewModifier(
        isPresented: isPresented,
        duration: duration,
        fullScreenContent: content,
        onAppear: onAppear,
        onDisappear: onDisappear
      )
    )
  }

  func animatableFullScreenCover<Item: Identifiable & Equatable>(
    item: Binding<Item?>,
    duration: Duration,
    content: @escaping (Item) -> some View,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) -> some View {
    modifier(
      AnimatableFullScreenItemViewModifier(
        item: item,
        duration: duration,
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

  let duration: Duration
  let fullScreenContent: (Item) -> (FullScreenContent)
  let onAppear: () -> Void
  let onDisappear: () -> Void

  init(
    item: Binding<Item?>,
    duration: Duration,
    fullScreenContent: @escaping (Item) -> FullScreenContent,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) {
    self._isUserInstructToPresentItem = item
    self.duration = duration
    self.fullScreenContent = fullScreenContent
    self.onAppear = onAppear
    self.onDisappear = onDisappear
    self.isActualPresented = item.wrappedValue
  }

  func body(content: Content) -> some View {
    content.onChange(of: isUserInstructToPresentItem) { isUserInstructToPresent in
      UIView.setAnimationsEnabled(false)
      if isUserInstructToPresent != nil {
        isActualPresented = isUserInstructToPresent
      } else {
        Task {
          try await Task.sleep(for: duration)
          isActualPresented = isUserInstructToPresent
        }
      }
    }
    .fullScreenCover(item: $isActualPresented) { item in
      fullScreenContent(item).background(BackgroundTransparentView())
        .onAppear {
          if !UIView.areAnimationsEnabled {
            UIView.setAnimationsEnabled(true)
            onAppear()
          }
        }
        .onDisappear {
          if !UIView.areAnimationsEnabled {
            UIView.setAnimationsEnabled(true)
            onDisappear()
          }
        }
    }
  }
}

private struct AnimatableFullScreenViewModifier<FullScreenContent: View>: ViewModifier {
  @Binding var isUserInstructToPresent: Bool
  @State var isActualPresented: Bool

  let duration: Duration
  let fullScreenContent: () -> (FullScreenContent)
  let onAppear: () -> Void
  let onDisappear: () -> Void

  init(
    isPresented: Binding<Bool>,
    duration: Duration,
    fullScreenContent: @escaping () -> FullScreenContent,
    onAppear: @escaping () -> Void,
    onDisappear: @escaping () -> Void
  ) {
    self._isUserInstructToPresent = isPresented
    self.duration = duration
    self.fullScreenContent = fullScreenContent
    self.onAppear = onAppear
    self.onDisappear = onDisappear
    self.isActualPresented = isPresented.wrappedValue
  }

  func body(content: Content) -> some View {
    content.onChange(of: isUserInstructToPresent) { isUserInstructToPresent in
      UIView.setAnimationsEnabled(false)
      if isUserInstructToPresent {
        isActualPresented = isUserInstructToPresent
      } else {
        Task {
          try await Task.sleep(for: duration)
          isActualPresented = isUserInstructToPresent
        }
      }
    }
    .fullScreenCover(isPresented: $isActualPresented) {
      fullScreenContent().background(BackgroundTransparentView())
        .onAppear {
          if !UIView.areAnimationsEnabled {
            UIView.setAnimationsEnabled(true)
            onAppear()
          }
        }
        .onDisappear {
          if !UIView.areAnimationsEnabled {
            UIView.setAnimationsEnabled(true)
            onDisappear()
          }
        }
    }
  }
}

private struct BackgroundTransparentView: UIViewRepresentable {
  func makeUIView(context _: Context) -> UIView { TransparentView() }

  func updateUIView(_: UIView, context _: Context) {}

  private class TransparentView: UIView {
    override func layoutSubviews() {
      super.layoutSubviews()
      superview?.superview?.backgroundColor = .clear
    }
  }
}
