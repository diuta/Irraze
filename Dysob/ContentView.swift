import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @StateObject private var multipeerManager = MultipeerManager()
    @State private var maze = MazeGenerator2(rows: Constants.rows, cols: Constants.cols)
    @State private var position = CGPoint.zero
    @State private var mazeReady = false
    @State private var showPeerSheet = false
    @State private var isFinished = false

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
        VStack(spacing: 0) {
            ZStack {
                Map(maze: maze)
                Obstacles(maze: maze, position: position)

                if multipeerManager.gameReady {
                    Player(maze: maze, position: position, color: localColor)

                    if let remotePos = multipeerManager.remotePosition {
                        RemotePlayer(
                            remotePosition: remotePos,
                            localPosition: position,
                            color: remoteColor,
                            maze: maze
                        )
                    }
                }
                
                if !multipeerManager.gameReady {
                    Color.black.opacity(0.5)
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.white)
                        Text("Waiting for opponent...")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                
                if isFinished || multipeerManager.opponentWon {
                    Color.black.opacity(0.5)
                    VStack{
                        if isFinished {
                            Text("YOU WIN!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            Text("YOU LOSE!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .frame(width: 350, height: 330)
            .background(Color(Constants.screenColor))
            .padding(.top, 30)
            
            Spacer()

            connectionToolbar
            
            Spacer()
            
//            HStack() {
//                HStack(spacing: 0) {
//                    MovementButtons(label: "", width: 50, height: 40) { move(x: -Constants.step, y: 0) }
//                    VStack(spacing: 0) {
//                        MovementButtons(label: "", width: 40, height: 60) { move(x: 0, y: -Constants.step) }
//                        MovementButtons(label: "", width: 40, height: 60) { move(x: 0, y: Constants.step) }
//                    }
//                    MovementButtons(label: "", width: 50, height: 40) { move(x: Constants.step, y: 0) }
//                }
//            }
//            .padding(.bottom, 30)
//            .shadow(radius: 10)
            UserInput(
                maze: $maze,
                position: $position,
                isFinished: $isFinished,
                multipeerManager: multipeerManager
            )
        }
        .background(Color(Constants.bodyColor))
        .onAppear {
            position = hostStart
            mazeReady = true
        }
        .onChange(of: multipeerManager.isConnected) { connected in
            if connected && multipeerManager.isHost {
                multipeerManager.sendMaze(maze.grid)
            }
        }
        .onChange(of: multipeerManager.receivedMazeGrid) { grid in
            if let grid = grid {
                maze = MazeGenerator2(grid: grid)
                position = guestStart
            }
        }
        .onChange(of: multipeerManager.gameReady) { ready in
            if ready {
                if multipeerManager.isHost {
                    position = hostStart
                } else {
                    position = guestStart
                }
            }
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

    private var connectionToolbar: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(multipeerManager.isConnected ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(multipeerManager.statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if multipeerManager.isConnected {
                Button("Disconnect") {
                    multipeerManager.disconnect()
                }
                .font(.caption)
                .foregroundColor(.red)
            } else {
                Button("Find Players") {
                    multipeerManager.startBrowsing()
                    showPeerSheet = true
                }
                .font(.caption.bold())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(Constants.secondaryBodyColor))
    }
    
//    private var connectionToolbar: some View {
//        HStack {
//            if multipeerManager.isConnected {
//                Button("Disconnect") {
//                    multipeerManager.disconnect()
//                }
//                .font(.caption)
//                .foregroundColor(.red)
//            } else {
//                Button("Find Players") {
//                    multipeerManager.startBrowsing()
//                    showPeerSheet = true
//                }
//                .font(.caption.bold())
//            }
//            
//            Spacer()
//            
//            HStack(spacing: 6) {
//                Circle()
//                    .fill(multipeerManager.isConnected ? Color.green : Color.orange)
//                    .frame(width: 8, height: 8)
//            }
//        }
//        .padding(.horizontal, 50)
//        .padding(.vertical, 8)
//    }



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


//    func move(x: CGFloat, y: CGFloat) {
//        guard multipeerManager.gameReady else { return }
//
//        let newRow = pixelToRow(pixel: position.y + y)
//        let newCol = pixelToCol(pixel: position.x + x)
//
//        guard newRow >= 0, newRow < rows,
//              newCol >= 0, newCol < cols,
//              !maze.isFinish(
//                row: pixelToRow(pixel: position.y),
//                col: pixelToCol(pixel: position.x)
//              ),
//              !maze.isWall(row: newRow, col: newCol) else { return }
//
//        position.x += x
//        position.y += y
//        multipeerManager.sendPosition(position)
//
//        isFinished = maze.isFinish(row: newRow, col: newCol)
//        
//        if isFinished {
//            multipeerManager.sendGameOver()
//        }
//    }
}

#Preview {
    ContentView()
}
