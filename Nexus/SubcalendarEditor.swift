import SwiftUI

struct SubcalendarEditor: View {
    @Binding var calendar: Subcalendar
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Calendar")) {
                TextField("Title", text: Binding(get: {
                    calendar.title
                }, set: { new in
                    calendar.title = new
                }))
                
                ColorPicker("Color", selection: Binding(get: {
                    Color(calendar.color)
                }, set: { newColor in
                    calendar.color = newColor.rgbaColor
                }))
                
                Toggle("Visible", isOn: Binding(get: {
                    calendar.isVisible
                }, set: { new in
                    calendar.isVisible = new
                }))
            }
        }
        .navigationTitle("Edit Calendar")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct SubcalendarEditor_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SubcalendarEditor(calendar: .constant(Subcalendar.example))
        }
    }
}
