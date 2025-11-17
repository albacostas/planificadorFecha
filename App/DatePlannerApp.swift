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
            RootTabView(eventData: eventData)
                .onAppear {
                    eventData.load()
                }
                .onChange(of: scenePhase) {
                    newPhase in
                    if newPhase == .inactive || newPhase == .background {
                        eventData.save()
                    }
                }

            //#-learning-code-snippet(10.saveData)
        }
    }
}
struct RootTabView: View {
    @ObservedObject var eventData: EventData
    var body: some View {
        TabView {
            EventList(eventData: eventData)
                .tabItem{
                    Label("Calendar Flow", systemImage: "calendar")
                }
            WeekScheduleFlowView(eventData: eventData)
                .tabItem { 
                    Label("Schedule", systemImage: "calendar.day.timeline.leading")
                }
        }
    }
}
