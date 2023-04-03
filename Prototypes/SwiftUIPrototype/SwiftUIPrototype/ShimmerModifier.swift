//
//  ShimmerModifier.swift
//  SwiftUIPrototype
//
//  Created by Ivo on 03/04/23.
//

import SwiftUI

struct ShimmeringView<Content: View>: View {
    private let content: () -> Content
    //  private let configuration: ShimmerConfiguration
    @State private var startPoint: UnitPoint
    @State private var endPoint: UnitPoint
    //  init(configuration: ShimmerConfiguration, @ViewBuilder content: @escaping () -> Content) {
    init(@ViewBuilder content: @escaping () -> Content) {
        //    self.configuration = configuration
        self.content = content
        _startPoint = .init(wrappedValue: UnitPoint(x: 0.0, y: 0.4))
        _endPoint = .init(wrappedValue: UnitPoint(x: 1.0, y: 0.6))
    }
    var body: some View {
        let white = Color.white
        let alpha = Color.white.opacity(0.7)
        let gradient = Gradient(colors: [white, alpha, white])
        ZStack {
            content()
            
            LinearGradient(gradient: gradient,
                           startPoint: startPoint,
                           endPoint: endPoint)
            .opacity(0.7)
            .blendMode(.screen)
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5)) {
                    startPoint = .trailing
                    endPoint = UnitPoint(x: 2.0, y: 0.5)
                }
            }
        }
    }
}

public struct ShimmerModifier: ViewModifier {
//    let configuration: ShimmerConfiguration
    public func body(content: Content) -> some View {
        ShimmeringView() { content }
    }
}


public extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
