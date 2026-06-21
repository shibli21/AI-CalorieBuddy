//
//  OnboardingCarouselView.swift
//  CalorieBuddy
//
//  Five-slide feature tour, mascot-forward, shown after the welcome screen.
//

import SwiftUI

private struct CarouselSlide: Identifiable {
    let id = UUID()
    let icon: String
    let tint: Color
    let mood: MascotMood
    let title: String
    let subtitle: String
}

struct OnboardingCarouselView: View {
    var onFinish: () -> Void

    @State private var index = 0

    private let slides: [CarouselSlide] = [
        .init(icon: "camera.viewfinder", tint: Theme.accent, mood: .scanning,
              title: "Track calories", subtitle: "Just snap a photo and let AI do the rest."),
        .init(icon: "drop.fill", tint: Theme.water, mood: .drinkingWater,
              title: "Stay hydrated", subtitle: "Easily track your water and hit your goals."),
        .init(icon: "moon.stars.fill", tint: Theme.grape, mood: .meditating,
              title: "Enjoy fasting", subtitle: "Build a healthy habit you'll actually enjoy."),
        .init(icon: "chart.line.uptrend.xyaxis", tint: Theme.sky, mood: .weighing,
              title: "See results", subtitle: "Watch your weight trend toward your goal."),
        .init(icon: "heart.fill", tint: Theme.berry, mood: .love,
              title: "Feel the love", subtitle: "Balanced macros and a buddy cheering you on."),
    ]

    var body: some View {
        VStack(spacing: Spacing.lg) {
            TabView(selection: $index) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { offset, slide in
                    slideView(slide).tag(offset)
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
                MascotView(mood: slide.mood, size: 210)
            }
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                Image(systemName: slide.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(slide.tint, in: Circle())
                    .padding(Spacing.lg)
            }
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
