import SwiftUI
import Foundation // Asegurarse de que esté importado

struct EventList: View {
    @ObservedObject var eventData: EventData
    @State private var isAddingNewEvent = false
    @State private var newEvent = Event()
    @State private var isManagingCalendars = false
    
    @State private var selection: Event?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        // Mantener el flujo condicional pero aplicar una única barra de herramientas externa
        Group {
            if eventData.isCalendarVisible {
                // Use a split view on regular width (iPad), but a stacked layout on compact (iPhone)
                if horizontalSizeClass == .regular {
                    NavigationSplitView {
                        CalendarSidebar(eventData: eventData, onSelectDate: { selection = nil }, onAddEvent: {
                            newEvent = Event()
                            isAddingNewEvent = true
                        }, onManageCalendars: {
                            isManagingCalendars = true
                        },
                            onToggleSidebar: { eventData.isCalendarVisible.toggle()
                        })
                    } detail: {
                        ZStack {
                            if let date = eventData.uiSelectedDate {
                                DayEventsDetailView(eventData: eventData, date: date, navigationSelection: $selection)
                            } else if let event = selection, let eventBinding = eventData.getBindingToEvent(event) {
                                EventEditor(event: eventBinding)
                            } else {
                                Text("Select a Day to see your Events")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .navigationTitle(eventData.uiCalendarTitle)
                    }
                } else {
                    // Compact: mostrar la barra lateral arriba y el detalle debajo para garantizar visibilidad
                    NavigationStack {
                        VStack(spacing: 0) {
                            CalendarSidebar(eventData: eventData, onSelectDate: { selection = nil }, onAddEvent: {
                                newEvent = Event()
                                isAddingNewEvent = true
                            }, onManageCalendars: {
                                isManagingCalendars = true
                            },
                                onToggleSidebar: { eventData.isCalendarVisible.toggle()
                            })
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemGroupedBackground))
                            Divider()
                            ZStack {
                                if let date = eventData.uiSelectedDate {
                                    DayEventsDetailView(eventData: eventData, date: date, navigationSelection: $selection)
                                } else if let event = selection, let eventBinding = eventData.getBindingToEvent(event) {
                                    EventEditor(event: eventBinding)
                                } else {
                                    WeekScheduleView(
                                        eventData: eventData,
                                        selectedDateFromCalendar: Binding(get: { eventData.uiSelectedDate }, set: { eventData.uiSelectedDate = $0 }),
                                        calendarTitle: Binding(get: { eventData.uiCalendarTitle }, set: { eventData.uiCalendarTitle = $0 })
                                    )
                                }
                            }
                            .navigationTitle(eventData.uiCalendarTitle)
                        }
                    }
                }
            } else {
                NavigationStack {
                    ZStack {
                        if let date = eventData.uiSelectedDate {
                            // detalle de día
                            DayEventsDetailView(eventData: eventData, date: date, navigationSelection: $selection)
                        } else if let event = selection, let eventBinding = eventData.getBindingToEvent(event) {
                            EventEditor(event: eventBinding)
                        } else {
                            WeekScheduleView(
                                eventData: eventData,
                                selectedDateFromCalendar: Binding(get: { eventData.uiSelectedDate }, set: { eventData.uiSelectedDate = $0 }),
                                calendarTitle: Binding(get: { eventData.uiCalendarTitle }, set: { eventData.uiCalendarTitle = $0 })
                            )
                            .navigationTitle(eventData.uiCalendarTitle)
                        }
                    }
                    .navigationTitle(eventData.uiCalendarTitle)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation { eventData.isCalendarVisible.toggle() }
                } label: {
                    Image(systemName: eventData.isCalendarVisible ? "sidebar.left" : "sidebar.right")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    newEvent = Event()
                    isAddingNewEvent = true
                } label: { Image(systemName: "plus") }
                
                Button {
                    isManagingCalendars = true
                } label: { Image(systemName: "calendar.badge.plus") }
                
                Button {
                    eventData.isCalendarVisible.toggle()
                } label: { Image(systemName: eventData.isCalendarVisible ? "sidebar.left" : "sidebar.right") }
            }
        }
        
        // Modificadores de Vistas Modales (Sheets)
        .sheet(isPresented: $isAddingNewEvent) {
            NavigationStack {
                EventEditor(event: $newEvent, isNew: true)
                    .environmentObject(eventData)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isAddingNewEvent = false
                            }
                        }
                        ToolbarItem {
                            Button {
                                eventData.add(newEvent)
                                isAddingNewEvent = false
                            } label: {
                                Text("Add")
                            }
                            .disabled(newEvent.title.isEmpty || (!newEvent.isAllDay && (newEvent.endDateOverride ?? newEvent.endDate) <= newEvent.date)
                            )
                        }
                    }
            }
        }
        .sheet(isPresented: $isManagingCalendars) {
            // Asumo que SubcalendarManager es una vista definida
            SubcalendarManager()
                .environmentObject(eventData)
        }
        .environmentObject(eventData)
    }
}

struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        EventList(eventData: EventData())
    }
}


