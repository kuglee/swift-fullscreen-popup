import FullscreenPopup
import SwiftUI

struct ContentView: View {
  @State var isExample1Presented = false
  @State var example2Item: MyItem?

  var body: some View {
    Color.clear.sheet(isPresented: .constant(true)) {
      Button {
        isExample1Presented = true
      } label: {
        Text("Show Alert 1")
      }
      .popup(isPresented: $isExample1Presented.animation(.default)) { isPresented in
        Example1Alert(isPresented: $isExample1Presented).scaleEffect(isPresented ? 1 : 0)
      }
      Button {
        example2Item = .init(id: UUID())
      } label: {
        Text("Show Alert 2")
      }
      .popup(item: $example2Item.animation(.default)) { item, isPresented in
        VStack {
          Text(item.id.uuidString)
          Button {
            example2Item = nil
          } label: {
            Text("Close")
          }
        }
        .padding().background(.gray).clipShape(RoundedRectangle(cornerRadius: 10))
        .scaleEffect(isPresented ? 1 : 0)
      }
    }
  }
}

struct MyItem: Identifiable, Equatable { let id: UUID }

#Preview { ContentView() }
