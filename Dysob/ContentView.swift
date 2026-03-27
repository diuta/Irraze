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
        GeometryReader { geo in
            Image("bmo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ZStack(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
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
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(.white)
                                Text("Waiting for opponent...")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .shadow(radius: 30)
                        }
                        
                        if isFinished || multipeerManager.opponentWon {
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
                    .offset(x:-63)
                }
                .offset(x: 185, y: 200)
                
                connectionToolbar
                    .offset(y: 465)
                
                UserInput(
                    maze: $maze,
                    position: $position,
                    isFinished: $isFinished,
                    multipeerManager: multipeerManager
                )
                .offset(x: -10, y:533)
                
            }
        }
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
            if multipeerManager.isConnected {
                Button {
                    multipeerManager.disconnect()
                } label: {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.2)
                        .frame(width: 210, height: 25)
                }
                .padding(.leading, 25)
            } else {
                Button {
                    multipeerManager.startBrowsing()
                    showPeerSheet = true
                } label: {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.2)
                        .frame(width: 200, height: 25)
                }
                .padding(.leading, 25)
//                .padding(.bottom, 10)
//                .background(Color.red)
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Circle()
                    .fill(multipeerManager.isConnected ? Color.green : Color.orange)
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 50)
            }
        }
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
