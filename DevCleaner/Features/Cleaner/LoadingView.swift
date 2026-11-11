//
//  LoadingView.swift
//  DevCleaner
//
//  Created by Lewis on 14.08.2025.
//

import SwiftUI

struct LoadingView: View {

    @Binding var status: ActionStatus

    private static let byteFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter
    }()

    var body: some View {
        VStack(spacing: 12) {
            switch status {
            case .initial:
                EmptyView()
            case .running(let progress, let bytesFreed):
                ProgressView(value: progress, total: 100)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 220)
                if bytesFreed > 0 {
                    Text(freedText(bytesFreed))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            case .completed(let bytesFreed):
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.largeTitle)
                Text(bytesFreed > 0 ? freedText(bytesFreed) : LocalizedString("Status.NothingToClean"))
                    .font(.callout)
            case .failed(let reason):
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.largeTitle)
                Text(reason)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .frame(width: 260)
    }

    private func freedText(_ bytes: Int64) -> String {
        String(format: LocalizedString("Status.Freed"), Self.byteFormatter.string(fromByteCount: bytes))
    }
}

#Preview {
    LoadingView(status: .init(get: { .completed(bytesFreed: 1_500_000) }, set: { _ in }))
}
