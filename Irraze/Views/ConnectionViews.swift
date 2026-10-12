import SwiftUI
import MultipeerConnectivity

struct ConnectionToolbarView: View {
    @ObservedObject var network: MultipeerManager
    @State private var showPeerSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(network.isConnected ? "CLICK HERE TO DISCONNECT" : "CLICK HERE TO CONNECT")
                .font(.pixel(7))
                .fontWeight(.bold)
                .foregroundColor(network.isConnected ? .red : .white.opacity(0.75))

            HStack {
                Button {
                    haptic()
                    if network.isConnected {
                        network.disconnect()
                    } else {
                        network.startBrowsing()
                        showPeerSheet = true
                    }
                } label: {
                    Rectangle()
                        .fill(Constants.catridgeColor)
                        .frame(width: 200, height: 25)
                        .shadow(color: .black, radius: 0, x: 5, y: 5)
                }

                Spacer()

                Circle()
                    .fill(network.isConnected ? Color.green : Color.orange)
                    .frame(width: 30, height: 30)
                    .shadow(color: .black, radius: 0, x: 5, y: 5)
            }
        }
        .padding(.leading, 25)
        .padding(.trailing, 50)
        .sheet(isPresented: $showPeerSheet) {
            PeerListSheetView(network: network)
                .presentationDetents([.medium])
        }
        .alert("Invitation Received", isPresented: $network.showInviteAlert) {
            Button("Accept") { network.acceptInvitation() }
            Button("Decline", role: .cancel) { network.declineInvitation() }
        } message: {
            Text("\(network.pendingInvitePeerName ?? "Someone") wants to play with you")
        }
    }
}

struct PeerListSheetView: View {
    @ObservedObject var network: MultipeerManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Group {
                if network.discoveredPeers.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Searching for nearby players...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(network.discoveredPeers, id: \.displayName) { peer in
                        Button {
                            network.invitePeer(peer)
                            dismiss()
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
                        network.stopBrowsing()
                        dismiss()
                    }
                }
            }
        }
    }
}
