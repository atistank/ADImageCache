//
//  DownloadService.swift
//  ADImageCatch
//
//  Created by Apple on 5/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

class DownloadService: NSObject {
   
// MARK: - Properties
    private var session: URLSession!
    static  let share = DownloadService()
    private let list                               = ListDownloading.share
    private var imageApdater                       = ImagCatcheAdapter()
    private var arrNextItems                       = [DownloadItem]()
    private var arrPauseItems                      = [DownloadItem]()
    private var fileExistsForURL                   = [String:String]()
    public  var currentActiveDownloadTasks         = 0
    public  var pendingDownloadTasks               = 0
    public  var resumeDownloadTasks                = 0
    public  var currentDownloadMaximum             = 1
    private var removeItemQueue                    = DispatchQueue(label: "removeItemQueue")
    private var createDirectoryQueue               = DispatchQueue(label: "createDirectoryQueue")
    
    private override init() {
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
    }
    
// MARK: - Start Download File
    func startDownloadFileFromURL(sourceURL: String, informationFile: ((DownloadItem) -> ())?,  queue: DispatchQueue) {
        if sourceURL == fileExistsForURL[sourceURL] {
            print("File Exits")
        } else if completeDownload(sourceURL: sourceURL) == false {
            print("File is Downloading.....")
        } else {
            print("Start Download File")
            let urlRequest = URLRequest(url: URL(string: sourceURL)!)
            let downloadTask: URLSessionDownloadTask  = session.downloadTask(with: urlRequest)
            let downloadFileItem = DownloadItem(downloadTask: downloadTask, callbackQueue: queue, infoFileDownloadBlock: informationFile!)
                downloadFileItem.startDate            = Date()
                downloadFileItem.fileName             = URL(string: sourceURL)!.lastPathComponent
                downloadFileItem.downloadItemStatus   = .DownloadItemStatusPending
                downloadFileItem.sourceURL            = sourceURL
                downloadFileItem.identifier           = downloadFileItem.downloadTask.taskIdentifier
            
            // Check maximum task download
            if currentActiveDownloadTasks >= currentDownloadMaximum {
                pendingDownloadTasks += 1
                arrNextItems.append(DownloadItem(downloadTask: downloadTask, callbackQueue: queue, infoFileDownloadBlock: informationFile!))
            } else {
                currentActiveDownloadTasks += 1;
                print("Start Download")
                downloadFileItem.downloadTask.resume()
            }
            list.addNewDownload(object: downloadFileItem)
            
            // callback to update UI
            if downloadFileItem.infoFileDownloadBlock != nil {
                DispatchQueue.main.async {
                    downloadFileItem.infoFileDownloadBlock!(downloadFileItem)
                }
            }
          
        }
    }

// MARK: - Pause Download
func pauseDownload(identifier: Int,  informationFile: ((DownloadItem) -> ())?) {
        let downloadItems = list.getAllList()
        let downloadFileItem = downloadItems.filter { $0.identifier == identifier }[0]
        switch downloadFileItem.downloadItemStatus {
        case .DownloadItemStatusPending:
              pendingDownloadTasks -= 1
        case .DownloadItemStatusStarted:
              currentActiveDownloadTasks -= 1
            downloadFileItem.downloadTask.suspend()
        default:
            print("default downloadFileItem status")
        }
        downloadFileItem.downloadItemStatus = .DownloadItemStatusPaused
        resumeDownloadTasks += 1
        if downloadFileItem.infoFileDownloadBlock != nil {
            DispatchQueue.main.async {
                downloadFileItem.infoFileDownloadBlock!(downloadFileItem)
            }
        }
        if pendingDownloadTasks > 0 && currentActiveDownloadTasks < currentDownloadMaximum {
            if arrNextItems.count > 0 {
                if downloadFileItem.downloadItemStatus == .DownloadItemStatusPending {
                    arrNextItems[0] = downloadFileItem
                    return
                }
                arrNextItems[0].downloadTask.resume()
                arrNextItems.remove(at: 0)
                currentActiveDownloadTasks += 1
                pendingDownloadTasks -= 1
            }
        }
    }
    
