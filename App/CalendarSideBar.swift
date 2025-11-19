import SwiftUI

/// Componente reutilizable que muestra el calendario lateral exactamente igual en todas las vistas.
struct CalendarSidebar: View {
    @ObservedObject var eventData: EventData
    // Permite anular la acción de selección (ej. limpiar selección de evento en el detalle)
    var onSelectDate: (() -> Void)? = nil
    // Optional actions for toolbar buttons so the host can provide behaviour
    var onAddEvent: (() -> Void)? = nil
    var onManageCalendars: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            if eventData.isCalendarVisible {
               // Mostrar el mes y el año encima del calendario.
                VStack {
                    Text(eventData.uiCalendarTitle)
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.bottom, 6)
                
                // Mostrar el calendario.
                CalendarView(
                    eventData: eventData,
                    selectedDate: Binding(get: { eventData.uiSelectedDate }, set: { eventData.uiSelectedDate = $0 }),
                    currentMonthAndYear: Binding(get: { eventData.uiCalendarTitle }, set: { eventData.uiCalendarTitle = $0 })
                )
                .onChange(of: eventData.uiSelectedDate) { _ in
                    onSelectDate?()
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct CalendarSidebar_Previews: PreviewProvider {
    static var previews: some View {
        CalendarSidebar(eventData: EventData())
    }
}

