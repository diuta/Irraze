import Foundation
import Combine
import MultipeerConnectivity
import SwiftUI

class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "dysob-maze"
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser
    private var browser: MCNearbyServiceBrowser

    @Published var isConnected = false
    @Published var isHost = true
    @Published var roleDecided = false
    @Published var gameReady = false
    @Published var remotePosition: CGPoint? = nil
    @Published var receivedMazeGrid: [[Bool]]? = nil
    @Published var opponentWon: Bool = false

    // Discovery
    @Published var discoveredPeers: [MCPeerID] = []
    @Published var isBrowsing = false

    // Invite handling
    @Published var pendingInvitePeerName: String? = nil
    @Published var showInviteAlert = false
    private var pendingInviteHandler: ((Bool, MCSession?) -> Void)? = nil

    @Published var connectedPeerName: String? = nil
    @Published var statusText: String = "Not Connected"

    override init() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)

        super.init()

        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self

        // Start advertising so others can find us, but do NOT auto-browse or auto-invite
        advertiser.startAdvertisingPeer()
    }

    deinit {
        advertiser.stopAdvertisingPeer()
        browser.stopBrowsingForPeers()
        session.disconnect()
    }

    // MARK: - Manual Discovery

    func startBrowsing() {
        discoveredPeers = []
        isBrowsing = true
        browser.startBrowsingForPeers()
    }

    func stopBrowsing() {
        isBrowsing = false
        browser.stopBrowsingForPeers()
        discoveredPeers = []
    }

    // MARK: - Invite

    func invitePeer(_ peerID: MCPeerID) {
        // The device that sends the invite is the host
        isHost = true
        roleDecided = true
        statusText = "Connecting..."
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        stopBrowsing()
    }

    func acceptInvitation() {
        guard let handler = pendingInviteHandler else { return }
        isHost = false
        roleDecided = true
        statusText = "Connecting..."
        handler(true, session)
        pendingInviteHandler = nil
        pendingInvitePeerName = nil
        showInviteAlert = false
    }

    func declineInvitation() {
        pendingInviteHandler?(false, nil)
        pendingInviteHandler = nil
        pendingInvitePeerName = nil
        showInviteAlert = false
    }

    // MARK: - Disconnect

    func disconnect() {
        session.disconnect()
        isConnected = false
        isHost = true
        roleDecided = false
        gameReady = false
        remotePosition = nil
        receivedMazeGrid = nil
        connectedPeerName = nil
        statusText = "Not Connected"
        discoveredPeers = []

        // Re-advertise so others can find us again
        advertiser.startAdvertisingPeer()
    }

    // MARK: - Send

    func sendPosition(_ position: CGPoint) {
        guard isConnected else { return }
        let message = PlayerMessage.position(x: Double(position.x), y: Double(position.y))
        send(message)
    }

    func sendMaze(_ grid: [[Bool]]) {
        guard isConnected else { return }
        let message = PlayerMessage.maze(grid: grid)
        send(message)
        // Host is ready once maze is sent
        DispatchQueue.main.async {
            self.gameReady = true
        }
    }
    
    func sendGameOver() {
        guard isConnected else { return }
        let message = PlayerMessage.gameOver
        send(message)
        DispatchQueue.main.async {
            self.gameReady = true
        }
    }

    private func send(_ message: PlayerMessage) {
        guard let data = try? JSONEncoder().encode(message),
              !session.connectedPeers.isEmpty else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

// MARK: - MCSessionDelegate

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.connectedPeerName = peerID.displayName
                self.statusText = "Connected to \(peerID.displayName)"
                self.advertiser.stopAdvertisingPeer()
                self.stopBrowsing()
            case .notConnected:
                if self.isConnected {
                    // Peer disconnected
                    self.disconnect()
                }
            case .connecting:
                self.statusText = "Connecting..."
            @unknown default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? JSONDecoder().decode(PlayerMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            switch message {
            case .position(let x, let y):
                self.remotePosition = CGPoint(x: x, y: y)
            case .maze(let grid):
                self.receivedMazeGrid = grid
                self.gameReady = true
            case .gameOver:
                self.opponentWon = true
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.pendingInvitePeerName = peerID.displayName
            self.pendingInviteHandler = invitationHandler
            self.showInviteAlert = true
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async {
            if !self.discoveredPeers.contains(where: { $0.displayName == peerID.displayName }) {
                self.discoveredPeers.append(peerID)
            }
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.discoveredPeers.removeAll { $0.displayName == peerID.displayName }
        }
    }
}
