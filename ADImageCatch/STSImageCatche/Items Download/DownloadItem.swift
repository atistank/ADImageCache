//
//  DownloadItems.swift
//  ADImageCatch
//
//  Created by Apple on 5/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit

class DownloadItem: NSObject {
    
    var downloadTask       : URLSessionDownloadTask
    var directoryName      : String
    var identifier         : Int
    var sourceURL          : String
    var fileName           : String
    var startDate          : Date
    var byteRecives        : Int64
    var totalbyteRecives   : Int64
    var totalBytes         : Int64
    var filePath           : String
    var image              : UIImage
    var callbackQueue      : DispatchQueue
    var downloadItemStatus : StatusFileDownload
    var infoFileDownloadBlock:((DownloadItem) -> ())?
    
    init(downloadTask : URLSessionDownloadTask,callbackQueue: DispatchQueue, infoFileDownloadBlock: ((DownloadItem) -> ())?) {
        self.totalBytes = 0
        self.byteRecives = 0
        self.totalbyteRecives = 0
        self.callbackQueue = callbackQueue
        self.downloadTask = downloadTask
        self.infoFileDownloadBlock = infoFileDownloadBlock
        self.identifier = 0
        self.directoryName = ""
        self.sourceURL = ""
        self.fileName = ""
        self.startDate = Date()
        self.downloadItemStatus = .DownloadItemStatusNotStarted
        self.filePath = ""
        self.image = #imageLiteral(resourceName: "ic_default")
    }
}
