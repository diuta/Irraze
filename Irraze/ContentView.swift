import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @StateObject private var multipeerManager = MultipeerManager()
    @State private var maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
    @State private var position = CGPoint.zero
    @State private var showPeerSheet = false
    @State private var isFinished = false
    @State private var firstGuide = true
    @State private var secondGuide = false
    @State private var thirdGuide = false
    @State private var fourthGuide = false
    @State private var showGame = false

    var rows: Int { maze.rows }
    var cols: Int { maze.cols }

    var hostStart: CGPoint {
        CGPoint(x: colToPixel(col: 1), y: rowToPixel(row: 1))
    }
    var guestStart: CGPoint {
        CGPoint(x: colToPixel(col: cols-2), y: rowToPixel(row: 1))
    }

    var localColor: Color { multipeerManager.isHost ? .blue : .red }
    var remoteColor: Color { multipeerManager.isHost ? .red : .blue }

    var body: some View {
        GeometryReader { geo in
            Image("bmo2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    ZStack {
                        if multipeerManager.gameReady {
                            if !showGame {
                                InstructionsView(firstGuide: $firstGuide, secondGuide: $secondGuide, thirdGuide: $thirdGuide, fourthGuide: $fourthGuide, showGame: $showGame)
                                    .frame(width: geo.size.width * 0.65, height: geo.size.height * 0.35)
                            } else if !isFinished && !multipeerManager.opponentWon && showGame {
                                Map()
                                Obstacles(maze: maze, position: position, isFogged: multipeerManager.isFogged, fogPickups: multipeerManager.fogPickups, swapPickups: multipeerManager.swapPickups, freezePickups: multipeerManager.freezePickups)
                                Player(maze: maze, position: position, color: localColor)
                                
                                if let remotePos = multipeerManager.remotePosition {
                                    RemotePlayer(remotePosition: remotePos, localPosition: position, color: remoteColor, maze: maze)
                                }
                            }
                        }
                        
                        if !multipeerManager.gameReady {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(.black)
                                Text("Waiting for opponent...")
                                    .font(.custom("PressStart2P-Regular", size: 10))
                                    .foregroundColor(.black)
                            }
                            .padding(.top, geo.size.height * 0.15)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                        }
                        
                        if (isFinished || multipeerManager.opponentWon) && multipeerManager.gameReady {
                            GameOverView(isFinished: isFinished, onTryAgain: {
                                haptic()
                                restartGame()
                            })
                            .padding(.top, geo.size.height * 0.15)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, geo.size.height * 0.10)
                
                ConnectionToolbarView(multipeerManager: multipeerManager, showPeerSheet: $showPeerSheet, onDisconnect: {
                    multipeerManager.disconnect()
                    maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
                    position = hostStart
                    isFinished = false
                    multipeerManager.opponentWon = false
                    
                    firstGuide = true
                    showGame = false
                })
                .padding(.top, geo.size.height * 0.6)

                UserInput(
                    maze: $maze,
                    position: $position,
                    isFinished: $isFinished,
                    multipeerManager: multipeerManager,
                )
                .padding(.top, geo.size.height * 0.67)

            }
        }
        .onAppear {
            position = hostStart
        }
        .onChange(of: multipeerManager.isConnected) { connected in
            if connected && multipeerManager.isHost {
                let (fog, swap, freeze) = generatePickups(from: maze, count: 3)
                
                multipeerManager.fogPickups = fog
                multipeerManager.swapPickups = swap
                multipeerManager.freezePickups = freeze
                
                multipeerManager.sendMaze(maze.grid)
                multipeerManager.sendPickups(fog: fog, swap: swap, freeze: freeze)
                
                firstGuide = true
                secondGuide = false
                thirdGuide = false
                fourthGuide = false
                showGame = false
                
            } else if !connected {
                isFinished = false
                firstGuide = true
                secondGuide = false
                thirdGuide = false
                fourthGuide = false
                showGame = false
            }
        }
        .onChange(of: multipeerManager.receivedMazeGrid) { grid in
            if let grid = grid {
                maze = MazeGenerator2(grid: grid)
            }
        }
        .onChange(of: multipeerManager.receivedRestartGrid) { grid in
            if let grid = grid {
                maze = MazeGenerator2(grid: grid)
                isFinished = false
                multipeerManager.opponentWon = false
                multipeerManager.skillSlots = [nil, nil]
                position = !multipeerManager.isHost ? guestStart : hostStart
                multipeerManager.sendPosition(position)
                multipeerManager.receivedRestartGrid = nil
                
                firstGuide = true
                secondGuide = false
                thirdGuide = false
                fourthGuide = false
                showGame = false
            }
        }
        .onChange(of: multipeerManager.receivedRestartRequest) { requested in
            guard requested else { return }
            multipeerManager.receivedRestartRequest = false
            if multipeerManager.isHost {
                restartGame()
            }
        }
        .onChange(of: position) { _ in
            checkPickupCollection()
        }
        .onChange(of: multipeerManager.swapPosition) { newPos in
            if let newPos = newPos {
                withAnimation(.spring()) {
                    position = newPos
                }
                multipeerManager.sendPosition(position)
                multipeerManager.swapPosition = nil
            }
        }
        .onChange(of: multipeerManager.gameReady) { ready in
            if ready {
                if multipeerManager.isHost {
                    position = hostStart
                } else {
                    position = guestStart
                }
                multipeerManager.sendPosition(position)
                SoundManager.shared.play("gamestart")
            }
        }
        .onChange(of: isFinished) { finished in
            if finished { SoundManager.shared.play("winner") }
        }
        .onChange(of: multipeerManager.opponentWon) { lost in
            if lost { SoundManager.shared.play("gameover") }
        }
        .sheet(isPresented: $showPeerSheet) {
            PeerListSheetView(multipeerManager: multipeerManager, showPeerSheet: $showPeerSheet)
                .presentationDetents([.medium])
        }
        .alert("Invitation Received",
               isPresented: $multipeerManager.showInviteAlert) {
            Button("Accept") { multipeerManager.acceptInvitation() }
            Button("Decline", role: .cancel) { multipeerManager.declineInvitation() }
        } message: {
            Text("\(multipeerManager.pendingInvitePeerName ?? "Someone") wants to play with you")
        }
    }

    private func restartGame() {
        firstGuide = true
        secondGuide = false
        thirdGuide = false
        fourthGuide = false
        showGame = false
        
        if multipeerManager.isHost {
            let newMaze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
            maze = newMaze
            isFinished = false
            multipeerManager.opponentWon = false
            multipeerManager.skillSlots = [nil, nil]
            
            let (fog, swap, freeze) = generatePickups(from: newMaze, count: 4)
            multipeerManager.fogPickups = fog
            multipeerManager.swapPickups = swap
            multipeerManager.freezePickups = freeze
            
            position = hostStart
            multipeerManager.sendRestart(newMaze.grid)
            multipeerManager.sendPickups(fog: fog, swap: swap, freeze: freeze)
            multipeerManager.sendPosition(position)
        } else {
            isFinished = false
            multipeerManager.opponentWon = false
            multipeerManager.skillSlots = [nil, nil]
            position = guestStart
            multipeerManager.sendPosition(position)
            multipeerManager.sendRestartRequest()
        }
    }

    private func generatePickups(from maze: MazeGenerator2, count: Int) -> ([SkillPickup], [SkillPickup], [SkillPickup]) {
        var openTiles: [SkillPickup] = []
        for row in 1..<maze.rows-1 {
            for col in 1..<maze.cols-1 {
                if !maze.isWall(row: row, col: col) && !maze.isFinish(row: row, col: col)
                    && !(row == 1 && col == 1) && !(row == 1 && col == maze.cols-2) {
                    openTiles.append(SkillPickup(row: row, col: col))
                }
            }
        }
        openTiles.shuffle()
        let fog = Array(openTiles.prefix(count))
        let swap = Array(openTiles.dropFirst(count).prefix(count))
        let freeze = Array(openTiles.dropFirst(count*2).prefix(count))
        return (fog, swap, freeze)
    }

    private func checkPickupCollection() {
        guard multipeerManager.gameReady else { return }
        let row = pixelToRow(pixel: position.y)
        let col = pixelToCol(pixel: position.x)

        if multipeerManager.fogPickups.contains(where: { $0.row == row && $0.col == col }),
           multipeerManager.skillSlots.contains(nil) {
            multipeerManager.fogPickups.removeAll { $0.row == row && $0.col == col }
            multipeerManager.assignSkill(.fog)   // puts .fog into the first nil slot
            multipeerManager.sendPickupCollected(skillType: .fog, row: row, col: col)
        }

        if multipeerManager.swapPickups.contains(where: { $0.row == row && $0.col == col }),
           multipeerManager.skillSlots.contains(nil) {
            multipeerManager.swapPickups.removeAll { $0.row == row && $0.col == col }
            multipeerManager.assignSkill(.swap)  // puts .swap into the first nil slot
            multipeerManager.sendPickupCollected(skillType: .swap, row: row, col: col)
        }
        
        if multipeerManager.freezePickups.contains(where: { $0.row == row && $0.col == col }),
           multipeerManager.skillSlots.contains(nil) {
            multipeerManager.freezePickups.removeAll { $0.row == row && $0.col == col }
            multipeerManager.assignSkill(.freeze)  // puts .swap into the first nil slot
            multipeerManager.sendPickupCollected(skillType: .freeze, row: row, col: col)
        }
    }
    

}

#Preview {
    ContentView()
}


