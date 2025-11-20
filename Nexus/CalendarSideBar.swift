import SwiftUI

/// Componente reutilizable que muestra el calendario lateral exactamente igual en todas las vistas.
struct CalendarSidebar: View {
    @ObservedObject var eventData: EventData
    // Permite anular la acción de selección (ej. limpiar selección de evento en el detalle)
    var onSelectDate: (() -> Void)? = nil
    // Optional actions for toolbar buttons so the host can provide behaviour
    var onAddEvent: (() -> Void)? = nil
    var onManageCalendars: (() -> Void)? = nil
    
    @State private var editingCalendar: Subcalendar? = nil
    
    var body: some View {
        VStack {
            if eventData.isCalendarVisible {
                // Month / Year title above the mini-calendar (centered)
                VStack {
                    Text(eventData.uiCalendarTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 6)
                
                // Top action row: add / manage
                HStack(spacing: 12) {
                    Spacer()
                    Button(action: {
                        // Create a new calendar and open editor
                        onAddEvent?()
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: {
                        onManageCalendars?()
                    }) {
                        Image(systemName: "calendar.badge.plus")
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.bottom, 6)
                
                CalendarView(
                    eventData: eventData,
                    selectedDate: Binding(get: { eventData.uiSelectedDate }, set: { eventData.uiSelectedDate = $0 }),
                    currentMonthAndYear: Binding(get: { eventData.uiCalendarTitle }, set: { eventData.uiCalendarTitle = $0 })
                )
                .onChange(of: eventData.uiSelectedDate) { _ in
                    onSelectDate?()
                }
                
                // List of subcalendars with edit/delete actions
                if !eventData.calendars.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Calendars")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        ForEach(eventData.calendars) { cal in
                            HStack {
                                Circle()
                                    .fill(Color(cal.color))
                                    .frame(width: 14, height: 14)
                                
                                Text(cal.title)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let binding = eventData.getBindingToCalendar(cal) {
                                        binding.wrappedValue.isVisible.toggle()
                                    }
                                }) {
                                    Image(systemName: cal.isVisible ? "eye.fill" : "eye.slash")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            } else {
                VStack(spacing: 12) {
                    Text("Calendario oculto")
                        .foregroundStyle(.secondary)
                    Button(action: { eventData.isCalendarVisible = true }) {
                        Text("Mostrar Calendario")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Spacer()
        }
        .padding()
        // Present editor when user taps edit or creates new calendar
        .sheet(item: $editingCalendar) { cal in
            if let binding = eventData.getBindingToCalendar(cal) {
                NavigationStack {
                    SubcalendarEditor(calendar: binding)
                        .environmentObject(eventData)
                }
            } else {
                // Fallback: show manager
                SubcalendarManager()
                    .environmentObject(eventData)
            }
        }
    }
}

struct CalendarSidebar_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSidebar(eventData: EventData())
    }
}

