//
//  ActionPerformer.swift
//  DevCleaner
//
//  Created by Lewis on 13.08.2025.
//

import Foundation
import AppKit
import ServiceManagement
import SwiftUI

enum ActionStatus: Equatable {
    case initial
    case running(_ progress: Double)
    case completed
    case failed
}

protocol ActionPerforming {
    init(action: Action)
    func perform() -> AsyncThrowingStream<ActionStatus, Error>
}

final class ActionPerformer: ActionPerforming {
    private let action: Action

    init(action: Action) {
        self.action = action
    }

    func perform() -> AsyncThrowingStream<ActionStatus, Error> {
        switch action.source {
        case .folder(let folder):
            return performFolderAction(folder)
        case .shell(let shell):
            return performShellAction(shell)
        }
    }

    private func performFolderAction(_ source: Source.Folder) -> AsyncThrowingStream<ActionStatus, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                continuation.yield(.running(0))
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continuation.yield(.completed)
                continuation.finish()
            }
        }
    }

    private func performShellAction(_ source: Source.Shell) -> AsyncThrowingStream<ActionStatus, Error> {
        let (launchPath, arguments) = shellCommandForAction(source)
        return AsyncThrowingStream { continuation in
            Task {
                continuation.yield(.running(0))
                let task = Process()
                task.launchPath = launchPath
                task.arguments = arguments
                continuation.yield(.running(10))
                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = pipe
                task.launch()
                continuation.yield(.running(20))
                task.waitUntilExit()
                continuation.yield(.completed)
                continuation.finish()
            }
        }
    }

    private func shellCommandForAction(_ source: Source.Shell) -> (String, [String]) {
        switch source {
        case .cleanBin:
            return ("/usr/bin/osascript", ["-e", "tell application \"Finder\" to empty the trash"])
        case .removeOldSimulators:
            return ("/usr/bin/xcrun", ["simctl", "delete", "unavailable"])
        case .removeSimulatorPreviews:
            return ("/usr/bin/xcrun", ["simctl", "--set", "previews", "delete", "all"])
        case .removeSimulatorsData:
            return ("/usr/bin/xcrun", ["simctl", "erase", "all"])
        case .removeCocoaPodsCache:
            return ("/bin/bash", ["-c", "if command -v pod &> /dev/null; then pod cache clean --all; else echo 'CocoaPods not installed'; fi"])
        }
    }
}
