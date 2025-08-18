//
//  Action.swift
//  DevCleaner
//
//  Created by Lewis on 13.08.2025.
//

import Foundation

struct Action {
    let source: Source
}

struct ActionModel: Identifiable {
    let id = UUID()
    let action: Action
    let name: String
    var divider: Bool = false
}

struct ActionsFactory {

    func create() -> [ActionModel] {
        [
            .init(
                action: .init(source: .folder(.clearDerivedData)),
                name: LocalizedString("Action.DerivedData")
            ),
            .init(
                action: .init(source: .folder(.clearArchives)),
                name: LocalizedString("Action.Archives")
            ),
            .init(
                action: .init(source: .folder(.clearIOSDeviceSupport)),
                name: LocalizedString("Action.Device.iOS")
            ),
            .init(
                action: .init(source: .folder(.clearWatchOSDeviceSupport)),
                name: LocalizedString("Action.Device.watchOS")
            ),
            .init(
                action: .init(source: .folder(.clearTVOSDeviceSupport)),
                name: LocalizedString("Action.Device.tvOS")
            ),
            .init(
                action: .init(source: .folder(.clearXcodeCaches)),
                name: LocalizedString("Action.XcodeCaches")
            ),
            .init(
                action: .init(source: .folder(.clearCaches)),
                name: LocalizedString("Action.Caches")
            ),
            .init(
                action: .init(source: .shell(.removeOldSimulators)),
                name: LocalizedString("Action.OldSimulators")
            ),
            .init(
                action: .init(source: .shell(.removeSimulatorPreviews)),
                name: LocalizedString("Action.SimulatorPreviews")
            ),
            .init(
                action: .init(source: .shell(.removeSimulatorsData)),
                name: LocalizedString("Action.SimulatorData")
            ),
            .init(
                action: .init(source: .shell(.removeCocoaPodsCache)),
                name: LocalizedString("Action.CocoaPods")
            ),
            .init(
                action: .init(source: .shell(.clearTrash)),
                name: LocalizedString("Action.Trash"),
                divider: true
            ),
            .init(
                action: .init(source: .other(.clearAll)),
                name: LocalizedString("Action.ClearAll"),
                divider: true
            ),
            .init(
                action: .init(source: .other(.quit)),
                name: LocalizedString("Action.Quit")
            )
        ]
    }
}
