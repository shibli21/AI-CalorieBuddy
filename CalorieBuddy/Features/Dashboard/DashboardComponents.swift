//
//  DashboardComponents.swift
//  CalorieBuddy
//
//  Reusable pieces of the Today dashboard.
//

import SwiftUI
import UIKit

struct DayStatCard: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String
    var progress: Double? = nil
    var addAction: (() -> Void)? = nil
    var tapAction: (() -> Void)? = nil

    var body: some View {
        if let tapAction {
            Button(action: tapAction) { cardContent }
                .buttonStyle(.plain)
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Image(systemName: icon).foregroundStyle(tint)
                Spacer()
                if addAction != nil {
                    Button {
                        Haptics.tap()
                        addAction?()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(tint)
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(value)
                .font(CBFont.title3)
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(CBFont.caption)
                .foregroundStyle(Theme.inkSecondary)
            if let progress {
                ProgressView(value: min(1, max(0, progress)))
                    .tint(tint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard(padding: Spacing.md)
    }
}

struct FoodEntryRow: View {
    let entry: FoodEntry

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(Theme.surfaceAlt)
                    .frame(width: 44, height: 44)
                if let data = entry.photoData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.sm, style: .continuous))
                } else {
                    Image(systemName: entry.source.systemImage)
                        .foregroundStyle(Theme.inkSecondary)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name.isEmpty ? "Meal" : entry.name)
                    .font(CBFont.bodyEmphasized)
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                Text(entry.servingDesc.isEmpty ? entry.source.label : entry.servingDesc)
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: Spacing.sm)
            (Text("\(entry.totalKcal)").font(CBFont.bodyEmphasized).foregroundColor(Theme.ink)
             + Text(" kcal").font(CBFont.caption).foregroundColor(Theme.inkSecondary))
        }
        .padding(.vertical, Spacing.xs)
        .contentShape(Rectangle())
    }
}

struct MealSectionView: View {
    let meal: MealType
    let entries: [FoodEntry]
    var onAdd: () -> Void
    var onDelete: (FoodEntry) -> Void

    private var total: Int { entries.reduce(0) { $0 + $1.totalKcal } }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Label(meal.title, systemImage: meal.systemImage)
                    .font(CBFont.headline)
                    .foregroundStyle(Theme.ink)
                Spacer()
                if total > 0 {
                    Text("\(total) kcal")
                        .font(CBFont.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                }
                Button {
                    Haptics.tap()
                    onAdd()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.accent)
                }
                .buttonStyle(.plain)
            }

            if entries.isEmpty {
                Text("Nothing logged yet")
                    .font(CBFont.subheadline)
                    .foregroundStyle(Theme.inkTertiary)
                    .padding(.vertical, Spacing.xs)
            } else {
                ForEach(entries) { entry in
                    NavigationLink(value: entry) {
                        FoodEntryRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            onDelete(entry)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    if entry.id != entries.last?.id {
                        Divider().overlay(Theme.separator)
                    }
                }
            }
        }
        .cbCard()
    }
}

struct MascotBanner: View {
    let mascotName: String
    let remaining: Int
    let target: Int

    var body: some View {
        HStack(spacing: Spacing.md) {
            MascotView(mood: mood, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(headline)
                    .font(CBFont.bodyEmphasized)
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkSecondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cbCard(padding: Spacing.md)
    }

    private var mood: MascotMood {
        if remaining < 0 { .sad }
        else if remaining < target / 10 { .hungry }
        else { .happy }
    }
    private var headline: String {
        if remaining < 0 { "Over your goal today" }
        else if remaining < target / 10 { "Almost there!" }
        else { "Hi, I'm \(mascotName)!" }
    }
    private var subtitle: String {
        if remaining < 0 { "It's okay — tomorrow is a fresh start." }
        else { "\(remaining) kcal left to log today." }
    }
}
