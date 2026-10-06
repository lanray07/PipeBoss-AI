import Foundation

protocol ProgressStoring {
    func loadPlayer() -> Player
    func save(_ player: Player)
    func loadTraining() -> TrainingProgress
    func saveTraining(_ training: TrainingProgress)
    func clear()
}

final class UserDefaultsProgressStore: ProgressStoring {
    private let key = "pipebossai.player.v1"
    private let trainingKey = "pipebossai.training.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadPlayer() -> Player {
        guard let data = defaults.data(forKey: key) else {
            return Player.newApprentice
        }

        do {
            var player = try JSONDecoder().decode(Player.self, from: data)
            player.refreshEnergyIfNeeded()
            return player
        } catch {
            return Player.newApprentice
        }
    }

    func save(_ player: Player) {
        guard let data = try? JSONEncoder().encode(player) else { return }
        defaults.set(data, forKey: key)
    }

    func clear() {
        defaults.removeObject(forKey: key)
        defaults.removeObject(forKey: trainingKey)
    }

    func loadTraining() -> TrainingProgress {
        guard let data = defaults.data(forKey: trainingKey),
              let training = try? JSONDecoder().decode(TrainingProgress.self, from: data) else { return TrainingProgress() }
        return training
    }

    func saveTraining(_ training: TrainingProgress) {
        guard let data = try? JSONEncoder().encode(training) else { return }
        defaults.set(data, forKey: trainingKey)
    }
}
