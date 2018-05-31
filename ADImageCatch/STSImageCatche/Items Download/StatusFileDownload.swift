//
//  StatusFileDownload.swift
//  ADImageCatch
//
//  Created by Apple on 5/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

enum StatusFileDownload {
    case DownloadItemStatusNotStarted
    case DownloadItemStatusStarted
    case DownloadItemStatusCompleted
    case DownloadItemStatusPaused
    case DownloadItemStatusCancelled
    case DownloadItemStatusInterrupted
    case DownloadItemStatusExisted
    case DownloadItemStatusPending
    case DownloadItemStatusError
    case DownloadItemStatusTimeOut
}

enum StatusButtonDownload {
    case DownloadButtonStatusDownload
    case DownloadButtonStatusPlay
    case DownloadButtonStatusPause
}

enum StatusConnection {
    case ConnectionTypeUnknown
    case ConnectionTypeNone
    case ConnectionType2G
    case ConnectionType3G
    case ConnectionType4G
    case ConnectionTypeWiFi
}

