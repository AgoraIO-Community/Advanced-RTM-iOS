//
//  RTMChatViewController.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 26/02/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AgoraRtmKit

class RTMChatViewController: MessagesViewController {

    public var keyboardManager = KeyboardManager()

    public let subviewInputBar = InputBarAccessoryView()

    init(username: String) {
        super.init(nibName: nil, bundle: nil)
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    lazy var messageList: [MessageType] = [
//        RTMMessage(sender: Sender(senderId: "Bob", displayName: "Bob"), messageId: "123", sentDate: .init(), kind: .text("test")),
//        RTMMessage(sender: Sender(senderId: "Bob", displayName: "Bob"), messageId: "123", sentDate: .init(), kind: .text("test")),
//        RTMMessage(sender: Sender(senderId: "dasfsdfdfs", displayName: "Bob4"), messageId: "123", sentDate: .init(), kind: .text("test"))
    ]
}

