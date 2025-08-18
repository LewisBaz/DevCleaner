//
//  Source.swift
//  DevCleaner
//
//  Created by Lewis on 13.08.2025.
//

import Foundation

enum Source {
    case folder(Folder)
    case shell(Shell)
    case other(Other)

    enum Folder: CaseIterable {
        case clearDerivedData
        case clearXcodeCaches
        case clearArchives
        case clearIOSDeviceSupport
        case clearWatchOSDeviceSupport
        case clearTVOSDeviceSupport
        case clearCaches
    }

    enum Shell: CaseIterable {
        case removeOldSimulators
        case removeSimulatorPreviews
        case removeSimulatorsData
        case removeCocoaPodsCache
        case clearTrash
    }

    enum Other {
        case clearAll
        case quit
    }
}
