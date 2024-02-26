// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
enum Layout {
    case vertical, horizontal
}

@available(iOS 13.0, *)
private struct HorizontalRangeSlider<V: BinaryFloatingPoint>: View {
    @Binding public var value: ClosedRange<V>
    public var range: ClosedRange<V>
    @State private var previousDragLoc: CGFloat = .zero
    @State private var draggingHandle: DraggingHandle = .lower
    let grabberSize: CGFloat = 27
    
    private enum DraggingHandle { case lower, upper }
    
    func updateValue(for translation: CGFloat, width: CGFloat) {
        let diff = translation - previousDragLoc
        let newPosition = diff / width * CGFloat(range.upperBound)
        
        var proposedLower = value.lowerBound
        var proposedUpper = value.upperBound
        
        switch draggingHandle {
        case .lower: proposedLower = max(range.lowerBound, min(value.lowerBound + V(newPosition), value.upperBound))
        case .upper: proposedUpper = min(range.upperBound, max(value.upperBound + V(newPosition), value.lowerBound))
        }
        
        value = proposedLower...proposedUpper
        previousDragLoc = translation
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Color.clear.frame(width: self.grabberSize, height: 0)
            GeometryReader { geo in
                ZStack {
                    HStack(spacing: 0) {
                        Capsule()
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(width: CGFloat(value.lowerBound / range.upperBound) * geo.size.width)
                        
                        Rectangle()
                            .foregroundColor(.accentColor)
                            .frame(width: CGFloat(value.upperBound - value.lowerBound) / CGFloat(range.upperBound) * geo.size.width)
                        
                        Capsule().foregroundColor(.gray.opacity(0.3))
                    }
                    .frame(height: 4)
                    ZStack {
                        Circle()
                            .gesture(
                                DragGesture(coordinateSpace: .global)
                                    .onChanged { update in
                                        draggingHandle = .lower
                                        updateValue(for: update.translation.width, width: geo.size.width)
                                    }
                                    .onEnded { _ in
                                        previousDragLoc = .zero
                                    }
                            )
                            .offset(x: CGFloat(value.lowerBound / range.upperBound) * geo.size.width - geo.size.width / 2 - self.grabberSize / 2)
                            .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                        
                        Circle()
                            .gesture(
                                DragGesture(coordinateSpace: .global)
                                    .onChanged { update in
                                        draggingHandle = .upper
                                        updateValue(for: update.translation.width, width: geo.size.width)
                                    }
                                    .onEnded { _ in
                                        previousDragLoc = .zero
                                    }
                            )
                            .offset(x: CGFloat(value.upperBound / range.upperBound) * geo.size.width - geo.size.width / 2 + self.grabberSize / 2)
                            .shadow(color: .black.opacity(0.2), radius: 2, y: 2)
                    }
                    .frame(width: self.grabberSize, height: self.grabberSize)
                    .foregroundColor(.white)
                }
            }
            .frame(height: self.grabberSize)
            Color.clear.frame(width: self.grabberSize, height: 0)
        }
    }
}

@available(iOS 13.0, *)
struct ContentView_Previews : PreviewProvider {
    struct TestView: View {
        @State var baseValue: ClosedRange<Double> = 2...10
        var range: ClosedRange<Double> = 0...10
        var body: some View {
            HorizontalRangeSlider(value: $baseValue, range: range)
        }
    }
    
    static var previews: some View {
        TestView()
    }
}
