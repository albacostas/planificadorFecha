import SwiftUI
/**
 * Proporciona la estrucutra NavigationStack a pantalla completa y define que el destino al pulsar un evento es el EventEditor. 
 */

struct WeekScheduleFlowView: View {
    @ObservedObject var eventData: EventData
    // Use shared UI state from EventData for selected date and title
    
    var body: some View {
        Group {
            if eventData.isCalendarVisible {
                NavigationSplitView {
                    CalendarSidebar(eventData: eventData, onSelectDate: { /* no-op */ }, onAddEvent: {}, onManageCalendars: {})
                } detail: {
                    NavigationStack {
                        WeekScheduleView(eventData: eventData, selectedDateFromCalendar: Binding(get: { eventData.uiSelectedDate }, set: { eventData.uiSelectedDate = $0 }), calendarTitle: Binding(get: { eventData.uiCalendarTitle }, set: { eventData.uiCalendarTitle = $0 }))
                            .navigationDestination(for: Event.self) { event in
                                if let eventBinding = eventData.getBindingToEvent(event) {
                                    EventEditor(event: eventBinding)
                                        .environmentObject(eventData)
                                }
                            }
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            } else {
                NavigationStack {
                    WeekScheduleView(eventData: eventData, selectedDateFromCalendar: Binding(get: { eventData.uiSelectedDate }, set: { eventData.uiSelectedDate = $0 }), calendarTitle: Binding(get: { eventData.uiCalendarTitle }, set: { eventData.uiCalendarTitle = $0 }))
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Weekly Schedule")
                    .font(.headline)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    eventData.isCalendarVisible.toggle()
                } label: {
                    Image(systemName: eventData.isCalendarVisible ? "sidebar.left" : "sidebar.right")
                }
            }
        }
        .environmentObject(eventData)
    }
}

