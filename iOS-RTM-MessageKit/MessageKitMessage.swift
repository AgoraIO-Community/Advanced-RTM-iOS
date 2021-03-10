//
//  MessageKitMessage.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 02/03/2021.
//

import Foundation
import AgoraRtmKit
import MessageKit

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

extension SenderType {
    public func toJSON() -> [String: String] {
        ["display_name": self.displayName, "sender_id": self.senderId]
    }
}

public struct MessageKitMessage: MessageType {
    public var sender: SenderType

    public var messageId: String

    public var sentDate: Date

    public var kind: MessageKind

    static func getProperties(from text: String) -> (sender: Sender, sentData: Date, messageId: String)? {
        let data = Data(text.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(
                    with: data, options: []) as? [String: Any],
                  let sender = json["sender"] as? [String: String],
                  let displayName = sender["display_name"],
                  let senderId = sender["sender_id"],
                  let messageId = json["message_id"] as? String,
                  let timestamp = json["timestamp"] as? String,
                  let sentDate = ISO8601DateFormatter().date(from: timestamp)
            else { return nil }
            return (
                Sender(senderId: senderId, displayName: displayName),
                sentDate,
                messageId
            )
        } catch let err as NSError {
            print("ERROR COULD NOT DECODE \(err)")
            print(text)
        }
        return nil
    }

    func generateMessageText() -> String {
        var rtmMessage: [String: Any] = [
            "sender": self.sender.toJSON(),
            "message_id": self.messageId,
            "timestamp": ISO8601DateFormatter().string(from: self.sentDate)
        ]
        switch self.kind {
        case .attributedText(let str):
            rtmMessage["type"] = "text"
            rtmMessage["body"] = str.string
        case .text(let str):
            rtmMessage["type"] = "text"
            rtmMessage["body"] = str
//            return AgoraRtmMessage(text: str)
        case .photo(_):
            rtmMessage["type"] = "photo"
        default:
            print("no conversion for type: \(kind)")
        }
        let jsonData = try! JSONSerialization.data(withJSONObject: rtmMessage, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        return decoded
    }

    func toRTM() -> AgoraRtmMessage? {
        return AgoraRtmMessage(text: self.generateMessageText())
    }
    public init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    public init?(image: AgoraRtmImageMessage) {
        return nil
    }
    public init?(basicMessage: AgoraRtmMessage) {
        let data = Data(basicMessage.text.utf8)
        do {
            guard let json = try JSONSerialization.jsonObject(
                    with: data, options: []) as? [String: Any],
                  let sender = json["sender"] as? [String: String],
                  let displayName = sender["display_name"],
                  let senderId = sender["sender_id"],
                  let messageId = json["message_id"] as? String,
                  let type = json["type"] as? String,
                  let timestamp = json["timestamp"] as? String,
                  let body = json["body"] as? String,
                  let sentDate = ISO8601DateFormatter().date(from: timestamp)
            else {
                return nil
            }

            var messageKind: MessageKind?
            if type == "text" {
                messageKind = .text(body)
            } else {
                return nil
            }
            self = MessageKitMessage(
                sender: Sender(senderId: senderId, displayName: displayName),
                messageId: messageId, sentDate: sentDate, kind: messageKind!
            )
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return nil
        }
    }
}

