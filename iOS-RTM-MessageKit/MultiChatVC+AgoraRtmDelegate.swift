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
        if let msgKitMessage = MessageKitMessage(basicMessage: message) {
            self.addNewMessage(message: msgKitMessage)
            return
        }
        let data = Data(message.text.utf8)
        if message.type == .text,
           let json = try? JSONSerialization.jsonObject(
            with: data, options: []
           ) as? [String: Any] {
            // we have a json object
            guard let senderJson = json["sender"] as? [String: String],
                  let displayName = senderJson["display_name"],
                  let senderId = senderJson["sender_id"],
                  let type = json["type"] as? String,
                  let body = json["body"] as? String
            else { return }
            let sender = Sender(senderId: senderId, displayName: displayName)
            switch type {
            case "status":
                self.statusUpdate(from: sender, newStatus: body)
            case "raise_hand":
                self.raiseHand(for: sender, flag: body == "true")
            default:
                print("unknown type \(type)")
            }
        }

    }
    func channel(_ channel: AgoraRtmChannel, imageMessageReceived message: AgoraRtmImageMessage, from member: AgoraRtmMember) {
        var requestId = Int64.random(in: Int64.min...Int64.max)
        channel.kit.downloadMedia(toMemory: message.mediaId, withRequest: &requestId) { (request, imageData, errcode) in
            if let imgData = imageData, let img = UIImage(data: imgData) {
                let mediaItem = ImageMediaItem(image: img)
                guard let (sender, sentDate, messageId) = MessageKitMessage.getProperties(from: message.text) else {
                    return
                }
                let message = MessageKitMessage(sender: sender, messageId: messageId, sentDate: sentDate, kind: .photo(mediaItem))
                self.addNewMessage(message: message)
            } else {
                print("bad image upload: \(errcode.rawValue)")
            }
        }
    }

    func channel(_ channel: AgoraRtmChannel, memberJoined member: AgoraRtmMember) {
        self.sendStatus(to: member)
    }
    func channel(_ channel: AgoraRtmChannel, memberLeft member: AgoraRtmMember) {
        if let offlineUser = self.usersLookup[member.userId] {
            self.statusUpdate(from: offlineUser.userDetails, newStatus: .offline)
        }
    }
    func sendStatus(to member: AgoraRtmMember) {
        print(self.localUser.statusRTMMessage.text)
        self.rtmKit?.send(self.localUser.statusRTMMessage, toPeer: member.userId, completion: { sentErr in
            if sentErr != .ok {
                print("status to member send failed \(sentErr.rawValue)")
            }
        })
    }
    func sendStatus(to channel: AgoraRtmChannel) {
        channel.send(self.localUser.statusRTMMessage) { sentErr in
            if sentErr != .errorOk {
                print("status to channel send failed \(sentErr.rawValue)")
            }
        }
    }
}
