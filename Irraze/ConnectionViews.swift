import SwiftUI
import MultipeerConnectivity

struct ConnectionToolbarView: View {
    @ObservedObject var multipeerManager: MultipeerManager
    @Binding var showPeerSheet: Bool
    let onDisconnect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(multipeerManager.isConnected ? "CLICK HERE TO DISCONNECT" : "CLICK HERE TO CONNECT")
                .font(.custom("PressStart2P-Regular", size: 7))
                .fontWeight(.bold)
                .foregroundColor(!multipeerManager.isConnected ? .white.opacity(0.75) : .red)
            
            HStack {
                if multipeerManager.isConnected {
                    Button {
                        haptic()
                        onDisconnect()
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
}

struct PeerListSheetView: View {
    @ObservedObject var multipeerManager: MultipeerManager
    @Binding var showPeerSheet: Bool
    
    var body: some View {
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
    }
}
