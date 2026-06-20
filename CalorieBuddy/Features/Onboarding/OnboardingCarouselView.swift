//
//  OnboardingCarouselView.swift
//  CalorieBuddy
//
//  Five-slide feature tour shown right after the welcome screen.
//

import SwiftUI

private struct CarouselSlide: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
}

struct OnboardingCarouselView: View {
    var onFinish: () -> Void

    @State private var index = 0

    private let slides: [CarouselSlide] = [
        .init(icon: "camera.viewfinder", tint: Theme.accent,
              title: "Track calories", subtitle: "Just snap a photo and let AI do the rest."),
        .init(icon: "drop.fill", tint: Theme.water,
              title: "Stay hydrated", subtitle: "Easily track your water and hit your goals."),
        .init(icon: "moon.stars.fill", tint: Theme.grape,
              title: "Enjoy fasting", subtitle: "Build a healthy habit you'll actually enjoy."),
        .init(icon: "chart.line.uptrend.xyaxis", tint: Theme.sky,
              title: "See results", subtitle: "Watch your weight trend toward your goal."),
        .init(icon: "heart.fill", tint: Theme.berry,
              title: "Feel the love", subtitle: "Balanced macros and a buddy cheering you on."),
    ]

    var body: some View {
        VStack(spacing: Spacing.lg) {
            TabView(selection: $index) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { offset, slide in
                    slideView(slide)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.smooth, value: index)

            PageDots(count: slides.count, index: index)

            OnboardingBottomButton(title: index == slides.count - 1 ? "Let's go" : "Next") {
                if index < slides.count - 1 {
                    withAnimation { index += 1 }
                } else {
                    onFinish()
                }
            }
        }
        .padding(.top, Spacing.xl)
        .background(Theme.background)
    }

    private func slideView(_ slide: CarouselSlide) -> some View {
        VStack(spacing: Spacing.xl) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(slide.tint.opacity(0.14))
                Image(systemName: slide.icon)
                    .font(.system(size: 96, weight: .semibold))
                    .foregroundStyle(slide.tint)
            }
            .frame(height: 320)
            .padding(.horizontal, Spacing.screen)

            VStack(spacing: Spacing.sm) {
                Text(slide.title)
                    .font(CBFont.largeTitle)
                    .foregroundStyle(Theme.ink)
                Text(slide.subtitle)
                    .font(CBFont.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.inkSecondary)
                    .padding(.horizontal, Spacing.xl)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview {
    OnboardingCarouselView(onFinish: {})
}
