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

    init() {
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
}

