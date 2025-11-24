import SwiftUI
import Foundation

/**
 * Vista de la presentación de la semana. Contiene el listado de días, navegación semanal y inicia el flujo de navegación.
 */
struct WeekScheduleView: View { // <-- ESTRUCTURA PRINCIPAL AÑADIDA
    @ObservedObject var eventData: EventData
    // Si se pasa un binding de fecha seleccionada desde un calendario lateral, lo usaremos.
    @Binding var selectedDateFromCalendar: Date?
    @Binding var calendarTitle: String
    
    @State private var currentWeekStart: Date = Date.now.startOfWeek
    
    private let daysInWeek = 7
    
    // Helper para obtener los 7 días comenzando desde currentWeekStart
    var weekDays: [Date] {
        (0..<daysInWeek).map { currentWeekStart.addDays($0) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Week Navigation
                HStack {
                    Button {
                        currentWeekStart = currentWeekStart.addDays(-7)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Text(weekLabel)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    Button {
                        currentWeekStart = currentWeekStart.addDays(7)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)
                
                AllDayEventsSection(eventData: eventData, weekDays: weekDays)
                // Weekly Schedule Body
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(weekDays, id: \.self) { day in
                        DayScheduleSection(
                            day: day,
                            events: eventData.eventsOn(date: day)
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
            .onChange(of: selectedDateFromCalendar) { newDate in
                if let d = newDate {
                    currentWeekStart = d.startOfWeek
                }
            }
        }
    }
    
    var weekLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: currentWeekStart)
        let end = formatter.string(from: currentWeekStart.addDays(6))
        return "\(start) - \(end)"
    }
}

// Vista de la fila de un evento individual en el horario
struct EventScheduleRow: View {
    let event: Event
    
    var body: some View {
        HStack(alignment: .top) {
            // Columna de la Hora (Muestra la hora y minutos)
            Text(event.date, style: .time)
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 50, alignment: .leading)
                .foregroundColor(.secondary)
            
            // Detalles del Evento
            VStack(alignment: .leading) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(Color(event.color))
                HStack(spacing: 8) {
                    /*Text("⏱ \(event.durationMinutes)m")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("-")
                        .font(.caption2)
                        .foregroundColor(.secondary)*/
                    Text(event.endDate, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                // Muestra el número de tareas pendientes
                if event.remainingTaskCount > 0 {
                    Text("\(event.remainingTaskCount) tasks remaining")
                        .font(.caption)
                        .foregroundColor(.gray)
                } else if event.isComplete {
                    Text("Completed!")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(5)
            .background(Color(event.color).opacity(0.1))
            .cornerRadius(5)
        }
    }
}

// Vista auxiliar para mostrar el marcador de hora (ej: 10:00)
struct HourMarker: View {
    let hour: Int
    
    var hourString: String {
        // Formato simple 24h
        return String(format: "%02d:00", hour)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(hourString)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.top, 8)
            
            //Divider() // Línea divisoria para el horario
            Rectangle()
                .fill(Color.secondary.opacity(0.25))
                .frame(height: 0)
                .frame(maxWidth: .infinity)
        }
    }
}


// Vista de sección para cada día de la semana (AHORA AGRUPADO POR HORAS)
struct DayScheduleSection: View {
    let day: Date
    let events: [Event]
    
    // Rango de horas a mostrar en el horario (de 8:00 a 22:00)
    //private let scheduleHours = Array(8...22)
    private let firstHour = 6
    private let lastHour = 23
    private let hourHeight: CGFloat = 60
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cabecera del día (ej: Monday, November 17)
            Text(day, style: .date)
                .font(.title3)
                .fontWeight(.bold)
            
            ZStack(alignment: .topLeading) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: 0) {
                        ForEach(firstHour...lastHour, id: \.self) { hour in
                            HourMarker(hour: hour)
                                .frame(height: hourHeight)
                        }
                    }
                    .frame(width: 70)
                    
                    GeometryReader { geo in
                        let totalHours = CGFloat(lastHour - firstHour + 1)
                        let totalHeight = totalHours * hourHeight
                        
                        ZStack(alignment: .topLeading) {
                            VStack(spacing: 0) {
                                ForEach(0..<Int(totalHours), id: \.self){ _ in
                                    ZStack(alignment: .top) {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: hourHeight)

                                            Rectangle()
                                                .fill(Color.secondary.opacity(0.25))
                                                .frame(height: 0.5)
                                                .frame(maxWidth: .infinity, alignment: .top)
                                    }
                                }
                            }
                            .frame(height: totalHeight)
                            .allowsHitTesting(false)
                            
                            ForEach(events) { event in
                                let startComponents = Calendar.current.dateComponents([.hour, .minute], from: event.date)
                                let startHour = (startComponents.hour ?? 0)
                                let startMinute = (startComponents.minute ?? 0)
                                let offsetHours = CGFloat(startHour - firstHour) +  CGFloat(startMinute)/60.0
                                let y = offsetHours * hourHeight
                                let height = max(30,  CGFloat(event.durationMinutes) / 60.0 * hourHeight)
                                
                                NavigationLink(value: event) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(event.title)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("\(event.date, style: .time) - \(event.endDate, style: .time)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color(event.color).opacity(0.3)))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(event.color), lineWidth: 1))
                                    
                                }
                                .buttonStyle(.plain)
                                .frame(width: geo.size.width - 4, height: height, alignment: .topLeading)
                                .offset(x: 8, y: y)
                            }
                        }
                        .frame(height: totalHeight)
                    }
                }
            }
            .padding(.vertical, 4)
             
        }
    }
}

struct AllDayEventsSection: View {
    @ObservedObject var eventData: EventData
    let weekDays: [Date]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("All-day")
                .font(.subheadline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(weekDays, id: \.self) { day in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(shortDayLabel(for: day))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            let dayEvents = eventData.eventsOn(date: day).filter { $0.isAllDay }
                            if dayEvents.isEmpty {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 10)
                            } else {
                                ForEach(dayEvents) { event in
                                    NavigationLink(value: event) {
                                        Text(event.title)
                                            .font(.caption2)
                                            .lineLimit(1)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 8)
                                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(event.color).opacity(0.3)))
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                        .frame(minWidth: 110, alignment: .leading)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 6)
    }
    
    private func shortDayLabel(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEE d"
        return fmt.string(from: date)
    }
}
