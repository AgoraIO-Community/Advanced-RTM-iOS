//
//  MultiChatVC+Downloads.swift
//  iOS-RTM-MessageKit
//
//  Created by Max Cobb on 09/03/2021.
//

import UIKit
import AgoraRtmKit
import PDFKit
import QuickLook

extension MultiChatVC: UIDocumentPickerDelegate, UICollectionViewDelegate {

    func setupDownloadsView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        let minDim = min(self.view.bounds.size.width, self.view.bounds.size.height)
        layout.itemSize = CGSize(width: minDim / 3.5, height: minDim / 3.5)


        let downloadsColView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        downloadsColView.register(DownloadCollectionCell.self, forCellWithReuseIdentifier: "downloadCell")
        downloadsColView.backgroundColor = UIColor.systemBackground
        downloadsColView.dataSource = self
        downloadsColView.delegate = self
        self.downloadsTable = downloadsColView
        self.pages.downloads.addSubview(downloadsColView)
        downloadsColView.translatesAutoresizingMaskIntoConstraints = false
        downloadsColView.topAnchor.constraint(equalTo: self.pages.downloads.topAnchor).isActive = true
        downloadsColView.leadingAnchor.constraint(equalTo: self.pages.downloads.leadingAnchor).isActive = true
        downloadsColView.trailingAnchor.constraint(equalTo: self.pages.downloads.trailingAnchor).isActive = true
        downloadsColView.bottomAnchor.constraint(equalTo: self.pages.downloads.bottomAnchor, constant: -60).isActive = true

        self.pages.downloads.addSubview(self.uploadFileButton)
        self.uploadFileButton.translatesAutoresizingMaskIntoConstraints = false
        self.uploadFileButton.centerXAnchor.constraint(equalTo: downloadsColView.centerXAnchor).isActive = true
        self.uploadFileButton.bottomAnchor.constraint(equalTo: self.pages.downloads.bottomAnchor, constant: -10).isActive = true
        self.uploadFileButton.topAnchor.constraint(equalTo: downloadsColView.bottomAnchor, constant: 10).isActive = true
        self.uploadFileButton.widthAnchor.constraint(lessThanOrEqualTo: downloadsColView.widthAnchor).isActive = true

    }

    @objc func uploadFile(sender: UIButton) {
        let docsBrowser = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .usdz], asCopy: false)
        docsBrowser.delegate = self
        docsBrowser.allowsMultipleSelection = false
        docsBrowser.shouldShowFileExtensions = true

        self.navigationController?.present(docsBrowser, animated: true)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first,
              url.startAccessingSecurityScopedResource()
        else { return }
        <#Create file message, then send to the channel#>
    }

    func channel(
        _ channel: AgoraRtmChannel,
        fileMessageReceived message: AgoraRtmFileMessage,
        from member: AgoraRtmMember
    ) {
        <#Display file message in downloadsTable#>
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let docsData = self.downloadFiles[indexPath.row]
        <#Download the file, then display it using showFile#>
    }
    func showFile(at url: URL) {
        self.previewItem = url
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        present(previewController, animated: true)
    }
}

extension MultiChatVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.downloadFiles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "downloadCell", for: indexPath) as! DownloadCollectionCell
        let filename = self.downloadFiles[indexPath.row].filename
        cell.titleLabel?.text = filename
        cell.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        if let urlfn = URL(string: filename.replacingOccurrences(of: " ", with: "")) {
            switch urlfn.pathExtension {
            case "usdz": cell.imageView?.image = UIImage(systemName: "arkit")
            default: cell.imageView?.image = UIImage(systemName: "doc")
            }
        } else {
            print("no filename!")
        }
        return cell
    }
}


extension MultiChatVC: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        self.previewItem == nil ? 0 : 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem! as QLPreviewItem
    }

    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        self.previewItem = nil
    }
}
