import SwiftUI

struct CalendarView: View {
    @ObservedObject var eventData: EventData
    // Binding para que EventList.swift pueda reaccionar a la selección de una fecha
    @Binding var selectedDate: Date? 
    // Binding para comunicar el mes y el actual.
    @Binding var currentMonthAndYear: String
    
    @State private var monthOffset: Int = 0
    //private let calendar = Calendar.current
    private var calendar: Calendar = {
        var c = Calendar.current
        c.firstWeekday = 2
        return c
    }()
    
    var currentMonth: Date {
        calendar.date(byAdding: .month, value: monthOffset, to: Date.now.startOfMonth!)!
    }
    
    // Make an explicit initializer so the view can be instantiated from other files
    init(eventData: EventData, selectedDate: Binding<Date?>, currentMonthAndYear: Binding<String>) {
        self.eventData = eventData
        self._selectedDate = selectedDate
        self._currentMonthAndYear = currentMonthAndYear
    }
    
    var monthAndYear: String {
        currentMonth.formatted(.dateTime.month(.wide).year())
    }
    
    var daysInMonth: [Date] {
        guard let startOfMonth = currentMonth.startOfMonth else { return [] }
        
        var dates: [Date] = []
        //let firstWeekday = calendar.component(.weekday, from: startOfMonth) // 1=Sunday, 7=Saturday
        let startWeekday = calendar.component(.weekday, from: startOfMonth) // 1=Sunday, 7=Saturday
        
        // Calculate leading days so the grid starts on `calendar.firstWeekday` (Monday)
        let leadingDays = ((startWeekday - calendar.firstWeekday) + 7) % 7
        //let leadingDays = (firstWeekday + 5) % 7
        for i in 0..<leadingDays {
            if let date = calendar.date(byAdding: .day, value: -leadingDays + i, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        // Add days of the month
        if let range = calendar.range(of: .day, in: .month, for: startOfMonth) {
            for day in range {
                if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                    dates.append(date)
                }
            }
        }
        
        // Add trailing empty days (from next month)
        let totalCells = dates.count
        let trailingDays = 42 - totalCells
        if totalCells < 42, let lastDay = dates.last {
            for day in 1...trailingDays {
                if let date = calendar.date(byAdding: .day, value: day, to: lastDay) {
                    dates.append(date)
                } else {
                    break
                }
            }
        }
        
        return dates
    }
    
    var body: some View {
        VStack {
            // Month Navigation
            HStack {
                Button {
                    monthOffset -= 1
                } label: {
                    Image(systemName: "chevron.left")
                }
                /*
                 Text(monthAndYear)
                 .font(.headline)
                 .frame(maxWidth: .infinity)
                 */
                Spacer() // Añadimos un spacer para empujar los botones a los lados.
                Button {
                    monthOffset += 1
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            
            // Weekday Headers
            Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                GridRow {
                    // Ensure headers start on the calendar's firstWeekday (Monday)
                    let symbols = calendar.shortWeekdaySymbols
                    let start = calendar.firstWeekday - 1
                    let ordered = Array(symbols[start...] + symbols[..<start])
                    ForEach(ordered, id: \.self) { day in
                        Text(day.prefix(1)) // Muestra solo la primera letra
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Day Grid
                ForEach(daysInMonth.chunked(into: 7), id: \.self) { week in
                    GridRow {
                        ForEach(week, id: \.self) { date in
                            dayCell(for: date)
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .onAppear{ // Establecemos el titulo cuando la vista aparece.
            currentMonthAndYear = monthAndYear
        }
        .onChange(of: currentMonth) { _ in 
            currentMonthAndYear = monthAndYear
        }
    }
    
    
    @ViewBuilder
    func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isToday = date.isSameDay(as: Date.now)
        let isSelected = date.isSameDay(as: selectedDate ?? Date.distantFuture)
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        let eventsOnDay = eventData.events(for: date)
        
        // 1. NUEVO: Definir un RGBAColor de fallback seguro (tomado de Event.example.color)
        let defaultEventColor = Event.example.color 
        
        Button {
            selectedDate = date.startOfDay
            
        } label: {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                // 2. CORREGIDO: Usar defaultEventColor (RGBAColor) en la coalescencia.
                    .foregroundColor(isCurrentMonth ? (isToday ? .white : (isSelected ? Color(eventData.events.first?.color ?? defaultEventColor) : .primary)) : .secondary.opacity(0.5))
                
                // Indicador de evento
                if !eventsOnDay.isEmpty {
                    Circle()
                        .frame(width: 5, height: 5)
                        .foregroundColor(Color(eventsOnDay.first!.color))
                } else {
                    Circle()
                        .frame(width: 5, height: 5)
                        .hidden()
                }
            }
            .frame(width: 30, height: 30)
            .background {
                if isToday {
                    Circle().fill(Color.blue)
                } else if isSelected {
                    // 3. CORREGIDO: Usar defaultEventColor (RGBAColor) en la coalescencia.
                    Circle().stroke(Color(eventData.events.first?.color ?? defaultEventColor), lineWidth: 2)
                }
            }
        }
        .disabled(!isCurrentMonth)
        .buttonStyle(.plain)
    }
}

// Utility to create weeks from a flat list of days
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// Used for GridRow ForEach id
extension Array: @retroactive Identifiable where Element: Hashable {
    public var id: Int {
        var hasher = Hasher()
        for element in self {
            hasher.combine(element)
        }
        return hasher.finalize()
    }
}

