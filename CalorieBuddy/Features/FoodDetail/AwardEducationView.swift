//
//  AwardEducationView.swift
//  CalorieBuddy
//
//  Paged educational content for a nutrition award (e.g. "Rich in fiber").
//

import SwiftUI

struct AwardEducationView: View {
    let award: NutritionAward
    @Environment(\.dismiss) private var dismiss
    @State private var index = 0

    var body: some View {
        VStack(spacing: Spacing.lg) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.inkTertiary)
                }
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.md)

            TabView(selection: $index) {
                ForEach(Array(award.pages.enumerated()), id: \.element.id) { offset, page in
                    VStack(spacing: Spacing.lg) {
                        Spacer()
                        Image(systemName: page.systemImage)
                            .font(.system(size: 66))
                            .foregroundStyle(Theme.brandGradient)
                        Text(page.title)
                            .font(CBFont.title)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.ink)
                        Text(page.body)
                            .font(CBFont.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Theme.inkSecondary)
                            .padding(.horizontal, Spacing.xl)
                        Spacer()
                    }
                    .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.smooth, value: index)

            PageDots(count: award.pages.count, index: index)

            Button(index == award.pages.count - 1 ? "Done" : "Next") {
                if index < award.pages.count - 1 {
                    withAnimation { index += 1 }
                } else {
                    dismiss()
                }
            }
            .buttonStyle(.cbPrimary)
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.lg)
        }
        .background(Theme.background)
    }
}
