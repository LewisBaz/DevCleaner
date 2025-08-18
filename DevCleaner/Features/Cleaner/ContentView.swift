//
//  ContentView.swift
//  DevCleaner
//
//  Created by Lewis on 13.08.2025.
//

import SwiftUI

struct ContentView: View {

    @Binding var status: ActionStatus

    var body: some View {
        VStack {
            ForEach(ActionsFactory().create()) { action in
                Button(action.name) {
                    Task {
                        await performAction(ActionPerformer(action: action.action))
                    }
                }
                if action.divider {
                    Divider()
                }
            }
        }
    }

    private func performAction(_ performer: ActionPerformer) async {
        Task {
            do {
                for try await status in performer.perform() {
                    await MainActor.run {
                        self.status = status
                    }
                }
            }
            catch is PerformerSpecialCaseError {
                NSApplication.shared.terminate(self)
            }
        }
    }
}

#Preview {
    ContentView(status: .init(get: { .completed }, set: { _ in }))
}
