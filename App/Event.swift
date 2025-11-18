import SwiftUI
import Foundation

// Creamos una clasificación para los subtipos de los eventos
enum EventType: String, CaseIterable, Codable, Hashable, Identifiable {
    case general = "General"
    case classSchedule = "Horario de Clase"
    case exam = "Examen / Prueba"
    case taskDelivery = "Entrega de Tarea"
    
    var id: String { 
        return self.rawValue 
    }
    
    var symbol: String {
        switch self {
        case .general: return "calendar.badge.exclamationmark"
        case .classSchedule: return "books.vertical.fill"
        case .exam: return "graduationcap.fill"
        case .taskDelivery: return "paperclip"
        }
    }
}

// Definimos una estructura para el patrón de repetición de tareas
struct EventRepetition: Codable, Hashable { 
    var isRepeating: Bool = false
    // El set de número de dia de la semana (1=Dom, 7=Sab)
    var repeatDays: Set<Int> = []
    var repetitionEndDate: Date? = nil
}

struct Event: Identifiable, Hashable, Codable { 
    var id = UUID()
    // NOTA: Asumo que RGBAColor tiene un inicializador con r, g, b, a
    var symbol: String = "calendar" 
    var color: RGBAColor = RGBAColor(r: 0.2, g: 0.4, b: 0.8, a: 1.0)
    var title: String = "Nuevo Evento"
    var tasks: [EventTask] = []
    var date: Date = Date()
    
    var eventType: EventType = .general
    var repetition: EventRepetition = EventRepetition()
    
    // Propiedades computadas existentes
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
    
    var startOfDay: Date { 
        return Calendar.current.startOfDay(for: self)
    }
    
    var startOfMonth: Date? {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components)
    }
    
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components)!
    }
    
    func addDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
}
