import SwiftUI
//#-learning-task(eventList)

/*#-code-walkthrough(5.eventList)*/
struct EventList: View {
    /*#-code-walkthrough(5.eventList)*/
    /*#-code-walkthrough(5.eventData)*/
    @ObservedObject var eventData: EventData
    /*#-code-walkthrough(5.eventData)*/
    @State private var isAddingNewEvent = false
    @State private var newEvent = Event()
    
    // Se mantiene para la edición de eventos si se pulsa un evento en la vista de detalle del día
    @State private var selection: Event? 
    
    // Estado para la fecha seleccionada en el calendario, por defecto hoy.
    @State private var selectedDateFromCalendar: Date? = Date.now.startOfDay
    
    // Estado para guardar el titulo de mes/año
    @State private var calendarTitle: String = "Date Planner"
    
    
    
    
    
    var body: some View {
        /*#-code-walkthrough(5.navSplitView)*/
        NavigationSplitView {
            
            VStack {
                CalendarView(eventData: eventData, selectedDate: $selectedDateFromCalendar, currentMonthAndYear: $calendarTitle)
                    .onChange(of: selectedDateFromCalendar) { newDate in
                        if newDate != nil {
                            selection = nil
                        }
                    }
                Spacer()
            }
            .navigationTitle(calendarTitle)
            .toolbar {
                ToolbarItem{
                    Button {
                        newEvent = Event()
                        isAddingNewEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            /*#-code-walkthrough(5.navSplitView)*/
            }
            .sheet(isPresented: $isAddingNewEvent) {
                NavigationStack {
                    EventEditor(event: $newEvent, isNew: true)
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
                                    Text("Add" )
                                }
                                .disabled(newEvent.title.isEmpty)
                            }
                        }
                }
            }
            
            /*#-code-walkthrough(5.navSplitViewDetails)*/
        } detail: {
            // Panel de Detalle: Muestra la vista de eventos del día o el editor de eventos
            ZStack {
                // 1. Si se selecciona una fecha en el calendario, muestra la vista de detalle de ese día.
                if let date = selectedDateFromCalendar {
                    DayEventsDetailView(eventData: eventData, date: date, navigationSelection: $selection)
                }
                // 2. Si se selecciona un evento (esto ocurre si se pulsa un evento dentro de DayEventsDetailView), muestra el editor.
                else if let event = selection, let eventBinding = eventData.getBindingToEvent(event) {
                    EventEditor(event: eventBinding)
                } 
                // Vista por defecto
                else {
                    Text("Select a Day to see your Events")
                        .foregroundStyle(.secondary)
                }
            }
        }
        /*#-code-walkthrough(5.navSplitViewDetails)*/
    }
}

struct EventList_Previews: PreviewProvider {
    static var previews: some View {
        EventList(eventData: EventData())
    }
}
