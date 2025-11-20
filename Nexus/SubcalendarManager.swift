import SwiftUI

struct SubcalendarManager: View {
    @EnvironmentObject var eventData: EventData
    @Environment(\.dismiss) private var dismiss
    
    @State private var isAddingNew = false
    @State private var newTitle: String = ""
    @State private var newColor: Color = ColorOptions.random()
    @State private var editingCalendar: Subcalendar? = nil
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Calendars")) {
                    ForEach(eventData.calendars) { cal in
                        HStack {
                            Circle().fill(Color(cal.color)).frame(width: 16, height: 16)
                            VStack(alignment: .leading) {
                                Text(cal.title)
                                if !cal.isVisible {
                                    Text("Hidden").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            Button(action: {
                                editingCalendar = cal
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.borderless)
                            Button(role: .destructive) {
                                eventData.removeCalendar(cal)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                
                Section(header: Text("Add Calendar")) {
                    TextField("Title", text: $newTitle)
                    ColorPicker("Color", selection: $newColor)
                    Button(action: addNewCalendar) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Calendar")
                        }
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Manage Calendars")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(item: $editingCalendar) { cal in
                if let binding = eventData.getBindingToCalendar(cal) {
                    SubcalendarEditor(calendar: binding)
                        .environmentObject(eventData)
                } else {
                    Text("Unable to edit")
                }
            }
        }
    }
    
    private func addNewCalendar() {
        let cal = Subcalendar(title: newTitle, color: newColor.rgbaColor)
        eventData.addCalendar(cal)
        newTitle = ""
        newColor = ColorOptions.random()
    }
}

struct SubcalendarManager_Previews: PreviewProvider {
    static var previews: some View {
        SubcalendarManager()
            .environmentObject(EventData())
    }
}

