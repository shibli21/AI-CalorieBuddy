//
//  Feedback.swift
//  CalorieBuddy
//
//  Toasts and lightweight loading indicators.
//

import SwiftUI
import Combine

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    var text: String
    var systemImage: String = "checkmark.circle.fill"
    var tint: Color = Theme.accent

    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool { lhs.id == rhs.id }
}

struct ToastView: View {
    let message: String
    var systemImage: String = "checkmark.circle.fill"
    var tint: Color = Theme.accent

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage).foregroundStyle(tint)
            Text(message)
                .font(CBFont.subheadline.weight(.medium))
                .foregroundStyle(Theme.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Theme.separator, lineWidth: 0.5))
        .cbShadow(.card)
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var toast: ToastMessage?

    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let toast {
                ToastView(message: toast.text, systemImage: toast.systemImage, tint: toast.tint)
                    .padding(.top, Spacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .task(id: toast.id) {
                        try? await Task.sleep(for: .seconds(2.2))
                        withAnimation(.snappy) { self.toast = nil }
                    }
            }
        }
        .animation(.snappy, value: toast?.id)
    }
}

extension View {
    func cbToast(_ toast: Binding<ToastMessage?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

/// Three pulsing dots for AI "analyzing…" states. Holds still under Reduce Motion.
struct PulsingDots: View {
    var color: Color = Theme.accent
    @State private var phase = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .opacity(reduceMotion ? 0.7 : (phase == i ? 1 : 0.3))
                    .scaleEffect(reduceMotion ? 1 : (phase == i ? 1.2 : 1))
            }
        }
        .onReceive(timer) { _ in
            guard !reduceMotion else { return }
            withAnimation(.snappy(duration: 0.25)) { phase = (phase + 1) % 3 }
        }
        .accessibilityLabel("Analyzing")
    }
}

#Preview {
    VStack(spacing: 24) {
        ToastView(message: "Meal logged")
        PulsingDots()
    }
    .padding()
    .background(Theme.background)
}
