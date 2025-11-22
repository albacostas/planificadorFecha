import SwiftUI
import CoreData
import Combine

class EventData: ObservableObject {
    // Optional Core Data context. If provided, persistence happens in Core Data using background contexts.
    private var moc: NSManagedObjectContext?

    init(context: NSManagedObjectContext? = nil) {
        self.moc = context
        if context != nil {
            loadFromCoreData()
        }
    }
    @Published var allEvents: [Event] = [
        Event(symbol: "gift.fill",
              color: Color.red.rgbaColor,
              title: "Maya's Birthday",
              tasks: [EventTask(text: "Guava kombucha"),
                      EventTask(text: "Paper cups and plates"),
                      EventTask(text: "Cheese plate"),
                      EventTask(text: "Party poppers"),
                     ],
              date: Date.roundedHoursFromNow(60 * 60 * 24 * 30)),
        Event(symbol: "theatermasks.fill",
              color: Color.yellow.rgbaColor,
              title: "Pagliacci",
              tasks: [EventTask(text: "Buy new tux"),
                      EventTask(text: "Get tickets"),
                      EventTask(text: "Book a flight for Carmen"),
                     ],
              date: Date.roundedHoursFromNow(60 * 60 * 22)),
        Event(symbol: "heart.text.square.fill",
              color: Color.indigo.rgbaColor,
              title: "Health Check-up",
              tasks: [EventTask(text: "Bring medical ID"),
                      EventTask(text: "Record heart rate data"),
                     ],
              date: Date.roundedHoursFromNow(60 * 60 * 24 * 4)),
        Event(symbol: "leaf.fill",
              color: Color.green.rgbaColor,
              title: "Camping Trip",
              tasks: [EventTask(text: "Find a sleeping bag"),
                      EventTask(text: "Bug spray"),
                      EventTask(text: "Paper towels"),
                      EventTask(text: "Food for 4 meals"),
                      EventTask(text: "Straw hat"),
                     ],
              date: Date.roundedHoursFromNow(60 * 60 * 36)),
        Event(symbol: "gamecontroller.fill",
              color: Color.cyan.rgbaColor,
              title: "Game Night",
              tasks: [EventTask(text: "Find a board game to bring"),
                      EventTask(text: "Bring a dessert to share"),
                     ],
              date: Date.roundedHoursFromNow(60 * 60 * 24 * 2)),
        Event(symbol: "graduationcap.fill",
              color: Color.primary.rgbaColor,
              title: "First Day of School",
              tasks: [
                EventTask(text: "Notebooks"),
                EventTask(text: "Pencils"),
                EventTask(text: "Binder"),
                EventTask(text: "First day of school outfit"),
              ],
              date: Date.roundedHoursFromNow(60 * 60 * 24 * 365)),
        Event(symbol: "book.fill",
              color: Color.purple.rgbaColor,
              title: "Book Launch",
              tasks: [
                EventTask(text: "Finish first draft"),
                EventTask(text: "Send draft to editor"),
                EventTask(text: "Final read-through"),
              ],
              date: Date.roundedHoursFromNow(60 * 60 * 24 * 365 * 2)),
        Event(symbol: "globe.americas.fill",
              color: Color.gray.rgbaColor,
              title: "WWDC",
              tasks: [
                EventTask(text: "Watch Keynote"),
                EventTask(text: "Watch What's new in SwiftUI"),
                EventTask(text: "Go to DT developer labs"),
                EventTask(text: "Learn about Create ML"),
              ],
              date: Date.from(month: 6, day: 7, year: 2021)),
        Event(symbol: "case.fill",
              color: Color.orange.rgbaColor,
              title: "Sayulita Trip",
              tasks: [
                EventTask(text: "Buy plane tickets"),
                EventTask(text: "Get a new bathing suit"),
                EventTask(text: "Find a hotel room"),
              ],
              date: Date.roundedHoursFromNow(60 * 60 * 24 * 19)),
    ]
    // New: support for subcalendars (subjects)
    @Published var calendars: [Subcalendar] = [
        Subcalendar(title: "Computación Distribuida", color: Color.blue.rgbaColor),
        Subcalendar(title: "Matemáticas", color: Color.green.rgbaColor),
    ]
    
    // UI state shared across views: selected date in the calendar, the title shown and visibility
    @Published var uiSelectedDate: Date? = Date.now.startOfDay
    @Published var uiCalendarTitle: String = "Date Planner"
    @Published var isCalendarVisible: Bool = true
    
    // Calendar management helpers
    func addCalendar(_ calendar: Subcalendar) {
        calendars.append(calendar)
        // Persist calendars if using Core Data
        if moc != nil {
            save()
        }
    }
    
