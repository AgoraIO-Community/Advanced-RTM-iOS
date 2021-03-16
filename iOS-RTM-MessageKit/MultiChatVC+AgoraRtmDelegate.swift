//
//  MultiChatVC+AgoraRtmDelegate.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 03/03/2021.
//

import AgoraRtmKit
import UIKit

extension MultiChatVC: AgoraRtmChannelDelegate, AgoraRtmDelegate {

    func rtmKit(_ kit: AgoraRtmKit, messageReceived message: AgoraRtmMessage, fromPeer peerId: String) {
        self.handleMessageReceived(message: message)
    }
    func channel(_ channel: AgoraRtmChannel, messageReceived message: AgoraRtmMessage, from member: AgoraRtmMember) {
        self.handleMessageReceived(message: message)
    }
    func handleMessageReceived(message: AgoraRtmMessage) {
        <#First check if this is a valid MessageKitMessage#>

        <#Then check if the message is a status update, or raised hand#>
    }
    func channel(_ channel: AgoraRtmChannel, imageMessageReceived message: AgoraRtmImageMessage, from member: AgoraRtmMember) {
        <#Download image, add it to MessageKit#>
    }

    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        <#Send local user status to the new member#>
    }
    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        <#Set status for member who just left#>
    }

}
