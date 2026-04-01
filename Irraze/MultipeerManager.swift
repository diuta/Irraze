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
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var isConnected = false
    @Published var isHost = true
    @Published var roleDecided = false
    @Published var gameReady = false
    @Published var remotePosition: CGPoint? = nil
    @Published var receivedMazeGrid: [[Bool]]? = nil
    @Published var opponentWon: Bool = false
    @Published var receivedRestartGrid: [[Bool]]? = nil
    
    @Published var isFogged: Bool = false
    @Published var swapPosition: CGPoint? = nil
    @Published var isFrozen: Bool = false
    @Published var fogPickups: [SkillPickup] = []
    @Published var swapPickups: [SkillPickup] = []
    @Published var freezePickups: [SkillPickup] = []

    @Published var skillSlots: [SkillType?] = [nil, nil]
    @Published var receivedRestartRequest: Bool = false

    @Published var discoveredPeers: [MCPeerID] = []
    @Published var isBrowsing = false

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
        isHost = true
        roleDecided = true
        statusText = "Connecting..."
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        // Do NOT stop browsing here — stopping the browser immediately after inviting
        // cancels the underlying transport before the invite is delivered.
        // Browsing is stopped in the session delegate once connected.
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
        isFogged = false
        swapPosition = nil
        isFrozen = false
        fogPickups = []
        swapPickups = []
        freezePickups = []
        skillSlots = [nil, nil]   // clear both button slots
        connectedPeerName = nil
        statusText = "Not Connected"
        discoveredPeers = []
        opponentWon = false
        receivedRestartRequest = false

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
        send(.gameOver)
    }

    func sendRestartRequest() {
        guard isConnected else { return }
        send(.restartRequest)
    }

    func sendRestart(_ grid: [[Bool]]) {
        guard isConnected else { return }
        let message = PlayerMessage.restart(grid: grid)
        send(message)
    }

    func sendFogOfWar() {
        guard isConnected else { return }
        send(.fogOfWar)
    }

    func sendSwap(myPosition: CGPoint) {
        guard isConnected else { return }
        send(.swap(x: Double(myPosition.x), y: Double(myPosition.y)))
    }
    
    func sendFreeze() {
        guard isConnected else { return }
        send(.freeze)
    }

    func sendPickups(fog: [SkillPickup], swap: [SkillPickup], freeze: [SkillPickup]) {
        guard isConnected else { return }
        send(.pickups(fog: fog, swap: swap, freeze: freeze))
    }

    func sendPickupCollected(skillType: SkillType, row: Int, col: Int) {
        guard isConnected else { return }
        send(.pickupCollected(skillType: skillType, row: row, col: col))
    }

    func assignSkill(_ skill: SkillType) {
        if let freeIndex = skillSlots.firstIndex(where: { $0 == nil }) {
            skillSlots[freeIndex] = skill
        }
    }

    func clearSkillSlot(_ index: Int) {
        guard index < skillSlots.count else { return }
        skillSlots[index] = nil
    }

    private func send(_ message: PlayerMessage) {
        
        guard let data = try? encoder.encode(message),
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
                self.browser.stopBrowsingForPeers()
                self.isBrowsing = false
                self.discoveredPeers = []
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
        guard let message = try? decoder.decode(PlayerMessage.self, from: data) else { return }
        DispatchQueue.main.async {
            switch message {
            case .position(let x, let y):
                self.remotePosition = CGPoint(x: x, y: y)
            case .maze(let grid):
                self.receivedMazeGrid = grid
                self.gameReady = true
            case .gameOver:
                self.opponentWon = true
            case .restart(let grid):
                self.receivedRestartGrid = grid
                self.opponentWon = false
            case .fogOfWar:
                self.isFogged = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isFogged = false
                }
            case .swap(let x, let y):
                self.swapPosition = CGPoint(x: x, y: y)
            case .freeze:
                self.isFrozen = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.isFrozen = false
                }
            case .pickups(let fog, let swap, let freeze):
                self.fogPickups = fog
                self.swapPickups = swap
                self.freezePickups = freeze
            case .pickupCollected(let skillType, let row, let col):
                switch skillType {
                case .fog: self.fogPickups.removeAll    { $0.row == row && $0.col == col }
                case .swap: self.swapPickups.removeAll   { $0.row == row && $0.col == col }
                case .freeze: self.freezePickups.removeAll { $0.row == row && $0.col == col }
                }
            case .restartRequest:
                self.receivedRestartRequest = true
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
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