    func removeCalendar(_ calendar: Subcalendar) {
        calendars.removeAll { $0.id == calendar.id }
        if moc != nil {
            save()
        }
    }
    
    func updateEventsColor(for calendarID: UUID, to newColor: RGBAColor) {
        if let idx = calendars.firstIndex(where: { $0.id == calendarID}) {
            calendars[idx].color = newColor
        }
        
        var didChange = false
        for i in allEvents.indices {
            if let calID = allEvents[i].calendarID, calID == calendarID {
                allEvents[i].color = newColor
                didChange = true
            }
        }
        if didChange || moc != nil {
            save()
        }
    }
    
    func getBindingToCalendar(_ calendar: Subcalendar) -> Binding<Subcalendar>? {
        Binding<Subcalendar>(
            get: {
                guard let index = self.calendars.firstIndex(where: { $0.id == calendar.id }) else { return Subcalendar.example }
                return self.calendars[index]
            },
            set: { updated in
                guard let index = self.calendars.firstIndex(where: { $0.id == updated.id }) else { return }
                self.calendars[index] = updated
            }
        )
    }
    
    func add(_ event: Event) {
        allEvents.append(event)
    }
    
    func remove(_ event: Event) {
        allEvents.removeAll { $0.id == event.id}
    }
    
    // Toggle a task's completion state for a given event and task id.
        // This is used by compact views (occurrences) where we only have a copied `Event`.
    func toggleTask(eventID: UUID, taskID: UUID) {
        guard let eIndex = allEvents.firstIndex(where: { $0.id == eventID }) else { return }
        guard let tIndex = allEvents[eIndex].tasks.firstIndex(where: { $0.id == taskID }) else { return }
            allEvents[eIndex].tasks[tIndex].isCompleted.toggle()
        if moc != nil { save() }
    }
    
    func sortedEvents(period: Period) -> Binding<[Event]> {
        Binding<[Event]>(
            get: {
                self.allEvents
                    .filter { $0.period == period}
                    .sorted { $0.date < $1.date }
            },
            set: { events in
                for event in events {
                    if let index = self.allEvents.firstIndex(where: { $0.id == event.id }) {
                        self.allEvents[index] = event
                    }
                }
            }
        )
    }

    
    func getBindingToEvent(_ event: Event) -> Binding<Event>? {
        Binding<Event>(
            get: {
                guard let index = self.allEvents.firstIndex(where: { $0.id == event.id }) else { return Event.delete }
                return self.allEvents[index]
            },
            set: { event in
                guard let index = self.allEvents.firstIndex(where: { $0.id == event.id }) else { return }
                self.allEvents[index] = event
            }
        )
    }
    func eventsOn(date: Date) -> [Event] {
        // Expand repeated events into occurrences for display
        var result: [Event] = []
        for event in allEvents {
            // If not repeating, check same day
            if event.repeatFrequency == .none {
                if event.date.isSameDay(as: date) {
                    result.append(event)
                }
            } else {
                // generate occurrences up to repeatEndDate (or a reasonable horizon)
                let occurrences = occurrencesFor(event: event, on: date)
                result.append(contentsOf: occurrences)
            }
        }
        return result.sorted { $0.date < $1.date }
    }
    
    func eventsForWeek(starting startOfWeek: Date) -> [Event] {
        let endOfWeek = startOfWeek.addDays(7)
        // Filtramos los eventos, queremos solo los que esa semana.
        var result: [Event] = []
        for event in allEvents {
            if event.repeatFrequency == .none {
                if event.date >= startOfWeek.startOfDay! && event.date < endOfWeek.startOfWeek {
                    result.append(event)
                }
            } else {
                // generate occurrences within the week
                var day = startOfWeek
                while day < endOfWeek {
                    let occ = occurrencesFor(event: event, on: day)
                    result.append(contentsOf: occ)
                    day = day.addDays(1)
                }
            }
        }
        return result.sorted { $0.date < $1.date }
    }
    
