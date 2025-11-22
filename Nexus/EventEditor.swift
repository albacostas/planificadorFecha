import SwiftUI

struct EventEditor: View {
    @Binding var event: Event
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var eventData: EventData
    
    @FocusState var focusedTask: EventTask?
    
    @State var isNew = false
    @State private var isPickingSymbol = false
    
    @State private var localEndDate: Date = Date()
   // @State private var selectedCalendarID: UUID? = nil
   // @State private var selectedSubtype: EventSubtype = .task
   // @State private var selectedRepeat: RepeatFrequency = .none
   // @State private var repeatEndDate: Date? = nil
    
    var body: some View {
        List {
            HStack {
                Button {
                    isPickingSymbol.toggle()
                } label: {
                    Image(systemName: event.symbol)
                        .imageScale(.large)
                        .foregroundColor(Color(event.color))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 5)

                TextField("New Event", text: $event.title)
                    .font(.title2)
            }
            .padding(.top, 5)
            
            DatePicker("Date", selection: $event.date)
                .labelsHidden()
                .listRowSeparator(.hidden)
            
            HStack {
                Text("Duration")
                Spacer()
                Text(formatDuration(minutes: event.durationMinutes))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            Toggle("All Day", isOn: $event.isAllDay)
            if !event.isAllDay {
                DatePicker("End", selection: $localEndDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .onChange(of: localEndDate) { newEnd in
                        event.endDateOverride = newEnd
                        let delta = Int(newEnd.timeIntervalSince(event.date) / 60)
                        event.durationMinutes = max(1, delta)
                    }
                    .onChange(of: event.date) { newStart in
                        if let end = event.endDateOverride {
                            if end <= newStart {
                                let newEnd = newStart.addingTimeInterval(TimeInterval(60 * event.durationMinutes))
                                localEndDate = newEnd
                                event.endDateOverride = newEnd
                            }
                                
                        } else {
                            let newEnd = newStart.addingTimeInterval(TimeInterval(event.durationMinutes * 60))
                            localEndDate = newEnd
                            event.endDateOverride = newEnd
                        }
                    }
                    .onAppear {
                        localEndDate = event.endDateOverride ?? event.endDate
                        if event.endDateOverride == nil {
                            event.endDateOverride = localEndDate
                        }
                    }
            }/*
            Stepper(value: $event.durationMinutes, in: 5...24*60, step: 5) {
                Text("Lenght: \(formatDuration(minutes: event.durationMinutes))")
            }*/
            //.listRowSeparator(.hidden)
            // Calendar selection
            Picker("Calendar", selection: Binding(get: {
                event.calendarID ?? eventData.calendars.first?.id
            }, set: { newID in
                event.calendarID = newID
                if let id = newID, let cal = eventData.calendars.first(where: { $0.id == id }) {
                    event.color = cal.color
                }
            })) {
                ForEach(eventData.calendars) { cal in
                    HStack {
                        Circle().fill(Color(cal.color)).frame(width: 10, height: 10)
                        Text(cal.title)
                    }.tag(cal.id as UUID?)
                }
            }
            
            // Subtype
            Picker("Type", selection: $event.subtype) {
                ForEach(EventSubtype.allCases) { s in
                    Text(s.rawValue).tag(s)
                }
            }
            
            // Repeat
            Picker("Repeat", selection: $event.repeatFrequency) {
                ForEach(RepeatFrequency.allCases) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            
            if event.repeatFrequency != .none {
                DatePicker("Repeat End", selection: Binding(get: {
                    event.repeatEndDate ?? Date().addingTimeInterval(60*60*24*30)
                }, set: { newDate in
                    event.repeatEndDate = newDate
                }), displayedComponents: .date)
            }
            
            if event.subtype == .task {
                Text("Tasks")
                    .fontWeight(.bold)
                
                ForEach($event.tasks) { $item in
                    TaskRow(task: $item, focusedTask: $focusedTask)
                }
                .onDelete(perform: { indexSet in
                    event.tasks.remove(atOffsets: indexSet)
                })

                Button {
                    let newTask = EventTask(text: "", isNew: true)
                    event.tasks.append(newTask)
                    focusedTask = newTask
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Task")
                    }
                }
                .buttonStyle(.borderless)
            }
            
        }

        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isPickingSymbol) {
            SymbolPicker(event: $event)
        }
    }
    
    private func formatDuration(minutes: Int) -> String {
        if minutes % 60 == 0 {
            return "\(minutes / 60) h"
        } else if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return "\(h)h \(m)m"
        }
        return "\(minutes) min"
    }
}

struct EventEditor_Previews: PreviewProvider {
    static var previews: some View {
        EventEditor(event: .constant(Event()), isNew: true)
            .environmentObject(EventData())
    }
}
