//
//  MultiChatVC.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 09/03/2021.
//

import UIKit
import MessageKit
import AgoraRtmKit

class MultiChatVC: UIViewController {

    static var sessionID: String = UUID().uuidString

    // MARK: Agora RTM and General
    var username: String
    var channel: String
    var rtmKit: AgoraRtmKit?
    var rtmChannel: AgoraRtmChannel?
    var localUser: RTMUser!
    var pageHeaders: [String] = ["Messages", "Members", "Downloads"]
    var pages: (messages: UIView, members: UIView, downloads: UIView) = (UIView(), UIView(), UIView())
    var pagesArr: [UIView] {
        [pages.messages, pages.members, pages.downloads]
    }

    // MARK: MessageKit
    var messageKitVC: RTMChatViewController!
    lazy var messageList: [MessageType] = []

    // MARK: Members
    var connectedUsers: [RTMUser] = []
    var offlineUsers: [RTMUser] = []
    var usersLookup: [String: RTMUser] = [:]
    var membersTable: UITableView?
    lazy var raiseHandButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .red // .secondarySystemFill
        btn.setTitle("Raise Hand", for: .normal)
        btn.layer.cornerRadius = 10
        btn.layer.cornerCurve = .continuous
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.addTarget(self, action: #selector(self.raiseHandPressed), for: .touchUpInside)
        return btn
    }()

    lazy var uploadFileButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .red // .secondarySystemFill
        btn.setTitle("Upload File", for: .normal)
        btn.layer.cornerRadius = 10
        btn.layer.cornerCurve = .continuous
        btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        btn.addTarget(self, action: #selector(self.uploadFile), for: .touchUpInside)
        return btn
    }()

    // MARK: Downloads
    struct DownloadableFileData {
        var filename: String
        var downloadID: String
    }

    var downloadsTable: UICollectionView?
    var downloadFiles: [DownloadableFileData] = []
    var previewItem: URL?
    func rtmLogin() {
        self.rtmKit = AgoraRtmKit(appId: <#Agora App ID#>, delegate: self)
        self.rtmKit?.login(byToken: nil, user: self.localUser.userDetails.senderId, completion: { loginCode in
            if loginCode == .ok {
                self.rtmChannel = self.rtmKit?.createChannel(withId: self.channel, delegate: self)
                self.rtmChannel?.join(completion: self.channelJoined(joinCode:))
            }
        })
    }

    func channelJoined(joinCode: AgoraRtmJoinChannelErrorCode) {
        if joinCode == .channelErrorOk {
            print("connected to channel")
            self.localUser.status = .online
            self.connectedUsers.insert(self.localUser, at: 0)
            self.usersLookup[self.localUser.userDetails.senderId] = self.localUser
            self.rtmChannel?.send(self.localUser.statusRTMMessage) { sentErr in
                if sentErr != .errorOk {
                    print("status to channel send failed \(sentErr.rawValue)")
                }
            }
            self.membersTable?.reloadData()
        }
    }

    init(username: String, channel: String) {
        self.username = username
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        self.localUser = RTMUser(
            userDetails: Sender(senderId: MultiChatVC.sessionID, displayName: self.username),
            handRaised: false,
            status: .offline
        )
    }

    func setupBaseUI() {
        self.view.backgroundColor = .systemBackground
        let segController = UISegmentedControl(items: self.pageHeaders)
        segController.addTarget(self, action: #selector(changeSegment), for: .valueChanged)
        self.navigationItem.titleView = segController
        self.navigationItem.hidesBackButton = true

        let newBackButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(self.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton

        for page in [pages.messages, pages.members, pages.downloads] {
            self.view.addSubview(page)
            page.translatesAutoresizingMaskIntoConstraints = false
            page.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            page.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            page.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            page.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            page.backgroundColor = .systemBackground
        }
        segController.selectedSegmentIndex = 0

    }

    @objc func changeSegment(sender: UISegmentedControl) {
        for (idx, page) in self.pagesArr.enumerated() {
            page.isHidden = idx != sender.selectedSegmentIndex
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupBaseUI()
        setupMessagesView()
        setupMembersView()
        setupDownloadsView()
        self.rtmLogin()
        self.pages.downloads.isHidden = true
        self.pages.members.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    @objc func back(sender: UIBarButtonItem) {
        self.rtmChannel?.leave()
        self.rtmKit?.logout()
        _ = navigationController?.popViewController(animated: true)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
