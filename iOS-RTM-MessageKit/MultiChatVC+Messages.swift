//
//  MultiChatVC+Messages.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 03/03/2021.
//

import UIKit
import AgoraRtmKit
import MessageKit
import InputBarAccessoryView

extension MultiChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

    func setupMessagesView() {
        self.messageKitVC = RTMChatViewController()
        messageKitVC.messagesCollectionView.messagesDataSource = self
        messageKitVC.messagesCollectionView.messagesLayoutDelegate = self
        messageKitVC.messagesCollectionView.messagesDisplayDelegate = self
        messageKitVC.subviewInputBar.delegate = self
        messageKitVC.willMove(toParent: self)
        self.addChild(messageKitVC)
        self.pages.messages.addSubview(messageKitVC.subviewInputBar)
        self.pages.messages.addSubview(messageKitVC.view)
        messageKitVC.keyboardManager.bind(inputAccessoryView: messageKitVC.subviewInputBar)
        messageKitVC.view.translatesAutoresizingMaskIntoConstraints = false
        messageKitVC.view.topAnchor.constraint(equalTo: self.pages.messages.topAnchor).isActive = true
        messageKitVC.view.bottomAnchor.constraint(equalTo: messageKitVC.subviewInputBar.topAnchor).isActive = true
        messageKitVC.view.leadingAnchor.constraint(equalTo: self.pages.messages.leadingAnchor).isActive = true
        messageKitVC.view.trailingAnchor.constraint(equalTo: self.pages.messages.trailingAnchor).isActive = true
    }

    func currentSender() -> SenderType {
        return self.localUser.userDetails
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        self.messageList[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        self.messageList.count
    }

    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].sender.displayName == self.messageList[indexPath.section - 1].sender.displayName
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? 30 : 0
        }
    }
}

extension MultiChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.inputTextView.resignFirstResponder()
        self.insertMessages(components)
    }

    internal func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
                let message = MessageKitMessage(
                    sender: self.currentSender(),
                    messageId: UUID().uuidString, sentDate: .init(), kind: .text(str)
                )
                self.addNewMessage(message: message)
                <#Send text based message over RTM#>
            } else if let img = component as? UIImage {
                let mediaItem = ImageMediaItem(image: img)
                let message = MessageKitMessage(sender: self.currentSender(), messageId: UUID().uuidString, sentDate: .init(), kind: .photo(mediaItem))
                self.addNewMessage(message: message)
                <#Write image to file, then send over RTM#>
            }
        }
    }

    func addNewMessage(message: MessageKitMessage) {
        self.messageList.append(message)
        self.messageKitVC.messagesCollectionView.performBatchUpdates({
            self.messageKitVC.messagesCollectionView.insertSections(
                [self.messageList.count - 1]
            )
            if self.messageList.count >= 2 {
                self.messageKitVC.messagesCollectionView.reloadSections(
                    [self.messageList.count - 2]
                )
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messageKitVC.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })

    }
    func isLastSectionVisible() -> Bool {
        guard !self.messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: self.messageList.count - 1)
        return self.messageKitVC.messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

}

