//
//  DownloadCollectionCell.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 10/03/2021.
//

import UIKit

class DownloadCollectionCell: UICollectionViewCell {
    var titleLabel: UILabel?
    var imageView: UIImageView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: 25, height: 25)))
        self.addSubview(self.imageView!)
        self.titleLabel = UILabel(frame: frame)
        self.layer.cornerRadius = 20
        self.layer.cornerCurve = .continuous
        self.titleLabel?.frame = CGRect(x: 10, y: 10, width: frame.width - 20, height: frame.height - 20)
        titleLabel?.textAlignment = .center
        self.titleLabel?.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.titleLabel?.contentMode = .scaleToFill
        self.titleLabel?.numberOfLines = 0
        self.addSubview(self.titleLabel!)
        self.backgroundColor = .systemGray
//        self.backgroundColor = .blue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
