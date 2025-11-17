import SwiftUI
//#-learning-task(eventPlannerApp)

@main
struct DatePlannerApp: App {
    /*#-code-walkthrough(1.stateObject)*/
    @StateObject private var eventData = EventData()
    /*#-code-walkthrough(1.stateObject)*/
    
    // NEW: Variable de entorno para detectar cambios en el estado de la aplicación
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            /*#-code-walkthrough(1.eventList)*/
            EventList(eventData: eventData)
            /*#-code-walkthrough(1.eventList)*/
            //#-learning-task(loadData)
            // NUEVO: Cargar los datos al aparecer la vista
                .onAppear {
                    eventData.load()
                }
            //#-learning-code-snippet(9.loadingData)
            //#-learning-task(saveData)
            // NUEVO: Guardar los datos cuando la aplicación se desactiva (se va a segundo plano o se cierra)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive || newPhase == .background {
                        eventData.save()
                    }
                }
            //#-learning-code-snippet(10.saveData)
        }
    }
}
