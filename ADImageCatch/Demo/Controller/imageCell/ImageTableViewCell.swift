//
//  ImageTableViewCell.swift
//  ADImageCatch
//
//  Created by Apple on 5/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

protocol TrackCellDelegate {
    func downloadTapped(_ cell: ImageTableViewCell)
    func pauseTapped(_ cell: ImageTableViewCell, identifier: Int)
    func resumeTapped(_cell: ImageTableViewCell, identifier: Int)
}


class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var ivCheckResume: UIImageView!
    @IBOutlet weak var lblTimeLeft: UILabel!
    @IBOutlet weak var lblNetworking: UILabel!
    @IBOutlet weak var lblDownloadProgress: UILabel!
    @IBOutlet weak var vProgress: UIProgressView!
    @IBOutlet weak var lblUrl: UILabel!
    @IBOutlet weak var ivImage: UIImageView!
    @IBOutlet weak var lblImageType: UILabel!
    @IBOutlet weak var btnDownload: UIButton!
    var statusButton: StatusButtonDownload = .DownloadButtonStatusDownload
    var model: DownloadCellObjectProtocol?
    var delegate : TrackCellDelegate?
    var imageApater = ImagCatcheAdapter()
    var taskIdentifier: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    @IBAction func downloadAction(_ sender: Any) {
        switch statusButton {
        case .DownloadButtonStatusDownload:
             delegate?.downloadTapped(self)
        case .DownloadButtonStatusPause:
             delegate?.pauseTapped(self, identifier: taskIdentifier)
        case .DownloadButtonStatusPlay:
            delegate?.resumeTapped(_cell: self, identifier: taskIdentifier)
        }
    }
    
    func updateDisplay(progress: Float,totalBytes: Int64, BytesReviced: Int64) {
        vProgress.progress = progress
    }
    
    func shouldUpdateCellWithModel(object: DownloadCellObjectProtocol) {
        let cellObject : DownloadCellObject = object as! DownloadCellObject
        ivImage.image                   = cellObject.image
        lblDownloadProgress.alpha       = 0
        taskIdentifier                  = cellObject.identifier
        if cellObject.taskStatus == .DownloadItemStatusNotStarted {
            btnDownload.setImage(#imageLiteral(resourceName: "ic_playDownload"), for: .normal)
            btnDownload.isHidden        = false
            vProgress.alpha             = 0
            ivCheckResume.alpha         = 0
            lblImageType.text           = "State: Ready"
            statusButton                = .DownloadButtonStatusDownload
        }
        if cellObject.taskStatus == .DownloadItemStatusCompleted {
            btnDownload.isHidden        = true
            lblImageType.text           = "State: Download Completed"
            vProgress.alpha             = 1
            ivCheckResume.alpha         = 0
            lblDownloadProgress.alpha   = 0
            statusButton                = .DownloadButtonStatusDownload
        }
        if cellObject.taskStatus == .DownloadItemStatusPending {
            btnDownload.setImage(#imageLiteral(resourceName: "ic_pending"), for: .normal)
            lblImageType.text           = "State: File Pending..."
            vProgress.alpha             = 0
            lblDownloadProgress.alpha   = 0
            ivCheckResume.alpha         = 0
            statusButton                = .DownloadButtonStatusPause
        }
        if cellObject.taskStatus == .DownloadItemStatusPaused {
            btnDownload.setImage(#imageLiteral(resourceName: "ic_playDownload"), for: .normal)
            btnDownload.isHidden        = false
            lblImageType.text           = "State: Paused"
            ivCheckResume.alpha         = 1
            lblDownloadProgress.alpha   = 1
            vProgress.alpha             = 1
            statusButton                = .DownloadButtonStatusPlay
        }
        if cellObject.taskStatus == .DownloadItemStatusStarted {
            btnDownload.setImage(#imageLiteral(resourceName: "ic_pause"), for: .normal)
            btnDownload.isHidden        = false
            lblImageType.text           = "State: Start Download"
            lblDownloadProgress.alpha   = 1
            vProgress.alpha             = 1
            ivCheckResume.alpha         = 1
            statusButton                = .DownloadButtonStatusPause
        }
        lblUrl.text                     = String(describing: cellObject.urlPhoto)
        lblTimeLeft.text                = cellObject.taskDetail
    }

    func setModel(model: DownloadCellObjectProtocol) {
        self.model = model
        self.model?.identifier = model.identifier
        updateProgress(progress: model.process)
        updateDisplay(progress: model.process,totalBytes: model.totalBytes,BytesReviced: model.totalbyteRecives)
        shouldUpdateCellWithModel(object: model)
    }
    
    func updateProgress(progress: CFloat) {
        self.vProgress.progress = progress
    }
    
}
