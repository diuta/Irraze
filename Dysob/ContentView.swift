import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    let size: CGFloat = 25
    let spacing: CGFloat = 5
    let maxRowView: Int = 10
    let cameraBoundary: Int = 5

    @StateObject private var multipeerManager = MultipeerManager()
    @State private var maze = MazeGenerator2(rows: 80, cols: 10)
    @State private var position = CGPoint.zero
    @State private var mazeReady = false
    @State private var showPeerSheet = false

    var rows: Int { maze.rows }
    var cols: Int { maze.cols }
    var step: CGFloat { spacing + size }
    var maxX: CGFloat { CGFloat(cols - 1) / 2 * step }
    var maxY: CGFloat { CGFloat(maxRowView - 1) / 2 * step }

    var hostStart: CGPoint {
        CGPoint(x: CGFloat(1) * step - maxX, y: CGFloat(1) * step - maxY)
    }
    var guestStart: CGPoint {
        CGPoint(x: CGFloat(cols - 2) * step - maxX, y: CGFloat(1) * step - maxY)
    }

    var localColor: Color { multipeerManager.isHost ? .blue : .red }
    var remoteColor: Color { multipeerManager.isHost ? .red : .blue }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Toolbar
            connectionToolbar

            Spacer()

            // MARK: - Maze
            ZStack {
                Map(rows: maxRowView, cols: maze.cols, spacing: spacing, size: size)
                Obstacles(maze: maze, size: size, spacing: spacing, maxRowView: maxRowView, cameraBoundary: cameraBoundary, position: position, step: step, maxY: maxY, maxX: maxX)

                if multipeerManager.gameReady {
                    Player(position: position, color: localColor, cameraBoundary: cameraBoundary, step: step, maxY: maxY, maze: maze, maxRowView: maxRowView)

                    if let remotePos = multipeerManager.remotePosition {
                        RemotePlayer(
                            remotePosition: remotePos,
                            localPosition: position,
                            color: remoteColor,
                            cameraBoundary: cameraBoundary,
                            step: step,
                            maxY: maxY,
                            maze: maze,
                            maxRowView: maxRowView
                        )
                    }
                }

                // Waiting overlay
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
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            Spacer()

            // MARK: - Movement Buttons
            HStack(spacing: 10) {
                MovementButtons(label: "←") { move(x: -step, y: 0) }
                VStack(spacing: 10) {
                    MovementButtons(label: "↑") { move(x: 0, y: -step) }
                    MovementButtons(label: "↓") { move(x: 0, y: step) }
                }
                MovementButtons(label: "→") { move(x: step, y: 0) }
            }
            .opacity(multipeerManager.gameReady ? 1.0 : 0.4)
        }
        .onAppear {
            maze.forceOpen(row: 1, col: maze.cols - 2)
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

    // MARK: - Connection Toolbar

    private var connectionToolbar: some View {
        HStack {
            // Status indicator
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
        .background(Color(.systemGray6))
    }

    // MARK: - Peer List Sheet

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

    // MARK: - Movement

    func move(x: CGFloat, y: CGFloat) {
        guard multipeerManager.gameReady else { return }

        let newRow = Int((position.y + y + maxY) / step)
        let newCol = Int((position.x + x + maxX) / step)

        guard newRow >= 0, newRow < rows,
              newCol >= 0, newCol < cols,
              !maze.isWall(row: newRow, col: newCol) else { return }

        position.x += x
        position.y += y
        multipeerManager.sendPosition(position)
    }
}

#Preview {
    ContentView()
}
