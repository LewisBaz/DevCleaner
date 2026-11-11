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
    case running(progress: Double, bytesFreed: Int64)
    case completed(bytesFreed: Int64)
    case failed(reason: String)
}

enum ActionPerformingError: Error, LocalizedError {
    case directoryNotFound(_ path: String)

    var errorDescription: String? {
        switch self {
        case .directoryNotFound(let path):
            return String(format: LocalizedString("Status.FolderNotFound"), path)
        }
    }
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
                continuation.yield(.running(progress: 0, bytesFreed: 0))
                if totalCount == 0 {
                    continuation.yield(.completed(bytesFreed: 0))
                    continuation.finish()
                    logger.info("action \(path) finished without any files to remove")
                    return
                }
                var freed: Int64 = 0
                for (index, item) in items.enumerated() {
                    let fullPath = (path as NSString).appendingPathComponent(item)
                    let itemSize = sizeOfItem(atPath: fullPath)
                    do {
                        try FileManager.default.removeItem(atPath: fullPath)
                        freed += itemSize
                        let progress = Double(index + 1) / Double(totalCount) * 100
                        continuation.yield(.running(progress: progress, bytesFreed: freed))
                    } catch {
                        logger.info("action \(path) throw remove file error")
                    }
                }
                continuation.yield(.completed(bytesFreed: freed))
                continuation.finish()
                logger.info("action \(path) finished, freed \(freed) bytes")
            }
        }
    }

    private func sizeOfItem(atPath path: String) -> Int64 {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else { return 0 }
        if !isDirectory.boolValue {
            let attributes = try? fileManager.attributesOfItem(atPath: path)
            return (attributes?[.size] as? Int64) ?? 0
        }
        guard let enumerator = fileManager.enumerator(atPath: path) else { return 0 }
        var total: Int64 = 0
        for case let relativePath as String in enumerator {
            let fullPath = (path as NSString).appendingPathComponent(relativePath)
            guard let attributes = try? fileManager.attributesOfItem(atPath: fullPath),
                  attributes[.type] as? FileAttributeType != .typeDirectory
            else { continue }
            total += (attributes[.size] as? Int64) ?? 0
        }
        return total
    }

    private func performShellAction(_ source: Source.Shell) -> AsyncThrowingStream<ActionStatus, Error> {
        let (launchPath, arguments) = shellCommandForAction(source)
        let sizePath = sizePathForAction(source)
        return AsyncThrowingStream { continuation in
            Task {
                logger.info("action at \(launchPath) with arguments \(arguments) started")
                continuation.yield(.running(progress: 0, bytesFreed: 0))
                let sizeBefore = sizePath.map(sizeOfItem(atPath:)) ?? 0
                let task = Process()
                task.launchPath = launchPath
                task.arguments = arguments
                continuation.yield(.running(progress: 10, bytesFreed: 0))
                let pipe = Pipe()
                task.standardOutput = pipe
                task.standardError = pipe
                do {
                    try task.run()
                } catch {
                    logger.info("action at \(launchPath) with arguments \(arguments) failed to launch")
                    continuation.yield(.failed(reason: error.localizedDescription))
                    continuation.finish()
                    return
                }
                continuation.yield(.running(progress: 20, bytesFreed: 0))
                // Drain the pipe before waiting on exit: reading blocks until the
                // child closes stdout/stderr, so this can't deadlock on a full pipe buffer.
                let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
                task.waitUntilExit()
                if task.terminationStatus != 0 {
                    let output = String(data: outputData, encoding: .utf8)?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    let reason = (output?.isEmpty == false ? output! : nil)
                        ?? String(format: LocalizedString("Status.CommandFailed"), task.terminationStatus)
                    logger.info("action at \(launchPath) with arguments \(arguments) exited with status \(task.terminationStatus)")
                    continuation.yield(.failed(reason: reason))
                    continuation.finish()
                    return
                }
                let sizeAfter = sizePath.map(sizeOfItem(atPath:)) ?? 0
                let freed = max(0, sizeBefore - sizeAfter)
                continuation.yield(.completed(bytesFreed: freed))
                continuation.finish()
                logger.info("action at \(launchPath) with arguments \(arguments) finished, freed \(freed) bytes")
            }
        }
    }

    private func sizePathForAction(_ source: Source.Shell) -> String? {
        switch source {
        case .removeOldSimulators, .removeSimulatorsData:
            return "/Users/\(NSUserName())/Library/Developer/CoreSimulator/Devices"
        case .removeSimulatorPreviews:
            return "/Users/\(NSUserName())/Library/Developer/CoreSimulator/Caches"
        case .removeCocoaPodsCache:
            return "/Users/\(NSUserName())/Library/Caches/CocoaPods"
        case .clearTrash:
            return "/Users/\(NSUserName())/.Trash"
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
                var totalFreed: Int64 = 0
                let onComplete: ((Int64) -> Void) = { freed in
                    completed += 1
                    totalFreed += freed
                    let overall = Double(completed) / Double(total) * 100
                    continuation.yield(.running(progress: overall, bytesFreed: totalFreed))
                }

                for performer in allActions {
                    do {
                        for try await status in performer.perform() {
                            switch status {
                            case .completed(let freed):
                                onComplete(freed)
                            case .failed:
                                onComplete(0)
                            default:
                                break
                            }
                        }
                    }
                    catch {
                        onComplete(0)
                    }
                }
                continuation.yield(.completed(bytesFreed: totalFreed))
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
