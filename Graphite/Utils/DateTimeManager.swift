//
//  DateTimeManager.swift
//  Graphite
//
//  Created by Martin Lasek on 9/11/22.
//

import Foundation

struct DateTimeManager {
    static func currentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return "\(hour):\(minutes)"
    }
}
