import SwiftUI

struct Event: Identifiable, Hashable, Codable {
    
    var id = UUID()
    var symbol: String = EventSymbols.randomName()
    var color: RGBAColor = ColorOptions.random().rgbaColor
    var title = ""
    var tasks = [EventTask(text: "")]
    var date = Date.now
    
    var calendarID: UUID?
    var subtype: EventSubtype = .task
    var repeatFrequency: RepeatFrequency = .none
    var repeatEndDate: Date? = nil
    var durationMinutes: Int = 60
    var period: Period {
        if date < Date.now{
            return .past
            
        } else if date < Date.now.sevenDaysOut {
            return .nextSevenDays
            
        } else if date < Date.now.thirtyDaysOut {
            return .nextThirtyDays
            
        } else {
            return .future
        }
    }
    
    var remainingTaskCount: Int {
        tasks.filter { !$0.isCompleted && !$0.text.isEmpty }.count
    }
    
    var isComplete: Bool {
        tasks.allSatisfy { $0.isCompleted || $0.text.isEmpty }
    }
    
    var endDate: Date {
        return date.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }
    static var example = Event(
        symbol: "case.fill",
        title: "Sayulita Trip",
        tasks: [
            EventTask(text: "Buy plane tickets"),
            EventTask(text: "Get a new bathing suit"),
            EventTask(text: "Find an airbnb"),
        ],
        date: Date(timeIntervalSinceNow: 60 * 60 * 24 * 365 * 1.5))
    
    static var delete = Event(symbol: "trash")
}

// Subtypes for events so they can be classified inside a subcalendar
enum EventSubtype: String, CaseIterable, Identifiable, Codable {
    case task = "Task"
    case exam = "Exam"
    case classSession = "Class"
    case other = "Other"
    
    var id: String { self.rawValue }
}

// Simple repetition frequency enum
enum RepeatFrequency: String, CaseIterable, Identifiable, Codable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    
    var id: String { self.rawValue }
}

// Convenience methods for dates.
extension Date {
    var sevenDaysOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 7, to: self) ?? self
    }
    
    var thirtyDaysOut: Date {
        Calendar.autoupdatingCurrent.date(byAdding: .day, value: 30, to: self) ?? self
    }
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
    
    var startOfDay: Date? {
        Calendar.current.startOfDay(for: self)
    }
    var startOfMonth: Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        // Obtenemos el año y la semana del año
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        // Devolvemos la fecha
        return calendar.date(from: components)!
    }
    
    func addDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}

