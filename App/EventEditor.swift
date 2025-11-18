import SwiftUI
import Foundation

struct EventEditor: View {
    @Binding var event: Event
    var isNew = false
    
    private let weekDayNames = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        List {
            // Usamos la inicializadora con título String para evitar ambigüedad
            Section("Event Details"){
                TextField("Event Title", text: $event.title)
                    .textFieldStyle(.roundedBorder)
                
                HStack(spacing: 12) {
                    Image(systemName: event.symbol)
                        .foregroundColor(event.color.color)
                    
                    SymbolPicker(symbol: $event.symbol, color: $event.color)
                    
                    Text("Symbol: \(event.symbol)")
                }
                
                // Selector de tipo de evento (Clase, examen, tarea).
                Picker("Event Type", selection: $event.eventType) {
                    ForEach(EventType.allCases) { type in
                        Label(type.rawValue, systemImage: type.symbol)
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Sección de fecha y repetición
            Section("Event Details"){
                DatePicker("Date", selection: $event.date)
                Toggle("Repeat Weekly", isOn: $event.repetition.isRepeating)
            }
            
            // Configuración de Repetición.
            if event.repetition.isRepeating {
                // CORRECCIÓN: 'hearder' a 'header'
                Section(header: Text("Repetition Details")) {
                    VStack(alignment: .leading) {
                        Text("Repeat on")
                        HStack {
                            // CORRECCIÓN: Sintaxis de ForEach y 'id: \.self'
                            ForEach(1...7, id: \.self)  { weekday in
                                let dayName = weekDayNames[weekday - 1]
                                // CORRECCIÓN: 'DatToggle' a 'DayToggle' y paso del argumento 'weekday'
                                DayToggle(day: dayName, weekday: weekday, selectedDays: $event.repetition.repeatDays)
                            }
                        }
                    }
                    Toggle("Set End Date", isOn: $event.repetition.repetitionEndDate.exists)
                    if event.repetition.repetitionEndDate.exists {
                        // AQUÍ ESTABA EL PROBLEMA DE INFERENCIA DE TIPO
                        DatePicker("End Date", selection: $event.repetition.repetitionEndDate.nonNilDateBinding, displayedComponents: .date)
                    }
                }
            }
            
            // Seleción de tareas.
            Section(header: Text("Tasks")) {
                ForEach($event.tasks) { $task in
                    // NOTA: Usar TaskRow(task: $task) si está disponible
                    Text("Task: \(task.text)")
                }
                .onDelete(perform: { indexSet in
                    event.tasks.remove(atOffsets: indexSet)
                })
                
                Button {
                    event.tasks.append(EventTask(text: ""))
                } label: {
                    Label("Add New Task", systemImage: "plus")
                }
            }
        }
        .navigationTitle(isNew ? "Add New Event" : "Edit Event")            
    }
}

// --- VISTAS Y PROTOCOLOS AUXILIARES CORREGIDOS ---

extension Binding where Value: OptionalProtocol, Value.Wrapped == Date { 
    var exists: Binding<Bool> {
        Binding<Bool>(
            get: { self.wrappedValue.wrapped != nil },
            set: { newValue in
                // CORRECCIÓN: Operador AND lógico '&&' y consistencia de tipos
                if newValue && self.wrappedValue.wrapped == nil { 
                    self.wrappedValue.wrapped = Calendar.current.startOfDay(for: Date().addDays(7)) // Asume que addDays() existe
                } else if !newValue {
                    self.wrappedValue.wrapped = nil
                }
            }
        )
    }
    
    // 💡 CORRECCIÓN PRINCIPAL: Se renombra a 'nonNilDateBinding' para ser más explícito
    // y para asegurar que el compilador infiera correctamente Binding<Date>
    var nonNilDateBinding: Binding<Date> { 
        Binding<Date>(
            get: { self.wrappedValue.wrapped ?? Date() },
            set: { self.wrappedValue.wrapped = $0 }
        )
    }
}

protocol OptionalProtocol {
    associatedtype Wrapped
    var wrapped: Wrapped? { get set }
}

extension Optional: OptionalProtocol {
    var wrapped: Wrapped? {
        get { self }
        set { self = newValue }
    }
}

struct DayToggle: View { 
    let day: String
    let weekday: Int 
    @Binding var selectedDays: Set<Int>
    
    var isSelected: Bool {
        selectedDays.contains(weekday)
    }
    
    var body: some View {
        Button(action: {
            if isSelected {
                selectedDays.remove(weekday)
            } else {
                selectedDays.insert(weekday)
            }
        }) {
            Text(String(day.prefix(1)))
                .font(.subheadline)
            // CORRECCIÓN: Se añade el valor '.bold'
                .fontWeight(.bold) 
                .frame(width: 30, height: 30)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Circle()) 
        }
        .buttonStyle(.plain)
    }
}

struct EventEditor_Previews: PreviewProvider {
    static var previews: some View {
        EventEditor(event: .constant(Event()), isNew: true)
    }
}
