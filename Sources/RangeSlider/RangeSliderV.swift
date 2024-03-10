// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

internal enum DraggingHandle { case lower, upper }

@available(iOS 13.0, macOS 10.15, *)
public struct HorizontalRangeSliderV<V: BinaryFloatingPoint>: View {
    @Binding var value: ClosedRange<V>
    let range: ClosedRange<V>
    
    public init(value: Binding<ClosedRange<V>>, range: ClosedRange<V>) {
        self._value = value
        self.range = range
    }
    
    func updateValue(width: CGFloat, diff: CGFloat, handle: DraggingHandle) {
        let newPosition = diff / width * CGFloat(range.upperBound)
        var proposedLower = value.lowerBound
        var proposedUpper = value.upperBound
        
        switch handle {
        case .lower: proposedLower = max(range.lowerBound, min(value.lowerBound + V(newPosition), value.upperBound))
        case .upper: proposedUpper = min(range.upperBound, max(value.upperBound + V(newPosition), value.lowerBound))
        }
        
        value = proposedLower...proposedUpper
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: GrabberV.grabberSize, height: 0)
            ZStack {
                GeometryReader { geo in
                    ZStack(alignment: .center) {
                        HorizontalSliderTrackV(value: value, range: range)
                        Group {
                            let offsetFix = geo.size.width / 2 - GrabberV.grabberSize / 2
                            GrabberV(draggingHandle: .lower, updateValue: updateValue, width: geo.size.width)
                                .offset(x: CGFloat(value.lowerBound / range.upperBound) * geo.size.width - offsetFix)
                            GrabberV(draggingHandle: .upper, updateValue: updateValue, width: geo.size.width)
                                .offset(x: CGFloat(value.upperBound / range.upperBound) * geo.size.width - geo.size.width / 2 + GrabberV.grabberSize / 2)
                        }
                        .frame(width: GrabberV.grabberSize, height: GrabberV.grabberSize)
                        .foregroundColor(.white)
                    }
                }
            }
            .frame(height: GrabberV.grabberSize)
            Color.clear.frame(width: GrabberV.grabberSize, height: 0)
        }
    }
}

@available(iOS 13.0, macOS 10.15, *)
fileprivate struct HorizontalSliderTrackV<V: BinaryFloatingPoint>: View {
    let value: ClosedRange<V>
    let range: ClosedRange<V>
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Capsule()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(width: CGFloat(value.lowerBound / range.upperBound) * geo.size.width)
                
                Rectangle()
                    .foregroundColor(.accentColor)
                    .frame(width: CGFloat(value.upperBound - value.lowerBound) / CGFloat(range.upperBound) * geo.size.width)
                
                Capsule().foregroundColor(.gray.opacity(0.3))
            }
        }
        .frame(height: 4)
    }
}

@available(iOS 13.0, macOS 10.15, *)
fileprivate struct GrabberV: View {
    var draggingHandle: DraggingHandle
    var updateValue: (CGFloat, CGFloat, DraggingHandle) -> Void
    @GestureState var dragAmount: CGSize = .zero
    static let grabberSize: CGFloat = 27
    @State var previousDragAmount: CGFloat = .zero
    let width: CGFloat
    
    var body: some View {
        Circle()
            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged { update in
                        let diff = update.translation.width - previousDragAmount
                        updateValue(width, diff, draggingHandle)
                        previousDragAmount = update.translation.width
                    }
                    .onEnded { _ in
                        previousDragAmount = .zero
                    }
            )
    }
}

@available(iOS 13.0, macOS 10.15, *)
struct ContentView_Previews : PreviewProvider {
    struct TestView: View {
        @State var baseValue: ClosedRange<Double> = 2...10
        var range: ClosedRange<Double> = 0...10
        var body: some View {
            HorizontalRangeSliderV(value: $baseValue, range: range)
        }
    }
    
    static var previews: some View {
        TestView()
    }
}