    // Generate occurrence(s) of a repeating event for a specific date.
    private func occurrencesFor(event: Event, on date: Date) -> [Event] {
        guard event.repeatFrequency != .none else { return [] }
        // If repeatEndDate specified and date beyond it, no occurrence
        if let end = event.repeatEndDate, date > end { return [] }
        
        let calendar = Calendar.current
        switch event.repeatFrequency {
        case .daily:
            // If the event date's time-of-day should be preserved
            if calendar.isDate(event.date, equalTo: date, toGranularity: .day) || true {
                let baseComponents = calendar.dateComponents([.hour, .minute, .second], from: event.date)
                if let occDate = calendar.date(bySettingHour: baseComponents.hour ?? 0, minute: baseComponents.minute ?? 0, second: baseComponents.second ?? 0, of: date) {
                    return [makeOccurrence(from: event, date: occDate)]
                }
            }
        case .weekly:
            let weekdayOfOriginal = calendar.component(.weekday, from: event.date)
            let weekdayOfTarget = calendar.component(.weekday, from: date)
            if weekdayOfOriginal == weekdayOfTarget {
                let baseComponents = calendar.dateComponents([.hour, .minute, .second], from: event.date)
                if let occDate = calendar.date(bySettingHour: baseComponents.hour ?? 0, minute: baseComponents.minute ?? 0, second: baseComponents.second ?? 0, of: date) {
                    return [makeOccurrence(from: event, date: occDate)]
                }
            }
        case .monthly:
            let dayOfMonthOriginal = calendar.component(.day, from: event.date)
            let dayOfMonthTarget = calendar.component(.day, from: date)
            if dayOfMonthOriginal == dayOfMonthTarget {
                let baseComponents = calendar.dateComponents([.hour, .minute, .second], from: event.date)
                if let occDate = calendar.date(bySettingHour: baseComponents.hour ?? 0, minute: baseComponents.minute ?? 0, second: baseComponents.second ?? 0, of: date) {
                    return [makeOccurrence(from: event, date: occDate)]
                }
            }
        default:
            break
        }
        return []
    }
    
    // Create a shallow copy of event with modified date to represent an occurrence
    private func makeOccurrence(from event: Event, date: Date) -> Event {
        var occ = event
        // Keep the original event id so edits map back to the source event
        occ.id = event.id
        occ.date = date
        return occ
    }
   
