//
//  DayNavBar.swift
//  CalorieBuddy
//
//  Reusable previous/next day navigation with a calendar jump.
//

import SwiftUI

struct DayNavBar: View {
    @Binding var date: Date
    @State private var showCalendar = false

    private var canGoForward: Bool {
        Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: .now)
    }

    var body: some View {
        HStack {
            CircleIconButton(systemImage: "chevron.left", size: 36) { shift(-1) }
            Spacer()
            Button { showCalendar = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(label).font(CBFont.headline)
                }
                .foregroundStyle(Theme.ink)
            }
            .buttonStyle(.plain)
            Spacer()
            CircleIconButton(systemImage: "chevron.right", size: 36) { shift(1) }
                .opacity(canGoForward ? 1 : 0.3)
                .disabled(!canGoForward)
        }
        .sheet(isPresented: $showCalendar) {
            NavigationStack {
                DatePicker("Date", selection: $date,
                           in: ...Calendar.current.startOfDay(for: .now),
                           displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Jump to a day")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showCalendar = false }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func shift(_ delta: Int) {
        if delta > 0 && !canGoForward { return }
        let cal = Calendar.current
        if let newDate = cal.date(byAdding: .day, value: delta, to: date) {
            date = cal.startOfDay(for: newDate)
            Haptics.selection()
        }
    }

    private var label: String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Today" }
        if cal.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.abbreviated).month().day())
    }
}
