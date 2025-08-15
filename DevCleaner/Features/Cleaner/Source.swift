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

    enum Folder {
        case clearDerivedData
        case clearXcodeCaches
        case clearArchives
        case clearIOSDeviceSupport
        case clearWatchOSDeviceSupport
        case clearTVOSDeviceSupport
        case clearCaches
    }

    enum Shell {
        case removeOldSimulators
        case removeSimulatorPreviews
        case removeSimulatorsData
        case removeCocoaPodsCache
        case clearTrash
    }
}
