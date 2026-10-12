import Combine
import SwiftUI

final class GameModel: ObservableObject {
    enum Outcome { case playing, won, lost }

    let network = MultipeerManager()

    @Published private(set) var maze = Maze(rows: Constants.rows, cols: Constants.cols)
    @Published private(set) var myPosition = CGPoint.zero
    @Published private(set) var opponentPosition: CGPoint?
    @Published private(set) var pickups: [SkillPickup] = []
    @Published private(set) var skillSlots: [SkillType?] = [nil, nil]
    @Published private(set) var effects: Set<SkillType> = []
    @Published private(set) var outcome = Outcome.playing
    @Published private(set) var isReady = false
    @Published private(set) var tutorialStep: Int? = 0

    private var effectTimers: [SkillType: Task<Void, Never>] = [:]
    private var networkChanges: AnyCancellable?

    var isFogged: Bool { effects.contains(.fog) }
    var isFrozen: Bool { effects.contains(.freeze) }
    var canMove: Bool { isReady && tutorialStep == nil && outcome == .playing && !isFrozen }
    var myColor: Color { network.isHost ? .blue : .red }
    var opponentColor: Color { network.isHost ? .red : .blue }

    private var start: CGPoint {
        CGPoint(x: Grid.x(col: network.isHost ? 1 : maze.cols - 2), y: Grid.y(row: 1))
    }

    init() {
        myPosition = start
        networkChanges = network.objectWillChange.sink { [weak self] in self?.objectWillChange.send() }
        network.onMessage = { [weak self] in self?.handle($0) }
        network.onConnectionChange = { [weak self] connected in
            guard let self else { return }
            if !connected {
                reset()
            } else if network.isHost {
                dealNewRound()
            }
        }
    }

    func move(dx: Int, dy: Int) {
        guard canMove else { return }
        let target = CGPoint(x: myPosition.x + CGFloat(dx) * Constants.step,
                             y: myPosition.y + CGFloat(dy) * Constants.step)
        let row = Grid.row(y: target.y)
        let col = Grid.col(x: target.x)
        guard !maze.isWall(row: row, col: col) else { return }

        myPosition = target
        network.send(.position(myPosition))
        SoundManager.shared.play("move")
        collectPickup()

        if maze.isFinish(row: row, col: col) {
            outcome = .won
            network.send(.gameOver)
            SoundManager.shared.play("winner")
        }
    }

    func useSkill(_ slot: Int) {
        guard isReady, outcome == .playing, let skill = skillSlots[slot] else { return }
        if skill == .swap {
            guard let opponent = opponentPosition else { return }
            network.send(.swap(myPosition))
            myPosition = opponent
            network.send(.position(myPosition))
            collectPickup()
        } else {
            network.send(.skill(skill))
        }
        skillSlots[slot] = nil
        SoundManager.shared.play("skill")
    }

    func restart() {
        if network.isHost {
            dealNewRound()
        } else {
            network.send(.restartRequest)
        }
    }

    func nextTutorialStep() {
        guard let step = tutorialStep else { return }
        if step < 3 {
            tutorialStep = step + 1
        } else {
            tutorialStep = nil
            SoundManager.shared.play("gamestart")
        }
    }

    private func handle(_ message: PlayerMessage) {
        switch message {
        case .position(let position):
            opponentPosition = position
        case .newRound(let grid, let pickups):
            maze = Maze(grid: grid)
            self.pickups = pickups
            beginRound()
        case .restartRequest:
            if network.isHost { dealNewRound() }
        case .gameOver:
            outcome = .lost
            SoundManager.shared.play("gameover")
        case .skill(let skill):
            suffer(skill)
        case .swap(let position):
            withAnimation(.spring()) { myPosition = position }
            network.send(.position(myPosition))
            collectPickup()
        case .pickupCollected(let row, let col):
            pickups.removeAll { $0.row == row && $0.col == col }
        }
    }

    private func dealNewRound() {
        maze = Maze(rows: Constants.rows, cols: Constants.cols)
        pickups = maze.randomPickups(perSkill: Constants.pickupsPerSkill)
        network.send(.newRound(maze: maze.grid, pickups: pickups))
        beginRound()
    }

    private func beginRound() {
        clearRound()
        isReady = true
        network.send(.position(myPosition))
    }

    private func reset() {
        clearRound()
        isReady = false
        pickups = []
        opponentPosition = nil
    }

    private func clearRound() {
        outcome = .playing
        skillSlots = [nil, nil]
        effectTimers.values.forEach { $0.cancel() }
        effectTimers = [:]
        effects = []
        tutorialStep = 0
        myPosition = start
    }

    private func collectPickup() {
        let row = Grid.row(y: myPosition.y)
        let col = Grid.col(x: myPosition.x)
        guard let index = pickups.firstIndex(where: { $0.row == row && $0.col == col }),
              let slot = skillSlots.firstIndex(of: nil) else { return }
        skillSlots[slot] = pickups.remove(at: index).skill
        network.send(.pickupCollected(row: row, col: col))
    }

    private func suffer(_ skill: SkillType) {
        effects.insert(skill)
        effectTimers[skill]?.cancel()
        effectTimers[skill] = Task {
            try? await Task.sleep(for: .seconds(Constants.effectSeconds))
            if !Task.isCancelled { effects.remove(skill) }
        }
    }
}
