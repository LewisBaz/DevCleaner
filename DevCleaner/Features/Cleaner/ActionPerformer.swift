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
import os

enum ActionStatus: Equatable {
    case initial
    case running(_ progress: Double)
    case completed
    case failed
}

enum ActionPerformingError: Error {
    case directoryNotFound(_ path: String)
}

enum PerformerSpecialCaseError: Error {
    case quitApp
}

struct ActionPerformer: Sendable {
    private let action: Action
    private let logger = Logger(subsystem: "devcleaner", category: "ActionPerformer")

    init(action: Action) {
        self.action = action
    }

    func perform() -> AsyncThrowingStream<ActionStatus, Error> {
        switch action.source {
        case .folder(let folder):
            return performFolderAction(folder)
        case .shell(let shell):
            return performShellAction(shell)
        case .other(let other):
            switch other {
            case .clearAll:
                return performClearAllAction()
            case .quit:
                return performQuitApp()
            }
        }
    }

    private func performFolderAction(_ source: Source.Folder) -> AsyncThrowingStream<ActionStatus, Error> {
        let path = pathForAction(source)
        guard let items = try? FileManager.default.contentsOfDirectory(atPath: path)
        else { return
            AsyncThrowingStream { continuation in
                continuation.finish(throwing: ActionPerformingError.directoryNotFound(path))
            }
        }
        let totalCount = items.count
        return AsyncThrowingStream { continuation in
            Task {
                logger.info("action \(path) started")
                continuation.yield(.running(0))
                if totalCount == 0 {
                    continuation.yield(.completed)
                    continuation.finish()
                    logger.info("action \(path) finished without any files to remove")
                    return
                }
                for (index, item) in items.enumerated() {
                    let fullPath = (path as NSString).appendingPathComponent(item)
                    do {
                        try FileManager.default.removeItem(atPath: fullPath)
                        let progress = Double(index + 1) / Double(totalCount) * 100
                        continuation.yield(.running(progress))
                    } catch {
                        logger.info("action \(path) throw remove file error")
                    }
                }
                continuation.yield(.completed)
                continuation.finish()
                logger.info("action \(path) finished")
            }
        }
    }

    private func performShellAction(_ source: Source.Shell) -> AsyncThrowingStream<ActionStatus, Error> {
        let (launchPath, arguments) = shellCommandForAction(source)
        return AsyncThrowingStream { continuation in
            Task {
                logger.info("action at \(launchPath) with arguments \(arguments) started")
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
                logger.info("action at \(launchPath) with arguments \(arguments) finished")
            }
        }
    }

    private func pathForAction(_ source: Source.Folder) -> String {
        switch source {
        case .clearDerivedData:
            return "/Users/\(NSUserName())/Library/Developer/Xcode/DerivedData"
        case .clearXcodeCaches:
            return "/Users/\(NSUserName())/Library/Developer/CoreSimulator/Caches"
        case .clearArchives:
            return "/Users/\(NSUserName())/Library/Developer/Xcode/Archives"
        case .clearIOSDeviceSupport:
            return "/Users/\(NSUserName())/Library/Developer/Xcode/iOS DeviceSupport"
        case .clearWatchOSDeviceSupport:
            return "/Users/\(NSUserName())/Library/Developer/Xcode/watchOS DeviceSupport"
        case .clearTVOSDeviceSupport:
            return "/Users/\(NSUserName())/Library/Developer/Xcode/tvOS DeviceSupport"
        case .clearCaches:
            return "/Users/\(NSUserName())/Library/Caches"
        }
    }

    private func shellCommandForAction(_ source: Source.Shell) -> (String, [String]) {
        switch source {
        case .removeOldSimulators:
            return ("/usr/bin/xcrun", ["simctl", "delete", "unavailable"])
        case .removeSimulatorPreviews:
            return ("/usr/bin/xcrun", ["simctl", "--set", "previews", "delete", "all"])
        case .removeSimulatorsData:
            return ("/usr/bin/xcrun", ["simctl", "erase", "all"])
        case .removeCocoaPodsCache:
            return ("/bin/bash", ["-c", "if command -v pod &> /dev/null; then pod cache clean --all; else echo 'CocoaPods not installed'; fi"])
        case .clearTrash:
            return ("/usr/bin/osascript", ["-e", "tell application \"Finder\" to empty the trash"])
        }
    }

    private func performClearAllAction() -> AsyncThrowingStream<ActionStatus, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let allActions: [ActionPerformer] =
                Source.Folder.allCases.map { ActionPerformer(action: .init(source: .folder($0))) } +
                Source.Shell.allCases.map { ActionPerformer(action: .init(source: .shell($0))) }
                let total = allActions.count
                var completed = 0
                var onComplete: (() -> Void) = {
                    completed += 1
                    let overall = Double(completed) / Double(total) * 100
                    continuation.yield(.running(overall))
                }

                for performer in allActions {
                    do {
                        for try await status in performer.perform() {
                            switch status {
                            case .completed, .failed:
                                onComplete()
                            default:
                                break
                            }
                        }
                    }
                    catch {
                        onComplete()
                    }
                }
                continuation.yield(.completed)
                continuation.finish()
            }
        }
    }

    private func performQuitApp() -> AsyncThrowingStream<ActionStatus, Error> {
        return AsyncThrowingStream<ActionStatus, Error> { continuation in
            continuation.finish(throwing: PerformerSpecialCaseError.quitApp)
        }
    }
}
