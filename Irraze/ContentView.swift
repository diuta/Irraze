import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @StateObject private var multipeerManager = MultipeerManager()
    @State private var maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
    @State private var position = CGPoint.zero
    @State private var showPeerSheet = false
    @State private var isFinished = false
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
                                VStack{
                                    Text("RACE TO THE FINISH LINE !!")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .onAppear {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                                showGame = true
                                            }
                                        }
                                    Text("(AT THE BOTTOM)")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                                .padding(.top, geo.size.height * 0.15)
                            } else {
                                Map(maze: maze)
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
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .padding(.top, geo.size.height * 0.15)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 0)
                        }
                        
                        if (isFinished || multipeerManager.opponentWon) && multipeerManager.gameReady {
                            VStack(spacing: 16){
                                if isFinished {
                                    Text("YOU WIN!")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
                                } else {
                                    Text("YOU LOSE!")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 0)
                                }
                                
                                Button {
                                    haptic()
                                    restartGame()
                                } label: {
                                    Text("Try Again")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 32)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(Constants.catridgeColor))
                                                .shadow(color: .black, radius: 0, x: 4, y: 4)
                                        )
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, geo.size.height * 0.10)
                
                connectionToolbar
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
                
            } else if !connected {
                isFinished = false
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
            peerListSheet
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
    
    private var connectionToolbar: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(multipeerManager.isConnected ? "DISCONNECT" : "CONNECT TO ANOTHER PLAYER")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(!multipeerManager.isConnected ? .white.opacity(0.75) : .red)
            
            HStack {
                if multipeerManager.isConnected {
                    Button {
                        haptic()
                        multipeerManager.disconnect()
                        maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
                        position = hostStart
                        isFinished = false
                        multipeerManager.opponentWon = false
                    } label: {
                        Rectangle()
                            .fill(Color(Constants.catridgeColor))
                            .frame(width: 200, height: 25)
                            .shadow(color: .black, radius: 0, x: 5, y: 5)
                    }
                } else {
                    Button {
                        haptic()
                        multipeerManager.startBrowsing()
                        showPeerSheet = true
                    } label: {
                        ZStack{
                            Rectangle()
                                .fill(Color(Constants.catridgeColor))
                                .frame(width: 200, height: 25)
                                .shadow(color: .black, radius: 0, x: 5, y: 5)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(multipeerManager.isConnected ? Color.green : Color.orange)
                        .frame(width: 30, height: 30)
                        .shadow(color: .black, radius: 0, x: 5, y: 5)
                }
            }
        }
        .padding(.leading, 25)
        .padding(.trailing, 50)
    }

    private var peerListSheet: some View {
        NavigationView {
            Group {
                if multipeerManager.discoveredPeers.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Searching for nearby players...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(multipeerManager.discoveredPeers, id: \.displayName) { peer in
                        Button {
                            multipeerManager.invitePeer(peer)
                            showPeerSheet = false
                        } label: {
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.blue)
                                Text(peer.displayName)
                                Spacer()
                                Image(systemName: "arrow.right.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Nearby Players")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        multipeerManager.stopBrowsing()
                        showPeerSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ContentView()
}
