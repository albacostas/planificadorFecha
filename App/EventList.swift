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
    
    @State private var selection: Event? // Used for editing a specific event
    
    // NEW: State for the date selected in the calendar
    @State private var selectedDateFromCalendar: Date? = Date.now.startOfDay
    
    var body: some View {
        /*#-code-walkthrough(5.navSplitView)*/
        NavigationSplitView {
            /*#-code-walkthrough(5.navSplitView)*/
            // NEW: TabView to switch between the original List and the new Calendar View
            TabView {
                // MARK: - Original Event List (Tab 1)
                Group {
                    /*#-code-walkthrough(5.listForEach)*/
                    List(selection: $selection) {
                        ForEach(Period.allCases) { period in
                            /*#-code-walkthrough(5.listForEach)*/
                            /*#-code-walkthrough(5.listSection)*/
                            Section(content: {
                                ForEach(eventData.sortedEvents(period: period)) { $event in
                                    /*#-code-walkthrough(5.listSection)*/
                                    /*#-code-walkthrough(5.eventView)*/
                                    EventRow(event: event)
                                        .tag(event)
                                    /*#-code-walkthrough(5.deleteEvents)*/
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                selection = nil
                                                eventData.remove(event)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    /*#-code-walkthrough(5.deleteEvents)*/
                                    /*#-code-walkthrough(5.eventView)*/
                                }
                            }, header: {
                                Text(period.name)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.bold)
                            })
                            .disabled(eventData.sortedEvents(period: period).isEmpty)
                        }
                    }
                    .onChange(of: selection) { newSelection in
                        // When an event is selected from the list, clear the calendar selection
                        if newSelection != nil {
                            selectedDateFromCalendar = nil
                        }
                    }
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                
                // MARK: - New Calendar View (Tab 2)
                Group {
                    CalendarView(eventData: eventData, selectedDate: $selectedDateFromCalendar)
                        .onChange(of: selectedDateFromCalendar) { newDate in
                            // When a date is selected from the calendar, clear the event selection
                            if newDate != nil {
                                selection = nil
                            }
                        }
                }
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            }
            .navigationTitle("Date Planner")
            .toolbar {
                ToolbarItem {
                    Button {
                        newEvent = Event()
                        isAddingNewEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
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
            ZStack {
                // NEW: If a date is selected from the calendar, show the DayEventsDetailView (with events and tasks)
                if let date = selectedDateFromCalendar {
                    DayEventsDetailView(eventData: eventData, date: date, navigationSelection: $selection)
                }
                // ORIGINAL: If an event is selected (either from the list or by tapping an event in DayEventsDetailView), show the EventEditor
                else if let event = selection, let eventBinding = eventData.getBindingToEvent(event) {
                    EventEditor(event: eventBinding)
                } 
                // Default view
                else {
                    Text("Select an Event or a Day from the Calendar")
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