    // MARK: - Resume Download
    func resumeDownload(identifier: Int) {
        let DownloadItem = list.getAllList()
        let downloadFileItem = DownloadItem.filter { $0.identifier == identifier }[0]
        if resumeDownloadTasks > 0 {
            if currentActiveDownloadTasks >= currentDownloadMaximum {
                if downloadFileItem.downloadItemStatus == .DownloadItemStatusNotStarted {
                    currentActiveDownloadTasks -= 1
                    arrPauseItems[0] = downloadFileItem
                    return
                }
                arrPauseItems[0].downloadItemStatus = .DownloadItemStatusPaused
                arrPauseItems[0].downloadTask.suspend()
                resumeDownloadTasks += 1
                DispatchQueue.main.async {
                    self.arrPauseItems[0].infoFileDownloadBlock!(self.arrPauseItems[0])
                }
                
            }
            // resume task
            downloadFileItem.downloadItemStatus = .DownloadItemStatusStarted
            downloadFileItem.downloadTask.resume()
            currentActiveDownloadTasks += 1
            resumeDownloadTasks -= 1
        }
    }
}

// MARK: - Helper function
extension DownloadService {
    
    // get Path of url
    func cachesDirectoryUrlPath() -> URL {
        let paths             = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let cachesDirectory   = paths[0]
        let urlPath           =  URL(fileURLWithPath: cachesDirectory)
        return urlPath
    }
    
    // Check Condition
    func completeDownload(sourceURL: String) -> Bool {
        var check = true
        let resultlist = list.getAllList()
        if  resultlist.contains(where: {$0.sourceURL == sourceURL}) {
            check = false
        }
        return check
    }
    
    func getDownloadSize(url: URL, completion: @escaping (Int64, Error?) -> Void) {
        let timeoutInterval = 5.0
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            let contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            completion(contentLength, error)
            }.resume()
    }
}


// MARK: - Download Session Delegate
extension DownloadService: URLSessionDelegate,URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        // Downloading
        let identifier            = downloadTask.taskIdentifier
        let downloadItems         = list.getAllList()
        let downloadingItemFirst  = downloadItems.filter { $0.identifier == identifier }[0]
        
        if downloadingItemFirst.downloadItemStatus == .DownloadItemStatusPending { downloadingItemFirst.downloadItemStatus = .DownloadItemStatusStarted }
        downloadingItemFirst.byteRecives           = bytesWritten
        downloadingItemFirst.totalBytes            = totalBytesExpectedToWrite
        downloadingItemFirst.totalbyteRecives      = totalBytesWritten
        print("totalBytesWritten \(identifier) - \(totalBytesWritten)")
        if downloadingItemFirst.infoFileDownloadBlock != nil {
            DispatchQueue.main.async {
                downloadingItemFirst.infoFileDownloadBlock!(downloadingItemFirst)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        //Download finished
        let identifier            = downloadTask.taskIdentifier
        let downloadItems         = list.getAllList()
        let downloadingItemFirst  = downloadItems.filter { $0.identifier == identifier }[0]
        var localFilePath: URL
        
        if downloadingItemFirst.directoryName != "" {
            localFilePath = self.cachesDirectoryUrlPath().appendingPathComponent(downloadingItemFirst.directoryName).appendingPathComponent(downloadingItemFirst.fileName)
        } else {
            localFilePath = self.cachesDirectoryUrlPath().appendingPathComponent("ImageCatche").appendingPathComponent(downloadingItemFirst.fileName)
        }
        downloadingItemFirst.filePath = String(describing: localFilePath)
        removeItemQueue.sync {
            let fileManager = FileManager.default
            try? fileManager.moveItem(at: location, to: localFilePath)
        }
        downloadingItemFirst.image = imageApdater.getImageFromFolder(named: downloadingItemFirst.fileName, folderName: "ImageCatche", defaultImage: #imageLiteral(resourceName: "ic_default"))
        if downloadingItemFirst.infoFileDownloadBlock != nil {
            downloadingItemFirst.downloadItemStatus = .DownloadItemStatusCompleted
            currentActiveDownloadTasks -= 1
            DispatchQueue.main.async {
                downloadingItemFirst.infoFileDownloadBlock!(downloadingItemFirst)
                self.list.removeObject(object: downloadingItemFirst)
            }
        }
        
        if pendingDownloadTasks > 0 && currentActiveDownloadTasks < currentDownloadMaximum {
            if arrNextItems.count > 0 {
                if downloadingItemFirst.downloadItemStatus == .DownloadItemStatusPending {
                    arrNextItems[0] = downloadingItemFirst
                    return
                }
                arrNextItems[0].downloadTask.resume()
                arrNextItems.remove(at: 0)
                currentActiveDownloadTasks += 1
                pendingDownloadTasks -= 1
            }
        }
    }
}
