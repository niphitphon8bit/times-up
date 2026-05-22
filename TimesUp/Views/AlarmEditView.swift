import SwiftUI

struct AlarmEditView: View {
    let viewModel: AlarmListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTime = Date()
    @State private var selectedExercise: ExerciseType = .pushUps
    @State private var requiredReps = 10
    @State private var label = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Section("Exercise") {
                    Picker("Exercise Type", selection: $selectedExercise) {
                        ForEach(ExerciseType.allCases) { exercise in
                            Label(exercise.rawValue, systemImage: exercise.icon)
                                .tag(exercise)
                        }
                    }
                    .pickerStyle(.inline)

                    Stepper(value: $requiredReps, in: 1...50) {
                        HStack {
                            Text("Reps")
                            Spacer()
                            Text("\(requiredReps)")
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                        }
                    }
                }

                Section("Label") {
                    TextField("Alarm label", text: $label, prompt: Text("Morning Workout"))
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addAlarm(
                            time: selectedTime,
                            exerciseType: selectedExercise,
                            requiredReps: requiredReps,
                            label: label.isEmpty ? "Alarm" : label
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .tint(.orange)
                }
            }
        }
    }
}
