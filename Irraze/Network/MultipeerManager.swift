import Combine
import MultipeerConnectivity
import UIKit

final class MultipeerManager: NSObject, ObservableObject {
    private let serviceType = "irraze-maze"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser

    @Published private(set) var isConnected = false
    @Published private(set) var isHost = true
    @Published private(set) var discoveredPeers: [MCPeerID] = []
    @Published private(set) var pendingInvitePeerName: String?
    @Published var showInviteAlert = false
    private var pendingInviteHandler: ((Bool, MCSession?) -> Void)?

    var onMessage: (PlayerMessage) -> Void = { _ in }
    var onConnectionChange: (Bool) -> Void = { _ in }

    override init() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
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

    func startBrowsing() {
        discoveredPeers = []
        browser.startBrowsingForPeers()
    }

    func stopBrowsing() {
        browser.stopBrowsingForPeers()
        discoveredPeers = []
    }

    func invitePeer(_ peerID: MCPeerID) {
        isHost = true
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }

    func acceptInvitation() {
        isHost = false
        answerInvitation(true)
    }

    func declineInvitation() {
        answerInvitation(false)
    }

    private func answerInvitation(_ accept: Bool) {
        pendingInviteHandler?(accept, accept ? session : nil)
        pendingInviteHandler = nil
        pendingInvitePeerName = nil
        showInviteAlert = false
    }

    func disconnect() {
        session.disconnect()
        isConnected = false
        isHost = true
        discoveredPeers = []
        advertiser.startAdvertisingPeer()
        onConnectionChange(false)
    }

    func send(_ message: PlayerMessage) {
        guard !session.connectedPeers.isEmpty,
              let data = try? JSONEncoder().encode(message) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
}

extension MultipeerManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.isConnected = true
                self.advertiser.stopAdvertisingPeer()
                self.stopBrowsing()
                self.onConnectionChange(true)
            case .notConnected:
                if self.isConnected { self.disconnect() }
            default:
                break
            }
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            guard let message = try? JSONDecoder().decode(PlayerMessage.self, from: data) else { return }
            self.onMessage(message)
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.pendingInvitePeerName = peerID.displayName
            self.pendingInviteHandler = invitationHandler
            self.showInviteAlert = true
        }
    }
}

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
