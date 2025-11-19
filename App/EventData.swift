import SwiftUI
//#-learning-task(eventData)

/*#-code-walkthrough(4.eventData)*/
class EventData: ObservableObject {
    /*#-code-walkthrough(4.eventData)*/
    /*#-code-walkthrough(4.events)*/
    @Published var events: [Event] = [
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
    }
    
    func removeCalendar(_ calendar: Subcalendar) {
        calendars.removeAll { $0.id == calendar.id }
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
    /*#-code-walkthrough(4.events)*/
    
    func add(_ event: Event) {
        events.append(event)
    }
    
    func remove(_ event: Event) {
        events.removeAll { $0.id == event.id}
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
    /*#-code-walkthrough(4.methods)*/
    
    func getBindingToEvent(_ event: Event) -> Binding<Event>? {
        Binding<Event>(
            get: {
                guard let index = self.events.firstIndex(where: { $0.id == event.id }) else { return Event.delete }
                return self.events[index]
            },
            set: { event in
                guard let index = self.events.firstIndex(where: { $0.id == event.id }) else { return }
                self.events[index] = event
            }
        )
    }
    func events(for date: Date) -> [Event] {
        // Expand repeated events into occurrences for display
        var result: [Event] = []
        for event in events {
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
    
    func events(forWeekStarting startOfWeek: Date) -> [Event] {
        let endOfWeek = startOfWeek.addDays(7)
        // Filtramos los eventos, queremos solo los que esa semana.
        var result: [Event] = []
        for event in events {
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
    /*#-code-walkthrough(7.fileURL)*/
    private static func getEventsFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("events.data")
    }
    /*#-code-walkthrough(7.fileURL)*/
    //#-learning-task(loadFunc)
    func load() {
        do {
            /*#-code-walkthrough(7.loadfileURL)*/
            let fileURL = try EventData.getEventsFileURL()
            /*#-code-walkthrough(7.loadfileURL)*/
            /*#-code-walkthrough(7.loadData)*/
            let data = try Data(contentsOf: fileURL)
            /*#-code-walkthrough(7.loadData)*/
            /*#-code-walkthrough(7.loadDataDecode)*/
            events = try JSONDecoder().decode([Event].self, from: data)
            /*#-code-walkthrough(7.loadDataDecode)*/
            print("Events loaded: \(events.count)")
        } catch {
            /*#-code-walkthrough(7.loadFail)*/
            print("Failed to load from file. Backup data used")
            /*#-code-walkthrough(7.loadFail)*/
        }
    }
    
    //#-learning-task(saveFunc)
    func save() {
        do {
            let fileURL = try EventData.getEventsFileURL()
            /*#-code-walkthrough(8.saveEncode)*/
            let data = try JSONEncoder().encode(events)
            /*#-code-walkthrough(8.saveEncode)*/
            /*#-code-walkthrough(8.saveWrite)*/
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
            /*#-code-walkthrough(8.saveWrite)*/
            print("Events saved")
        } catch {
            /*#-code-walkthrough(8.saveFail)*/
            print("Unable to save")
            /*#-code-walkthrough(8.saveFail)*/
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

