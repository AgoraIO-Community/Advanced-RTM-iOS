//
//  MultiChatVC+Messages.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 03/03/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

internal struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

    init(imageURL: URL) {
        self.url = imageURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}

extension MultiChatVC: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

    func setupMessagesView() {
        messageKitVC.messagesCollectionView.messagesDataSource = self
        messageKitVC.messagesCollectionView.messagesLayoutDelegate = self
        messageKitVC.messagesCollectionView.messagesDisplayDelegate = self
        messageKitVC.subviewInputBar.delegate = self
        messageKitVC.willMove(toParent: self)
        addChild(messageKitVC)
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
        self.messageKitVC.messageList[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        self.messageKitVC.messageList.count
    }

    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageKitVC.messageList[indexPath.section].sender.displayName == self.messageKitVC.messageList[indexPath.section - 1].sender.displayName
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

    internal func insertMessages(_ data: [Any], send: Bool = true) {
        for component in data {
            var message: MessageKitMessage?
            if let str = component as? String {
                message = MessageKitMessage(
                    sender: self.currentSender(),
                    messageId: UUID().uuidString, sentDate: .init(), kind: .text(str))
                self.addNewMessage(message: message!)
                if send, let msg = message?.toRTM() {
                    self.rtmChannel?.send(msg, completion: { sentCode in
                        if sentCode != .errorOk {
                            print("could not send message")
                        }
                    })
                }
            } else if let img = component as? UIImage {
                let mediaItem = ImageMediaItem(image: img)
                message = MessageKitMessage(sender: self.currentSender(), messageId: UUID().uuidString, sentDate: .init(), kind: .photo(mediaItem))
                self.addNewMessage(message: message!)
                let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                // Download contents of imageURL as Data.  Use a URLSession if you want to do this asynchronously.
                if send, let _ = try? img.pngData()?.write(to: fileURL) {
                    var requestID: Int64 = Int64.random(in: Int64.min...Int64.max)
                    self.rtmKit?.createImageMessage(byUploading: fileURL.path, withRequest: &requestID, completion: { (requestId, imageMsg, errorCode) in
                        if errorCode == .ok, let imageMsg = imageMsg {
//                            message.text = message.
                            imageMsg.text = message?.generateMessageText() ?? ""
                            self.rtmChannel?.send(imageMsg, completion: { (messageSent) in
                                if messageSent != .errorOk {
                                    print(messageSent)
                                }
                            })
                        }
                    })
                }
            }
        }
    }

    func addNewMessage(message: MessageKitMessage) {
        self.messageKitVC.messageList.append(message)
        self.messageKitVC.messagesCollectionView.performBatchUpdates({
            self.messageKitVC.messagesCollectionView.insertSections(
                [self.messageKitVC.messageList.count - 1]
            )
            if self.messageKitVC.messageList.count >= 2 {
                self.messageKitVC.messagesCollectionView.reloadSections(
                    [self.messageKitVC.messageList.count - 2]
                )
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messageKitVC.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })

    }
    func isLastSectionVisible() -> Bool {
        guard !self.messageKitVC.messageList.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: self.messageKitVC.messageList.count - 1)
        return self.messageKitVC.messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

}

