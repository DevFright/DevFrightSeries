//
//  ContentView.swift
//  Swift Charts
//
//  Created by Matthew Newill on 02/08/2023.
//

import SwiftUI
import Charts
import Foundation

struct ContentView: View {
    @ObservedObject var viewModel: StepCountViewModel
    
    var body: some View {
        VStack {
            Button("Request HealthKit Access") {
                viewModel.requestAuthorization { success, error in
                    if success {
                        viewModel.fetchStepData(for: .today)
                    } else {
                        // Handle it!!!!...
                    }
                }
            }
            Chart {
                ForEach(viewModel.stepData, id: \.date) {
                    BarMark(
                        x: .value("Date", $0.date),
                        y: .value("Steps", $0.count)
                    )
                    .foregroundStyle(by: .value("Steps", $0.count))
                }
                .alignsMarkStylesWithPlotArea()
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .onAppear {
                viewModel.fetchStepData(for: .today)
            }
            HStack {
                Button("Today") {
                    viewModel.requestAuthorization { success, error in
                        viewModel.fetchStepData(for: .today)
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("This Month") {
                    viewModel.requestAuthorization { success, error in
                        viewModel.fetchStepData(for: .month)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView(viewModel: StepCountViewModel(healthKitService: HealthKitService()))
        }
    }
    
}
