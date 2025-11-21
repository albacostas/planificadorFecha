import SwiftUI
import CoreData

@main
struct DatePlannerApp: App {
    // Create EventData backed by Core Data context
    
    @StateObject private var eventData = EventData(context: PersistenceController.shared.container.viewContext)
    
    // Detectar cambios en el estado de la aplicación
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootTabView(eventData: eventData)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .inactive || newPhase == .background {
                        // trigger save to Core Data
                        eventData.save()
                    }
                }
        }
    }
}
struct RootTabView: View {
    @ObservedObject var eventData: EventData
    // Control explícito para la pestaña selecionada.
    @State var selectedTab: Int = 0 // 0 = Calendario; 1 = Semana
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                EventList(eventData: eventData)
                    .tabItem{
                        Label("Calendario", systemImage: "calendar")
                    }
                    .tag(0)
                WeekScheduleFlowView(eventData: eventData)
                    .tabItem {
                        Label("Semana", systemImage: "calendar.day.timeline.leading")
                    }
                    .tag(1)
            }

            // Floating toggle button: visible only when the sidebar is hidden
            if !eventData.isCalendarVisible {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation { eventData.isCalendarVisible = true }
                        }) {
                            Image(systemName: "sidebar.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.accentColor))
                                .shadow(radius: 4)
                        }
                        .padding()
                        .accessibilityLabel("Mostrar barra lateral")
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
}

