//
//  CoachChatView.swift
//  CalorieBuddy
//
//  Conversational AI nutrition coach (coach task). Persists history in SwiftData,
//  sends recent turns + today's context to the proxy, and shows replies as chat
//  bubbles. Pro-gated (see SettingsView). Includes a not-medical-advice note.
//

import SwiftUI
import SwiftData

struct CoachChatView: View {
    @Environment(\.modelContext) private var context
    @Environment(AIService.self) private var ai
    @Query(sort: \CoachMessage.createdAt) private var messages: [CoachMessage]
    @Query private var profiles: [UserProfile]
    @Query private var todayEntries: [FoodEntry]

    @State private var input = ""
    @State private var sending = false
    @State private var errorMessage: String?
    @State private var showClear = false

    private let suggestions = [
        "How am I doing today?",
        "Ideas for a high-protein snack?",
        "What should I cook for dinner?",
    ]

    init() {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        _todayEntries = Query(filter: #Predicate<FoodEntry> { $0.loggedAt >= start && $0.loggedAt < end },
                              sort: \FoodEntry.loggedAt)
    }

    var body: some View {
        VStack(spacing: 0) {
            chatScroll
            if let errorMessage {
                HStack(spacing: Spacing.sm) {
                    Text(errorMessage)
                        .font(CBFont.caption)
                        .foregroundStyle(Theme.berry)
                    Spacer()
                    Button("Retry") { Haptics.tap(); generateReply() }
                        .font(CBFont.caption.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                        .disabled(sending)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.screen)
                .padding(.bottom, 4)
            }
            disclaimer
            inputBar
        }
        .background(Theme.background)
        .navigationTitle("AI Coach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !messages.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showClear = true } label: { Image(systemName: "trash") }
                        .accessibilityLabel("Clear chat")
                }
            }
        }
        .alert("Clear this chat?", isPresented: $showClear) {
            Button("Clear", role: .destructive) { clearHistory() }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: Chat list

    private var chatScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.md) {
                    if messages.isEmpty { emptyState }
                    ForEach(messages) { message in
                        bubble(message).id(message.id)
                    }
                    if sending {
                        typingBubble.id("typing")
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, Spacing.screen)
                .padding(.vertical, Spacing.md)
            }
            .onChange(of: messages.count) { _, _ in scrollToBottom(proxy) }
            .onChange(of: sending) { _, _ in scrollToBottom(proxy) }
            .onAppear { scrollToBottom(proxy, animated: false) }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy, animated: Bool = true) {
        let target = sending ? "typing" : "bottom"
        if animated {
            withAnimation(.smooth(duration: 0.25)) { proxy.scrollTo(target, anchor: .bottom) }
        } else {
            proxy.scrollTo(target, anchor: .bottom)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .center, spacing: Spacing.md) {
            MascotView(mood: .cool, size: 100)
            Text("Hey! I'm your nutrition coach.")
                .font(CBFont.title3).foregroundStyle(Theme.ink)
            Text("Ask me anything about your meals, macros, or goals.")
                .font(CBFont.subheadline).foregroundStyle(Theme.inkSecondary)
                .multilineTextAlignment(.center)
            VStack(spacing: Spacing.sm) {
                ForEach(suggestions, id: \.self) { s in
                    Button { sendText(s) } label: {
                        Text(s)
                            .font(CBFont.subheadline)
                            .foregroundStyle(Theme.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .background(Theme.surfaceAlt, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, Spacing.sm)
            Text("Your coach can be wrong and isn't medical advice.")
                .font(CBFont.caption2)
                .foregroundStyle(Theme.inkTertiary)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.xl)
    }

    private func bubble(_ message: CoachMessage) -> some View {
        let isUser = message.role == .user
        return HStack(alignment: .bottom, spacing: Spacing.xs) {
            if isUser { Spacer(minLength: 40) }
            if !isUser { MascotView(mood: .happy, size: 28) }
            Text(message.content)
                .font(CBFont.body)
                .foregroundStyle(isUser ? .white : Theme.ink)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(
                    isUser ? AnyShapeStyle(Theme.accent) : AnyShapeStyle(Theme.surface),
                    in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
                )
                .frame(maxWidth: 300, alignment: isUser ? .trailing : .leading)
            if !isUser { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private var typingBubble: some View {
        HStack(spacing: Spacing.xs) {
            MascotView(mood: .thinking, size: 28)
            HStack(spacing: 4) { PulsingDots() }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Input

    private var inputBar: some View {
        HStack(spacing: Spacing.sm) {
            TextField("Ask your coach…", text: $input, axis: .vertical)
                .lineLimit(1...4)
                .font(CBFont.body)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(Theme.surfaceAlt, in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous))
                .onSubmit { sendText(input) }

            Button { sendText(input) } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(canSend ? Theme.accent : Theme.inkTertiary)
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
            .accessibilityLabel("Send")
        }
        .padding(.horizontal, Spacing.screen)
        .padding(.vertical, Spacing.sm)
        .background(.bar)
    }

    private var canSend: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !sending
    }

    private var disclaimer: some View {
        Text("Your coach can be wrong and isn't medical advice.")
            .font(CBFont.caption2)
            .foregroundStyle(Theme.inkTertiary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.screen)
            .padding(.bottom, 2)
    }

    // MARK: Logic

    private func sendText(_ raw: String) {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !sending else { return }
        input = ""
        let userMessage = CoachMessage(role: .user, content: text)
        context.insert(userMessage)
        try? context.save()
        generateReply()
    }

    /// Request an assistant reply for the conversation as it stands. Used after a
    /// new message and to retry a failed turn — no new user message is inserted on
    /// retry (the failed turn is already persisted), so tapping Retry just re-asks.
    private func generateReply() {
        guard !sending else { return }
        errorMessage = nil
        sending = true
        let history = recentHistory()
        let dayContext = AIInsightContext.day(entries: todayEntries, profile: profiles.first)
        Task {
            do {
                let reply: String
                if ai.isConfigured {
                    reply = try await ai.coachReply(messages: history, context: dayContext)
                } else {
                    #if DEBUG
                    try? await Task.sleep(for: .seconds(0.8))
                    reply = AIService.mockCoachReply(to: history.last?.content ?? "")
                    #else
                    throw AIError.notConfigured
                    #endif
                }
                let aiMessage = CoachMessage(role: .assistant, content: reply)
                context.insert(aiMessage)
                try? context.save()
                sending = false
                Haptics.tap()
            } catch {
                errorMessage = (error as? AIError)?.errorDescription ?? error.localizedDescription
                sending = false
                Haptics.error()
            }
        }
    }

    /// The persisted conversation (capped), authoritative even if @Query hasn't
    /// refreshed yet after an insert.
    private func recentHistory() -> [AICoachMessage] {
        let descriptor = FetchDescriptor<CoachMessage>(sortBy: [SortDescriptor(\.createdAt)])
        let all = (try? context.fetch(descriptor)) ?? []
        return all.suffix(20).map { AICoachMessage(role: $0.role.rawValue, content: $0.content) }
    }

    private func clearHistory() {
        for message in messages { context.delete(message) }
        try? context.save()
        Haptics.warning()
    }
}

#Preview {
    NavigationStack {
        CoachChatView()
            .environment(AIService())
            .modelContainer(AppContainer.preview)
    }
}
