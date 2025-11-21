import SwiftUI

struct TaskRow: View {
    @Binding var task: EventTask
    var focusedTask: FocusState<EventTask?>.Binding

    var body: some View {
        HStack(spacing: 8) {
            Button {
                // Toggle completion — keep action simple so it reliably updates the binding
                task.isCompleted.toggle()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(task.isCompleted ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            // Ensure a sufficiently large, obvious hit area on touch devices
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .padding(.leading, 2)
            .accessibilityLabel(task.isCompleted ? "Completed" : "Mark as complete")

            TextField("Task Description", text: $task.text, axis: .vertical)
                .focused(focusedTask, equals: task)
                .strikethrough(task.isCompleted, color: .secondary)
                .foregroundColor(task.isCompleted ? .secondary : .primary)
                .animation(.easeInOut, value: task.isCompleted)

            Spacer()
        }
    }
}
