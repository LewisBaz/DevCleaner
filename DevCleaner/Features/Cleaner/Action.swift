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
                action: .init(source: .shell(.cleanBin)),
                name: "Clean Trash"
            )
        ]
    }
}
