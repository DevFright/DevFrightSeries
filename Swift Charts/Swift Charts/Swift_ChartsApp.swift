//
//  Swift_ChartsApp.swift
//  Swift Charts
//
//  Created by Matthew Newill on 02/08/2023.
//

import SwiftUI

@main
struct Swift_ChartsApp: App {
    let healthKitService = HealthKitService()
    let viewModel: StepCountViewModel

    init() {
        viewModel = StepCountViewModel(healthKitService: healthKitService)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
