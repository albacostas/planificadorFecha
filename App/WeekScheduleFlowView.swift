import SwiftUI
/**
* Proporciona la estrucutra NavigationStack a pantalla completa y define que el destino al pulsar un evento es el EventEditor. 
*/

struct WeekScheduleFlowView: View {
    @ObservedObject var eventData: EventData
    
    var body: some View {
        // Usa NavigationStack para gestionar la navegación a pantalla completa
        NavigationStack {
            // El contenido principal es el horario semanal
            WeekScheduleView(eventData: eventData) // Ya no necesita el binding de navegación
            // Definimos el destino de la navegación (cuando se pulsa un Evento)
                .navigationDestination(for: Event.self) { event in
                    if let eventBinding = eventData.getBindingToEvent(event) {
                        EventEditor(event: eventBinding)
                    }
                }
            // Eliminamos el título general para cumplir con el requisito
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Weekly Schedule") // Título específico para esta vista
                            .font(.headline)
                    }
                }
        }
    }
}
