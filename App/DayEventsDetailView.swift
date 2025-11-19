import SwiftUI

struct DayEventsDetailView: View {
    @ObservedObject var eventData: EventData
    let date: Date
    // Se usa el binding para permitir seleccionar un evento y navegar a EventEditor.
    @Binding var navigationSelection: Event? 
    
    var eventsForDay: [Event] {
        eventData.events(for: date)
    }
    
    var body: some View {
        List {
            Section(header: Text("Events for \(date.formatted(date: .long, time: .omitted))")) {
                if eventsForDay.isEmpty {
                    Text("No events scheduled for this day.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(eventsForDay) { event in
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: event.symbol)
                                    .foregroundColor(Color(event.color))
                                Text(event.title)
                                    .font(.headline)
                            }
                            Text(event.date.formatted(date: .omitted, time: .shortened))
                                .font(.subheadline)
                                .padding(.bottom, 5)
                            
                            // Listado de tareas (tasks) del evento
                            ForEach(event.tasks.filter { !$0.text.isEmpty }) { task in
                                HStack {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(task.isCompleted ? .green : Color(event.color))
                                    Text(task.text)
                                        .strikethrough(task.isCompleted)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 5)
                            }
                            // Permite al usuario seleccionar el evento para ir al EventEditor
                            .onTapGesture {
                                navigationSelection = event
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
        }
        .navigationTitle("Day Details")
    }
}

