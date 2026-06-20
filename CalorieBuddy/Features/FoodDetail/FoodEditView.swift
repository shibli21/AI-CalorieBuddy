//
//  FoodEditView.swift
//  CalorieBuddy
//
//  Edit a logged meal: name, type, time, and ingredients. Totals recompute
//  from ingredients on save.
//

import SwiftUI
import SwiftData

struct FoodEditView: View {
    @Bindable var entry: FoodEntry
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    TextField("Name", text: $entry.name)
                    Picker("Type", selection: $entry.mealType) {
                        ForEach(MealType.allCases) { Text($0.title).tag($0) }
                    }
                    DatePicker("When", selection: $entry.loggedAt)
                }
                Section("Ingredients") {
                    ForEach(entry.ingredientsList) { ingredient in
                        NavigationLink {
                            IngredientModelEditView(ingredient: ingredient)
                        } label: {
                            HStack {
                                Text(ingredient.name.isEmpty ? "Item" : ingredient.name)
                                Spacer()
                                Text("\(ingredient.kcal) kcal").foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteIngredients)

                    Button {
                        addIngredient()
                    } label: {
                        Label("Add ingredient", systemImage: "plus")
                    }
                }
                Section {
                    HStack {
                        Text("Total").font(CBFont.bodyEmphasized)
                        Spacer()
                        Text("\(entry.totalKcal) kcal").foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Done") { save() } }
            }
        }
    }

    private func addIngredient() {
        let ingredient = Ingredient(name: "New item")
        ingredient.entry = entry
        context.insert(ingredient)
        entry.recalcFromIngredients()
    }

    private func deleteIngredients(_ offsets: IndexSet) {
        let list = entry.ingredientsList
        for index in offsets where list.indices.contains(index) {
            context.delete(list[index])
        }
        entry.recalcFromIngredients()
    }

    private func save() {
        entry.recalcFromIngredients()
        try? context.save()
        Haptics.success()
        dismiss()
    }
}

struct IngredientModelEditView: View {
    @Bindable var ingredient: Ingredient

    var body: some View {
        Form {
            Section("Item") {
                TextField("Name", text: $ingredient.name)
                HStack {
                    Text("Quantity")
                    Spacer()
                    TextField("Qty", value: $ingredient.quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }
                TextField("Unit (e.g. g, cup)", text: $ingredient.unit)
            }
            Section("Nutrition") {
                numberField("Calories", value: $ingredient.kcal, unit: "kcal")
                numberField("Protein", value: $ingredient.protein, unit: "g")
                numberField("Carbs", value: $ingredient.carbs, unit: "g")
                numberField("Fat", value: $ingredient.fat, unit: "g")
                numberField("Fiber", value: $ingredient.fiber, unit: "g")
            }
        }
        .navigationTitle("Edit item")
        .navigationBarTitleDisplayMode(.inline)
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
