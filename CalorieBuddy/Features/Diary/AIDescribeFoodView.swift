//
//  AIDescribeFoodView.swift
//  CalorieBuddy
//
//  Natural-language food entry: the user types what they ate, the AI (nl-parse
//  task) returns structured items, and the existing review screen lets them edit
//  and log. Falls back to a demo estimate when no proxy is configured.
//

import SwiftUI
import SwiftData

struct AIDescribeFoodView: View {
    let date: Date

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AIService.self) private var ai
    @Environment(HealthKitService.self) private var health
    @Environment(AppState.self) private var appState
    @Query private var streaks: [Streak]

    private enum Step { case input, analyzing, review, error }
    @State private var step: Step = .input
    @State private var text = ""
    @State private var errorMessage: String?
    @State private var vm = ScanViewModel()

    private var canSubmit: Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .input: inputView
                case .analyzing: AnalyzingView(image: nil)
                case .review: ScanReviewView(vm: vm, onSave: save, onRetake: { step = .input }, retakeTitle: "Edit")
                case .error: errorView
                }
            }
            .navigationTitle("Describe a meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Close") { dismiss() } }
            }
            .background(Theme.background)
        }
    }

    // MARK: Input

    private var inputView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack(spacing: Spacing.md) {
                    MascotView(mood: .thinking, size: 56)
                    Text("Tell me what you ate and I'll estimate the calories and macros.")
                        .font(CBFont.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("e.g. two scrambled eggs, a slice of sourdough toast with butter, and a flat white")
                            .font(CBFont.body)
                            .foregroundStyle(Theme.inkTertiary)
                            .padding(.top, 8)
                            .padding(.horizontal, 5)
                    }
                    TextEditor(text: $text)
                        .font(CBFont.body)
                        .frame(minHeight: 130)
                        .scrollContentBackground(.hidden)
                }
                .cbCard()

                if !ai.isConfigured {
                    Label("Demo mode — add a proxy URL to enable real AI.", systemImage: "info.circle")
                        .font(CBFont.caption)
                        .foregroundStyle(Theme.inkTertiary)
                }

                Button { submit() } label: {
                    Label("Estimate with AI", systemImage: "sparkles")
                }
                .buttonStyle(.cbPrimary)
                .disabled(!canSubmit)
            }
            .padding(.horizontal, Spacing.screen)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
    }

    private var errorView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.amber)
            Text("Couldn't estimate that").font(CBFont.title2).foregroundStyle(Theme.ink)
            Text(errorMessage ?? "Something went wrong.")
                .font(CBFont.subheadline)
                .foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            Spacer()
            Button("Try again") { step = .input }
                .buttonStyle(.cbPrimary)
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, Spacing.lg)
        }
    }

    // MARK: Actions

    private func submit() {
        let prompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }
        step = .analyzing
        errorMessage = nil
        Task {
            do {
                let result: AIScanResult
                if ai.isConfigured {
                    result = try await ai.parse(text: prompt)
                } else {
                    #if DEBUG
                    try? await Task.sleep(for: .seconds(1.0))
                    result = AIService.mockParse(text: prompt)
                    #else
                    throw AIError.notConfigured
                    #endif
                }
                vm.loadParsed(result, at: DiaryStore.timestamp(for: date))
                step = .review
                Haptics.success()
            } catch {
                errorMessage = (error as? AIError)?.errorDescription ?? error.localizedDescription
                step = .error
                Haptics.error()
            }
        }
    }

    private func save() {
        let advanced = vm.save(context: context, health: health, streak: streaks.first)
        dismiss()
        appState.goToToday()
        if let advanced { appState.celebrationDay = advanced }
    }
}

#Preview {
    AIDescribeFoodView(date: .now)
        .environment(AppState())
        .environment(AIService())
        .environment(HealthKitService())
        .modelContainer(AppContainer.preview)
}
