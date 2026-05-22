import SwiftUI
import SwiftData

struct AlarmListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Alarm.time) private var alarms: [Alarm]
    @State private var showingAddAlarm = false
    @State private var activeAlarm: Alarm?

    var body: some View {
        NavigationStack {
            Group {
                if alarms.isEmpty {
                    emptyState
                } else {
                    alarmList
                }
            }
            .navigationTitle("Times Up")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddAlarm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddAlarm) {
                AlarmEditView(viewModel: AlarmListViewModel(modelContext: modelContext))
            }
            .fullScreenCover(item: $activeAlarm) { alarm in
                ChallengeView(alarm: alarm)
            }
            .onReceive(NotificationCenter.default.publisher(for: .alarmTriggered)) { notification in
                if let alarmId = notification.userInfo?["alarmId"] as? String,
                   let alarm = alarms.first(where: { $0.id.uuidString == alarmId }) {
                    activeAlarm = alarm
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Alarms", systemImage: "alarm.fill")
        } description: {
            Text("Add an alarm to get started.\nYou'll need to exercise to turn it off!")
        } actions: {
            Button("Add Alarm") {
                showingAddAlarm = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
    }

    private var alarmList: some View {
        List {
            ForEach(alarms) { alarm in
                AlarmRow(alarm: alarm) {
                    let vm = AlarmListViewModel(modelContext: modelContext)
                    vm.toggleAlarm(alarm)
                }
            }
            .onDelete { indexSet in
                let vm = AlarmListViewModel(modelContext: modelContext)
                for index in indexSet {
                    vm.deleteAlarm(alarms[index])
                }
            }
        }
        .listStyle(.plain)
    }
}

struct AlarmRow: View {
    let alarm: Alarm
    let onToggle: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.timeString)
                    .font(.system(size: 36, weight: .light, design: .rounded))
                    .foregroundStyle(alarm.isEnabled ? .primary : .secondary)
                HStack(spacing: 8) {
                    Label(alarm.exerciseType.rawValue, systemImage: alarm.exerciseType.icon)
                    Text("·")
                    Text("\(alarm.requiredReps) reps")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { alarm.isEnabled },
                set: { _ in onToggle() }
            ))
            .tint(.orange)
        }
        .padding(.vertical, 4)
    }
}

extension Notification.Name {
    static let alarmTriggered = Notification.Name("alarmTriggered")
}
