//
//  LoadingView.swift
//  DevCleaner
//
//  Created by Lewis on 14.08.2025.
//

import SwiftUI

struct LoadingView: View {

    @Binding var progress: Double

    var body: some View {
        VStack {
            ProgressView(value: progress, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 200)
        }
        .padding()
    }
}
