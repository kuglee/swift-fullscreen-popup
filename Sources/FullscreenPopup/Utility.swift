import SwiftUI

func calcPopupOffset(
  contentFrame: CGRect,
  popupFrame: CGRect,
  attachmentAnchor: PopupAttachmentAnchor,
  alignment: Alignment?,
  edge: Edge,
  offset: CGFloat
) -> CGSize {
  func getPopupUnitPoint(alignment: Alignment?, edge: Edge) -> PopupUnitPoint {
    if let alignment { alignment.popupUnitPoint } else { edge.popupUnitPoint }
  }

  func getEdgeOffset(edge: Edge, offset: CGFloat) -> CGSize {
    edge.popupUnitPoint * CGSize(width: offset, height: offset)
  }

  func calcPopupOffset(popupSize: CGSize, alignment: Alignment?, edge: Edge, offset: CGFloat)
    -> CGSize
  {
    getPopupUnitPoint(alignment: alignment, edge: edge) * popupSize * 0.5
      + getEdgeOffset(edge: edge, offset: offset)
  }

  let relativePosition =
    switch attachmentAnchor {
    case let .rect(.rect(rect)): rect.origin + edge.unitPoint * rect.size
    case .rect(.bounds): CGPoint.zero + edge.unitPoint * contentFrame.size
    case let .point(unitPoint): CGPoint.zero + unitPoint * contentFrame.size
    }
  let offset = calcPopupOffset(
    popupSize: popupFrame.size,
    alignment: alignment,
    edge: edge,
    offset: offset
  )

  return
    (contentFrame.origin + relativePosition + offset - popupFrame.origin + popupFrame.size * -0.5)
    .cgSize
}
