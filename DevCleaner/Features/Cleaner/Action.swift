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
                name: "Clear Derived Data"
            ),
            .init(
                action: .init(source: .folder(.clearArchives)),
                name: "Clear Archives"
            ),
            .init(
                action: .init(source: .folder(.clearIOSDeviceSupport)),
                name: "Clear iOS Device Support"
            ),
            .init(
                action: .init(source: .folder(.clearWatchOSDeviceSupport)),
                name: "Clear watchOS Device Support"
            ),
            .init(
                action: .init(source: .folder(.clearTVOSDeviceSupport)),
                name: "Clear tvOS Device Support"
            ),
            .init(
                action: .init(source: .folder(.clearXcodeCaches)),
                name: "Clear Xcode Caches"
            ),
            .init(
                action: .init(source: .folder(.clearCaches)),
                name: "Clear Caches"
            ),
            .init(
                action: .init(source: .shell(.removeOldSimulators)),
                name: "Remove Old Simulators"
            ),
            .init(
                action: .init(source: .shell(.removeSimulatorPreviews)),
                name: "Remove Simulator Previews"
            ),
            .init(
                action: .init(source: .shell(.removeSimulatorsData)),
                name: "Remove Simulators Data"
            ),
            .init(
                action: .init(source: .shell(.removeCocoaPodsCache)),
                name: "Remove Cocoa Pods Cache"
            ),
            .init(
                action: .init(source: .shell(.clearTrash)),
                name: "Clear Trash"
            )
        ]
    }
}
