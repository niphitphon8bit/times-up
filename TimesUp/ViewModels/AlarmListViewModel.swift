import SwiftData
import Observation

@Observable
final class AlarmListViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addAlarm(time: Date, exerciseType: ExerciseType, requiredReps: Int, label: String) {
        let alarm = Alarm(time: time, exerciseType: exerciseType, requiredReps: requiredReps, label: label)
        modelContext.insert(alarm)
        try? modelContext.save()
        NotificationService.shared.scheduleAlarm(alarm)
    }

    func deleteAlarm(_ alarm: Alarm) {
        NotificationService.shared.cancelAlarm(alarm)
        modelContext.delete(alarm)
        try? modelContext.save()
    }

    func toggleAlarm(_ alarm: Alarm) {
        alarm.isEnabled.toggle()
        try? modelContext.save()
        if alarm.isEnabled {
            NotificationService.shared.scheduleAlarm(alarm)
        } else {
            NotificationService.shared.cancelAlarm(alarm)
        }
    }
}
