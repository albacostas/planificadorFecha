import SwiftUI
import Foundation

class EventData: ObservableObject {
    
    @Published var expandedEvents: [Event] = []
    @Published var events: [Event] = []
    
    init() {
        expandRecurringEvents()
    }
    
    private func expandRecurringEvents() {
        var expanded: [Event] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let futureLimit = today.addDays(365 * 2)
        
        for event in events {
            expanded.append(event)
            
            guard event.repetition.isRepeating && !event.repetition.repeatDays.isEmpty else { continue }
            
            var currentDate = event.date.startOfDay
            let endDate = event.repetition.repetitionEndDate ?? futureLimit
            
            while currentDate < endDate && currentDate < futureLimit {
                currentDate = currentDate.addDays(1)
                
                let weekday = calendar.component(.weekday, from: currentDate)
                
                if event.repetition.repeatDays.contains(weekday) {
                    
                    var recurringEvent = event
                    
                    let originalHour = calendar.component(.hour, from: event.date)
                    let originalMinute = calendar.component(.minute, from: event.date)
                    
                    if let newDate = calendar.date(bySettingHour: originalHour, minute: originalMinute, second: 0, of: currentDate) {
                        recurringEvent.date = newDate
                        recurringEvent.id = UUID() 
                        expanded.append(recurringEvent)
                    }
                }
            }
        }
        
        self.expandedEvents = expanded.sorted { $0.date < $1.date }
    }
    
    func add(_ event: Event) {
        events.append(event)
        save()
        expandRecurringEvents()
    }
    
    func remove(_ event: Event) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events.remove(at: index)
        }
        save()
        expandRecurringEvents()
    }
    
    func sortedEvents(period: Period) -> Binding<[Event]> {
        Binding<[Event]>(
            get: {
                self.events
                    .filter { $0.period == period}
                    .sorted { $0.date < $1.date }
            },
            set: { events in
                for event in events {
                    if let index = self.events.firstIndex(where: { $0.id == event.id }) {
                        self.events[index] = event
                    }
                }
            }
        )
    }
    
    func getBindingToEvent(_ event: Event) -> Binding<Event>? {
        guard let index = events.firstIndex(where: { $0.id == event.id}) else { return nil }
        return Binding<Event>(
            get: { self.events[index] },
            set: { newValue in
                if !self.events.indices.contains(index) { return }
                self.events[index] = newValue
                self.save()
                self.expandRecurringEvents()
            }
        )
    }
    
    func events(for date: Date) -> [Event] {
        expandedEvents.filter { $0.date.isSameDay(as: date) }
            .sorted { $0.date < $1.date }
    }
    
    // Esta función no se usa en el flujo final, pero se corrige para evitar errores.
    func events(forWeekStarting startOfWeek: Date) -> [Event] {
        let endOfWeek = startOfWeek.addDays(7)
        // Corregido: startOfDay es una propiedad no opcional
        return expandedEvents.filter{ $0.date >= startOfWeek.startOfDay && $0.date < endOfWeek.startOfDay } 
            .sorted { $0.date < $1.date }
    }
    
    /*#-code-walkthrough(7.fileURL)*/
    private static func getEventsFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("events.data")
    }
    /*#-code-walkthrough(7.fileURL)*/
    
    func load() {
        do {
            let fileURL = try EventData.getEventsFileURL()
            let data = try Data(contentsOf: fileURL)
            let decodedEvents = try JSONDecoder().decode([Event].self, from: data)
            self.events = decodedEvents
            self.expandRecurringEvents()
            print("Events loaded: \(events.count)")
        } catch {
            print("Failed to load from file. Backup data used")
        }
    }
    
    func save() {
        do {
            let fileURL = try EventData.getEventsFileURL()
            let data = try JSONEncoder().encode(events)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            print("Events saved")
        } catch {
            print("Unable to save")
        }
    }
}

enum Period: String, CaseIterable, Identifiable {
    case nextSevenDays = "Next 7 Days"
    case nextThirtyDays = "Next 30 Days"
    case future = "Future"
    case past = "Past"
    
    var id: String { return self.rawValue }
    var name: String { return self.rawValue }
}
