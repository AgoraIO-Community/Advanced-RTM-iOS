//
//  ViewController.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 26/02/2021.
//

import UIKit

class MainNavigationVC: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pushViewController(ViewController(), animated: false)
    }
}

class ViewController: UIViewController {

    /// UITextField where the user will enter the channel to join
    lazy var channelField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "channel-name"
        tf.borderStyle = .roundedRect
        tf.text = "test"
        return tf
    }()
    /// UITextField where the user will enter the channel to join
    lazy var usernameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "username"
        tf.borderStyle = .roundedRect
        tf.text = "ipad"
        return tf
    }()


    // Button to join/leave channels
    lazy var submitButton: UIButton = {
        let btn = UIButton(type: .roundedRect)
        btn.setTitle("Join", for: .normal)
        btn.backgroundColor = .secondarySystemBackground
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(joinChannels), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        placeFields()
        self.view.backgroundColor = .systemBackground
    }

    func placeFields() {
        [self.channelField, self.usernameField, self.submitButton]
            .enumerated().forEach { (idx, field) in
                self.view.addSubview(field)
                field.translatesAutoresizingMaskIntoConstraints = false
                field.centerYAnchor.constraint(
                    equalTo: self.view.safeAreaLayoutGuide.centerYAnchor,
                    constant: -75 + 50 * CGFloat(idx)
                ).isActive = true
                field.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
                field.widthAnchor.constraint(equalToConstant: 200).isActive = true
                field.heightAnchor.constraint(equalToConstant: 45).isActive = true
            }
    }

    @objc func joinChannels() {
        guard let channelName = self.channelField.text,
              let username = self.usernameField.text,
              !channelName.isEmpty, !username.isEmpty else {
            return
        }
        self.navigationController?.pushViewController(MultiChatVC(username: username, channel: channelName), animated: true)
    }

}

