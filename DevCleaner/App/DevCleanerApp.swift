//
//  DevCleanerApp.swift
//  DevCleaner
//
//  Created by Lewis on 13.08.2025.
//

import SwiftUI

@main
struct DevCleanerApp: App {

    @State private var window: NSWindow?
    @State private var actionStatus: ActionStatus = .initial
    @State private var actionProgress: Double = 0

    var body: some Scene {
        MenuBarExtra(LocalizedString("AppName"), systemImage: "externaldrive.fill") {
            ContentView(status: $actionStatus)
        }
        .onChange(of: actionStatus) { oldValue, newValue in
            switch newValue {
            case .initial:
                break
            case .running(let progress):
                showWindow()
                actionProgress = progress
            case .completed:
                actionProgress = 100
                hideWindow()
            case .failed:
                print("error")
                hideWindow()
            }
        }
    }

    private func showWindow() {
        if window == nil {
            let contentView = NSHostingView(rootView: LoadingView(progress: $actionProgress))
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false)
            newWindow.center()
            newWindow.contentView = contentView
            newWindow.title = LocalizedString("AppName")
            window = newWindow
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func hideWindow() {
        Task {
            try await Task.sleep(for: .milliseconds(500))
            await MainActor.run {
                window?.orderOut(nil)
            }
        }
    }
}
