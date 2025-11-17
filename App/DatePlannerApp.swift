import SwiftUI
//#-learning-task(eventPlannerApp)

@main
struct DatePlannerApp: App {
    /*#-code-walkthrough(1.stateObject)*/
    @StateObject private var eventData = EventData()
    /*#-code-walkthrough(1.stateObject)*/
    
    var body: some Scene {
        WindowGroup {
            /*#-code-walkthrough(1.eventList)*/
            EventList(eventData: eventData)
            /*#-code-walkthrough(1.eventList)*/
            //#-learning-task(loadData)
            //#-learning-code-snippet(9.loadingData)
            //#-learning-task(saveData)
            //#-learning-code-snippet(10.saveData)
        }
    }
}
