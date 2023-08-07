//
//  StepsViewModel.swift
//  Swift Charts
//
//  Created by Matthew Newill on 04/08/2023.
//

import Foundation

class StepCountViewModel: ObservableObject {
    @Published var stepData: [StepData] = []
    private var healthKitService: HealthKitService

    init(healthKitService: HealthKitService) {
        self.healthKitService = healthKitService
    }
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        healthKitService.requestAuthorization(completion: completion)
    }

    func fetchStepData(for period: StepDataPeriod) {
        switch period {
        case .today:
            healthKitService.getStepsByHourToday { [weak self] data in
                self?.updateStepData(data)
            }
        case .month:
            healthKitService.getStepsByDayForMonth { [weak self] data in
                self?.updateStepData(data)
            }
        }
    }
    
    private func updateStepData(_ data: [StepData]) {
        DispatchQueue.main.async {
            self.stepData = data
        }
    }
}
