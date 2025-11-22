import SwiftUI
/**
 * Proporciona la estrucutra NavigationStack a pantalla completa y define que el destino al pulsar un evento es el EventEditor. 
 */

struct WeekScheduleFlowView: View {
    @ObservedObject var eventData: EventData
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var isAddingNewEvent = false
    @State private var newEvent = Event()
    @State private var isManagingCalendars = false
    
    var selectedTab: Binding<Int>? = nil
    
    var body: some View {
        Group {
            if eventData.isCalendarVisible {
                if horizontalSizeClass == .regular {
                    NavigationSplitView {
                        CalendarSidebar(
                            eventData: eventData,
                            onSelectDate: { /* no-op */ },
                            onAddEvent: {},
                            onManageCalendars: {},
                            onToggleSidebar: {
                                withAnimation{
                                    eventData.isCalendarVisible.toggle()
                                    
                                    selectedTab?.wrappedValue = 1
                                }
                                
                            }
                        )
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
                                .navigationDestination(for: Event.self) { event in
                                    if let eventBinding = eventData.getBindingToEvent(event) {
                                        EventEditor(event: eventBinding)
                                            .environmentObject(eventData)
                                        
                                    }
                                }
                        }
                    }
                } else {
                    NavigationStack {
                        VStack(spacing: 0) {
                            CalendarSidebar(
                                eventData: eventData,
                                onSelectDate: {/*no-op*/},
                                onAddEvent: {},
                                onManageCalendars: {},
                                onToggleSidebar: {
                                    withAnimation {
                                        eventData.isCalendarVisible.toggle()
                                        selectedTab?.wrappedValue = 1
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemGroupedBackground))
                            Divider()
                            WeekScheduleView(eventData: eventData, selectedDateFromCalendar: Binding(get: { eventData.uiSelectedDate }, set: { eventData.uiSelectedDate = $0 }), calendarTitle: Binding(get: { eventData.uiCalendarTitle }, set: { eventData.uiCalendarTitle = $0 }))
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationDestination(for: Event.self) { event in
                                    if let eventBinding = eventData.getBindingToEvent(event) {
                                        EventEditor(event: eventBinding)
                                            .environmentObject(eventData)
                                        
                                    }
                                }
                        }
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
            // Toggle en la izquierda (junto al título)
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation { eventData.isCalendarVisible.toggle()
                        selectedTab?.wrappedValue = 1
                    }
                } label: {
                    Image(systemName: eventData.isCalendarVisible ? "sidebar.left" : "sidebar.right")
                }
            }

            // Título en el centro
            ToolbarItem(placement: .principal) {
                Text("Weekly Schedule")
                    .font(.headline)
            }

            // Acciones a la derecha: añadir evento / gestionar calendarios
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    newEvent = Event()
                    isAddingNewEvent = true
                } label: { Image(systemName: "plus") }

                Button {
                    isManagingCalendars = true
                } label: { Image(systemName: "calendar.badge.plus") }
            }
        }

        // Sheets: añadir evento y gestionar calendarios
        .sheet(isPresented: $isAddingNewEvent) {
            NavigationStack {
                EventEditor(event: $newEvent, isNew: true)
                    .environmentObject(eventData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { isAddingNewEvent = false }
                        }
                        ToolbarItem {
                            Button {
                                eventData.add(newEvent)
                                isAddingNewEvent = false
                            } label: { Text("Add") }
                            .disabled(newEvent.title.isEmpty)
                        }
                    }
            }
        }
        .sheet(isPresented: $isManagingCalendars) {
            SubcalendarManager()
                .environmentObject(eventData)
        }
        .environmentObject(eventData)
    }
}

