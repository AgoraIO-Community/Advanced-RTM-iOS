//
//  MultiChatVC+Members.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 03/03/2021.
//

import UIKit.UITableView

extension MultiChatVC: UITableViewDataSource, UITableViewDelegate {

    func setupMembersView() {
        let membersTable = UITableView()
        let membersView = self.pages.members
        membersTable.dataSource = self
        membersTable.delegate = self
        membersTable.register(UITableViewCell.self, forCellReuseIdentifier: "userCell")
        membersView.addSubview(membersTable)
        membersTable.translatesAutoresizingMaskIntoConstraints = false
        membersTable.topAnchor.constraint(equalTo: membersView.topAnchor).isActive = true
        membersTable.leadingAnchor.constraint(equalTo: membersView.leadingAnchor).isActive = true
        membersTable.trailingAnchor.constraint(equalTo: membersView.trailingAnchor).isActive = true
        membersTable.bottomAnchor.constraint(equalTo: membersView.bottomAnchor, constant: -60).isActive = true
        membersTable.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        membersTable.reloadData()
        self.membersTable = membersTable
        membersView.addSubview(self.raiseHandButton)
        self.raiseHandButton.translatesAutoresizingMaskIntoConstraints = false
        self.raiseHandButton.centerXAnchor.constraint(equalTo: membersTable.centerXAnchor).isActive = true
        self.raiseHandButton.bottomAnchor.constraint(equalTo: membersView.bottomAnchor, constant: -10).isActive = true
        self.raiseHandButton.topAnchor.constraint(equalTo: membersTable.bottomAnchor, constant: 10).isActive = true
        self.raiseHandButton.widthAnchor.constraint(lessThanOrEqualTo: membersTable.widthAnchor).isActive = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? self.connectedUsers.count : self.offlineUsers.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        self.offlineUsers.isEmpty ? 1 : 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Online" : "Offline"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        let user: RTMUser
        if indexPath.section == 0 {
            user = self.connectedUsers[indexPath.row]
        } else {
            user = self.offlineUsers[indexPath.row]
        }
        cell.textLabel?.text = user.userDetails.displayName
        if user.userDetails.senderId == self.localUser.userDetails.senderId {
            cell.textLabel?.text! += " (me)"
        }
        if user.handRaised {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "hand.raised.fill"))
        } else {
            cell.accessoryView = nil
        }
        return cell
    }
    func statusUpdate(from sender: Sender, newStatus status: RTMUser.Status) {
        if let senderObj = self.usersLookup[sender.senderId] {
            if senderObj.status == status {
                return
            }
            let oldStatus = senderObj.status

            senderObj.status = status
            if status == .offline {
                self.connectedUsers.removeAll(where: { $0.userDetails.senderId == sender.senderId })
                self.offlineUsers.append(senderObj)
            } else if oldStatus == .offline {
                self.offlineUsers.removeAll(where: { $0.userDetails.senderId == sender.senderId })
                self.connectedUsers.append(senderObj)
            }
        } else if status != .offline {
            let newUser = RTMUser(userDetails: sender, handRaised: false, status: status)
            self.usersLookup[sender.senderId] = newUser
            self.connectedUsers.append(newUser)
        } else {
            return
        }
        self.membersTable?.reloadData()
    }
    func raiseHand(for sender: Sender, flag: Bool) {
        if let senderObj = self.usersLookup[sender.senderId] {
            senderObj.handRaised = flag
        } else {
            let newUser = RTMUser(userDetails: sender, handRaised: flag, status: .online)
            self.usersLookup[sender.senderId] = newUser
            self.connectedUsers.append(newUser)
        }
        self.membersTable?.reloadData()
    }

    @objc func raiseHandPressed(sender: UIButton) {
        self.localUser.handRaised.toggle()
        <#Send raised hand updated to the channel#>
        sender.setTitle((self.localUser.handRaised ? "Lower" : "Raise") + " Hand" , for: .normal)
        self.membersTable?.reloadData()
    }
}

