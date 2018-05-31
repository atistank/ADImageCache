//
//  Download.swift
//  ADImageCatch
//
//  Created by Apple on 5/15/18.
//  Copyright © 2018 Apple. All rights reserved.
//
import UIKit
import Foundation
class DownloadCellObject: NSObject,DownloadCellObjectProtocol {

    init(urlPhoto: URL,identifier: Int,taskName: String,taskStatus: StatusFileDownload,process: Float,taskDetail:String, totalBytes: Int64, totalbyteRecives: Int64,filePath: String,fileName: String,image: UIImage) {
        self.urlPhoto          = urlPhoto
        self.identifier        = identifier
        self.taskName          = taskName
        self.taskStatus        = taskStatus
        self.process           = process
        self.taskDetail        = taskDetail
        self.totalbyteRecives  = totalbyteRecives
        self.totalBytes        = totalBytes
        self.filePath          = filePath
        self.fileName          = fileName
        self.image             = image
    }
    
    // Download service sets these values:
    var urlPhoto:         URL
    var identifier:       Int
    var taskName:         String
    var process:          Float
    var taskStatus:       StatusFileDownload
    var taskDetail:       String
    var totalBytes:       Int64
    var totalbyteRecives: Int64
    var filePath:         String
    var fileName:         String
    var image :           UIImage
}


protocol DownloadCellObjectProtocol {
    
    // Download service sets these values:
    var urlPhoto:    URL {get set}
    var identifier:  Int {get set}
    var taskName:    String {get set}
    var process:     Float {get set}
    var taskStatus:  StatusFileDownload {get set}
    var taskDetail: String {get set}
    var totalBytes: Int64 {get}
    var totalbyteRecives: Int64 {get}
    var filePath: String {get set}
    var fileName: String { get set}
    var image: UIImage {get set}
}
