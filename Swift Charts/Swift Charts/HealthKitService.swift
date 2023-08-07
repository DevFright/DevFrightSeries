//
//  HealthKitService.swift
//  Swift Charts
//
//  Created by Matthew Newill on 04/08/2023.
//

import Foundation
import HealthKit

class HealthKitService {
    let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [HKObjectType.quantityType(forIdentifier: .stepCount)!]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { (success, error) in
            completion(success, error)
        }
    }
    
    func getStepsByHourToday(completion: @escaping ([StepData]) -> Void) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        getSteps(from: startOfDay, to: now, interval: DateComponents(hour: 1), completion: completion)
    }

    func getStepsByDayForMonth(completion: @escaping ([StepData]) -> Void) {
        let now = Date()
        let thirtyDaysBeforeNow = Calendar.current.date(byAdding: .day, value: -30, to: now)!
        getSteps(from: thirtyDaysBeforeNow, to: now, interval: DateComponents(day: 1), completion: completion)
    }
    
    private func getSteps(from startDate: Date, to endDate: Date, interval: DateComponents, completion: @escaping ([StepData]) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            if let error = error {
                print("Error fetching step data: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let results = results else {
                completion([])
                return
            }
            
            var data: [StepData] = []
            results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let count: Double = statistics.sumQuantity()?.doubleValue(for: .count()) ?? 0
                data.append(StepData(date: statistics.startDate, count: Int(count)))
            }
            
            DispatchQueue.main.async {
                completion(data)
            }
        }
        healthStore.execute(query)
    }
    
}