    private static func getEventsFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("events.data")
    }
   
    func load() {
        // Backwards-compatible loader; prefer Core Data if available
        if moc != nil {
            loadFromCoreData()
            return
        }

        do {
            let fileURL = try EventData.getEventsFileURL()
            let data = try Data(contentsOf: fileURL)
            allEvents = try JSONDecoder().decode([Event].self, from: data)
                        print("Events loaded from file: \(allEvents.count)")
        } catch {
            print("Failed to load from file. Using embedded backup data")
        }
    }
    
    
    func save() {
        // Prefer Core Data persistence when a context is available
        if let moc = self.moc {
            saveToCoreData(in: moc)
            return
        }

        do {
            let fileURL = try EventData.getEventsFileURL()
            let data = try JSONEncoder().encode(allEvents)
                        try data.write(to: fileURL, options: .atomic)
            print("Events saved to file")
        } catch {
            print("Unable to save to file: \(error)")
        }
    }

    // Core Data integration
    private func loadFromCoreData() {
        guard let moc = self.moc else { return }
        let request = NSFetchRequest<NSManagedObject>(entityName: "CDEvent")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        moc.perform {
            do {
                let results = try moc.fetch(request)
                var loaded: [Event] = []
                let decoder = JSONDecoder()
                for obj in results {
                    guard let id = obj.value(forKey: "id") as? UUID,
                          let date = obj.value(forKey: "date") as? Date else { continue }
                    let symbol = obj.value(forKey: "symbol") as? String ?? EventSymbols.randomName()
                    let title = obj.value(forKey: "title") as? String ?? ""
                    let calendarID = obj.value(forKey: "calendarID") as? UUID
                    let subtypeRaw = obj.value(forKey: "subtype") as? String ?? EventSubtype.task.rawValue
                    let repeatFrequencyRaw = obj.value(forKey: "repeatFrequency") as? String ?? RepeatFrequency.none.rawValue
                    let repeatEnd = obj.value(forKey: "repeatEndDate") as? Date

                    // decode tasks
                    var tasks: [EventTask] = [EventTask(text: "")]
                    if let tasksData = obj.value(forKey: "tasksData") as? Data {
                        if let decoded = try? decoder.decode([EventTask].self, from: tasksData) {
                            tasks = decoded
                        }
                    }

                    // decode color
                    var color = ColorOptions.random().rgbaColor
                    if let colorData = obj.value(forKey: "colorData") as? Data {
                        if let decoded = try? decoder.decode(RGBAColor.self, from: colorData) {
                            color = decoded
                        }
                    }

                    var ev = Event(symbol: symbol, color: color, title: title, tasks: tasks, date: date)
                    ev.id = id
                    ev.calendarID = calendarID
                    ev.subtype = EventSubtype(rawValue: subtypeRaw) ?? .task
                    ev.repeatFrequency = RepeatFrequency(rawValue: repeatFrequencyRaw) ?? .none
                    ev.repeatEndDate = repeatEnd
                    loaded.append(ev)
                }
                DispatchQueue.main.async {
                    self.allEvents = loaded
                    print("Events loaded from Core Data: \(loaded.count)")
                }
            } catch {
                print("Failed to fetch from Core Data: \(error)")
            }
        }
        // Load subcalendars
        let subReq = NSFetchRequest<NSManagedObject>(entityName: "CDSubcalendar")
        subReq.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        moc.perform {
            do {
                let results = try moc.fetch(subReq)
                var loadedSubs: [Subcalendar] = []
                let decoder = JSONDecoder()
                for obj in results {
                    guard let id = obj.value(forKey: "id") as? UUID,
                          let title = obj.value(forKey: "title") as? String,
                          let isVisible = obj.value(forKey: "isVisible") as? Bool else { continue }

                    var color = ColorOptions.random().rgbaColor
                    if let colorData = obj.value(forKey: "colorData") as? Data {
                        if let decoded = try? decoder.decode(RGBAColor.self, from: colorData) {
                            color = decoded
                        }
                    }

                    let sub = Subcalendar(id: id, title: title, color: color, isVisible: isVisible)
                    loadedSubs.append(sub)
                }
                DispatchQueue.main.async {
                    if !loadedSubs.isEmpty {
                        self.calendars = loadedSubs
                    }
                    print("Subcalendars loaded from Core Data: \(loadedSubs.count)")
                }
            } catch {
                print("Failed to fetch subcalendars: \(error)")
            }
        }
    }

    private func saveToCoreData(in viewContext: NSManagedObjectContext) {
        // Save using a background context to avoid blocking UI
        let bg = PersistenceController.shared.newBackgroundContext()
        bg.perform {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CDEvent")
            let batchDelete = NSBatchDeleteRequest(fetchRequest: fetch)
            do {
                _ = try bg.execute(batchDelete)
            } catch {
                print("Failed to clear old CDEvent objects: \(error)")
            }

            let encoder = JSONEncoder()
                for event in self.allEvents {
                guard let entity = NSEntityDescription.entity(forEntityName: "CDEvent", in: bg) else { continue }
                let obj = NSManagedObject(entity: entity, insertInto: bg)
                obj.setValue(event.id, forKey: "id")
                obj.setValue(event.symbol, forKey: "symbol")
                obj.setValue(event.title, forKey: "title")
                obj.setValue(event.date, forKey: "date")
                obj.setValue(event.calendarID, forKey: "calendarID")
                obj.setValue(event.subtype.rawValue, forKey: "subtype")
                obj.setValue(event.repeatFrequency.rawValue, forKey: "repeatFrequency")
                obj.setValue(event.repeatEndDate, forKey: "repeatEndDate")
                if let tasksData = try? encoder.encode(event.tasks) {
                    obj.setValue(tasksData, forKey: "tasksData")
                }
                if let colorData = try? encoder.encode(event.color) {
                    obj.setValue(colorData, forKey: "colorData")
                }
            }

            do {
                try bg.save()
                print("Events saved to Core Data: \(self.allEvents.count)")
            } catch {
                print("Failed to save to Core Data: \(error)")
            }
        }
        // Also save subcalendars
        let bg2 = PersistenceController.shared.newBackgroundContext()
        bg2.perform {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "CDSubcalendar")
            let batchDelete = NSBatchDeleteRequest(fetchRequest: fetch)
            do {
                _ = try bg2.execute(batchDelete)
            } catch {
                print("Failed to clear old CDSubcalendar objects: \(error)")
            }

            let encoder = JSONEncoder()
            for sub in self.calendars {
                guard let entity = NSEntityDescription.entity(forEntityName: "CDSubcalendar", in: bg2) else { continue }
                let obj = NSManagedObject(entity: entity, insertInto: bg2)
                obj.setValue(sub.id, forKey: "id")
                obj.setValue(sub.title, forKey: "title")
                obj.setValue(sub.isVisible, forKey: "isVisible")
                if let colorData = try? encoder.encode(sub.color) {
                    obj.setValue(colorData, forKey: "colorData")
                }
            }

            do {
                try bg2.save()
                print("Subcalendars saved to Core Data: \(self.calendars.count)")
            } catch {
                print("Failed to save subcalendars to Core Data: \(error)")
            }
        }
    }
}

enum Period: String, CaseIterable, Identifiable {
    case nextSevenDays = "Next 7 Days"
    case nextThirtyDays = "Next 30 Days"
    case future = "Future"
    case past = "Past"
    
    var id: String { self.rawValue }
    var name: String { self.rawValue }
}

extension Date {
    static func from(month: Int, day: Int, year: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        
        let calendar = Calendar(identifier: .gregorian)
        if let date = calendar.date(from: dateComponents) {
            return date
        } else {
            return Date.now
        }
    }
    
    static func roundedHoursFromNow(_ hours: Double) -> Date {
        let exactDate = Date(timeIntervalSinceNow: hours)
        guard let hourRange = Calendar.current.dateInterval(of: .hour, for: exactDate) else {
            return exactDate
        }
        return hourRange.end
    }
}

