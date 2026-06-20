//
//  ScanReviewView.swift
//  CalorieBuddy
//
//  Editable AI result: rename, fix the meal type/time, tweak ingredients, log.
//

import SwiftUI

struct ScanReviewView: View {
    @Bindable var vm: ScanViewModel
    var onSave: () -> Void
    var onRetake: () -> Void

    @State private var editingItem: AIScanItem?

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                if let image = vm.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 190)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                }

                if vm.isLowConfidence {
                    Label("Low confidence — please double-check these items.", systemImage: "exclamationmark.triangle.fill")
                        .font(CBFont.caption)
                        .foregroundStyle(Theme.amber)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: Spacing.md) {
                    TextField("Meal name", text: $vm.title)
                        .font(CBFont.title3)
                        .foregroundStyle(Theme.ink)
                    Divider().overlay(Theme.separator)
                    Picker("Meal", selection: $vm.mealType) {
                        ForEach(MealType.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    DatePicker("When", selection: $vm.loggedAt)
                        .font(CBFont.subheadline)
                }
                .cbCard()

                VStack(spacing: Spacing.md) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xs) {
                        Text("\(vm.totalKcal)")
                            .font(CBFont.display(36))
                            .foregroundStyle(Theme.ink)
                            .contentTransition(.numericText())
                        Text("kcal").font(CBFont.headline).foregroundStyle(Theme.inkSecondary)
                        Spacer()
                    }
                    HStack(spacing: Spacing.sm) {
                        MacroChip(kind: .protein, grams: vm.totalProtein)
                        MacroChip(kind: .carbs, grams: vm.totalCarbs)
                        MacroChip(kind: .fat, grams: vm.totalFat)
                    }
                }
                .cbCard()

                VStack(alignment: .leading, spacing: Spacing.sm) {
                    HStack {
                        Text("Ingredients").font(CBFont.headline).foregroundStyle(Theme.ink)
                        Spacer()
                        Button {
                            Haptics.tap()
                            vm.addItem()
                        } label: {
                            Image(systemName: "plus.circle.fill").font(.title3).foregroundStyle(Theme.accent)
                        }
                        .buttonStyle(.plain)
                    }
                    if vm.items.isEmpty {
                        Text("No items — add one above.")
                            .font(CBFont.subheadline)
                            .foregroundStyle(Theme.inkTertiary)
                            .padding(.vertical, Spacing.xs)
                    } else {
                        ForEach(vm.items) { item in
                            Button { editingItem = item } label: { row(item) }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) { vm.removeItem(item.id) } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            if item.id != vm.items.last?.id {
                                Divider().overlay(Theme.separator)
                            }
                        }
                    }
                }
                .cbCard()
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, Spacing.xxl)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: Spacing.md) {
                Button("Retake", action: onRetake)
                    .buttonStyle(.cbSecondary)
                    .frame(width: 130)
                Button("Log meal", action: onSave)
                    .buttonStyle(.cbPrimary)
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.vertical, Spacing.sm)
        }
        .sheet(item: $editingItem) { item in
            IngredientEditView(item: vm.binding(for: item))
        }
    }

    private func row(_ item: AIScanItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name.isEmpty ? "Item" : item.name)
                    .font(CBFont.bodyEmphasized)
                    .foregroundStyle(Theme.ink)
                Text(portion(item))
                    .font(CBFont.caption)
                    .foregroundStyle(Theme.inkSecondary)
            }
            Spacer()
            Text("\(item.kcal) kcal")
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.inkSecondary)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Theme.inkTertiary)
        }
        .contentShape(Rectangle())
    }

    private func portion(_ item: AIScanItem) -> String {
        let qty = item.quantity == item.quantity.rounded()
            ? String(Int(item.quantity))
            : String(format: "%.1f", item.quantity)
        return "\(qty) \(item.unit)"
    }
}

struct IngredientEditView: View {
    @Binding var item: AIScanItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Name", text: $item.name)
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("Qty", value: $item.quantity, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    TextField("Unit (e.g. g, cup)", text: $item.unit)
                }
                Section("Nutrition") {
                    numberField("Calories", value: $item.kcal, unit: "kcal")
                    numberField("Protein", value: $item.protein, unit: "g")
                    numberField("Carbs", value: $item.carbs, unit: "g")
                    numberField("Fat", value: $item.fat, unit: "g")
                    numberField("Fiber", value: $item.fiber, unit: "g")
                }
            }
            .navigationTitle("Edit item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func numberField(_ label: String, value: Binding<Int>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, value: value, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
            Text(unit).foregroundStyle(.secondary)
        }
    }
}
