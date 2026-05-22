import Foundation
import SwiftData

final class AlarmListViewModel {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addAlarm(time: Date, exerciseType: ExerciseType, requiredReps: Int, label: String, sound: AlarmSound = .classic) {
        let alarm = Alarm(time: time, exerciseType: exerciseType, requiredReps: requiredReps, label: label, sound: sound)
        modelContext.insert(alarm)
        save()
        NotificationService.shared.scheduleAlarm(alarm)
    }

    func deleteAlarm(_ alarm: Alarm) {
        NotificationService.shared.cancelAlarm(alarm)
        modelContext.delete(alarm)
        save()
    }

    func toggleAlarm(_ alarm: Alarm) {
        alarm.isEnabled.toggle()
        save()
        if alarm.isEnabled {
            NotificationService.shared.scheduleAlarm(alarm)
        } else {
            NotificationService.shared.cancelAlarm(alarm)
        }
    }

    private func save() {
        do { try modelContext.save() }
        catch { print("[AlarmListViewModel] Save failed: \(error)") }
    }
}
