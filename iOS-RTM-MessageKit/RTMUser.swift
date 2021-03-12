//
//  RTMPresenceMessage.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 02/03/2021.
//

import AgoraRtmKit

class RTMUser {
    internal init(userDetails: Sender, handRaised: Bool = false, status: RTMUser.Status) {
        self.userDetails = userDetails
        self.handRaised = handRaised
        self.status = status
    }
    
    enum Status: String {
        case online
        case offline
    }
    var userDetails: Sender
    var handRaised: Bool = false
    var status: Status
    private func rtmMessage(type: String) -> AgoraRtmMessage {
        var messageJson: [String: Any] = [
            "sender": self.userDetails.toJSON(),
            "type": type
        ]
        switch type {
        case "status":
            messageJson["body"] = self.status.rawValue
        case "raise_hand":
            messageJson["body"] = handRaised.description
        default: break
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: messageJson, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        return AgoraRtmMessage(text: decoded)
    }
    var statusRTMMessage: AgoraRtmMessage {
        self.rtmMessage(type: "status")
    }
    var raiseHandRTMMessage: AgoraRtmMessage {
        self.rtmMessage(type: "raise_hand")
    }
}
