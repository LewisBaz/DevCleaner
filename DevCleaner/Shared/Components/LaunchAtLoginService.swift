//
//  LaunchAtLoginService.swift
//  DevCleaner
//
//  Created by Codex on 20.04.2026.
//

import Foundation
import ServiceManagement
import os

@MainActor
final class LaunchAtLoginService: ObservableObject {

    @Published private(set) var isEnabled: Bool

    private let logger = Logger(subsystem: "devcleaner", category: "LaunchAtLoginService")

    init() {
        isEnabled = SMAppService.mainApp.status == .enabled
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            isEnabled = SMAppService.mainApp.status == .enabled
        } catch {
            logger.error("Failed to update launch at login state: \(error.localizedDescription, privacy: .public)")
            isEnabled = SMAppService.mainApp.status == .enabled
        }
    }
}
