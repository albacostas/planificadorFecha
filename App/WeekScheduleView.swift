import SwiftUI
import Foundation

/**
 * Vista de la presentación de la semana. Contiene el listado de días, navegación semanal y inicia el flujo de navegación.
 */
struct WeekScheduleView: View { // <-- ESTRUCTURA PRINCIPAL AÑADIDA
    @ObservedObject var eventData: EventData
    
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
                
                // Weekly Schedule Body
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(weekDays, id: \.self) { day in
                        DayScheduleSection(
                            day: day,
                            events: eventData.events(for: day)
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
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
        VStack(alignment: .leading) {
            Text(hourString)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            Divider() // Línea divisoria para el horario
        }
    }
}


// Vista de sección para cada día de la semana (AHORA AGRUPADO POR HORAS)
struct DayScheduleSection: View {
    let day: Date
    let events: [Event]
    
    // Rango de horas a mostrar en el horario (de 8:00 a 22:00)
    private let scheduleHours = Array(8...22)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Cabecera del día (ej: Monday, November 17)
            Text(day, style: .date)
                .font(.title3)
                .fontWeight(.bold)
            
            if events.isEmpty {
                Text("No events scheduled.")
                    .foregroundColor(.secondary)
                    .padding(.leading)
            } else {
                
                // Iteramos por las horas fijas del horario
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(scheduleHours, id: \.self) { hour in
                        
                        // 1. Mostrar el marcador de hora
                        HourMarker(hour: hour)
                        
                        // 2. Filtrar eventos que empiezan en esta hora
                        let eventsInHour = events.filter { Calendar.current.component(.hour, from: $0.date) == hour }
                        
                        // 3. Mostrar los eventos si existen
                        if !eventsInHour.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(eventsInHour) { event in
                                    NavigationLink(value: event) {
                                        EventScheduleRow(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            // Pequeña sangría para diferenciar los eventos del marcador de hora
                            .padding(.leading, 15)
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
    }
}

