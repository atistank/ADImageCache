//
//  ViewController.swift
//  ADImageCatch
//
//  Created by Apple on 5/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import LinearProgressBar
import CoreTelephony

class DemoViewController: UIViewController {

    @IBOutlet weak var viewButtom: UIView!
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTaskResume: UILabel!
    @IBOutlet weak var lblPending: UILabel!
    @IBOutlet weak var lblDownloading: UILabel!
    @IBOutlet weak var vTableview: UITableView!
    
//MARK:- Properties
    var resultApi       = [photoAPI]()
    var imageList       = [UIImage]()
    let session         = URLSession(configuration: .default)
    let STSimageCatche  = ImagCatcheAdapter()
    var downloadService = DownloadService.share
    var cellObjects     = [String:DownloadCellObject]()
    var fileNameCell    = [String]()
    let networkInfo     = CTTelephonyNetworkInfo()
    
//MARK:- Lifeclyle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        checkNetworking { (status) in
            
            // Limit Download Task
            switch status {
            case .ConnectionTypeWiFi:
                self.downloadService.currentDownloadMaximum = 3
            case .ConnectionType3G:
                self.downloadService.currentDownloadMaximum = 1
            case .ConnectionType4G:
                self.downloadService.currentDownloadMaximum = 2
            case .ConnectionTypeNone:
                self.downloadService.currentDownloadMaximum = 0
            case .ConnectionTypeUnknown:
                self.downloadService.currentDownloadMaximum = 1
            case .ConnectionType2G:
                self.downloadService.currentDownloadMaximum = 1
            }
        }
        fetchJson()
    }

    func setUI() {
        vTableview.delegate            = self
        vTableview.dataSource          = self
        vTableview.separatorStyle      = .none
        cellimage.delegate = self
        // Create folder save image
        let ImageCatchePath = URL.createFolder(folderName: "ImageCatche")
        let documentsURL    = try! FileManager().url(for: .documentDirectory,
                                                  in: .userDomainMask,
                                                  appropriateFor: nil,
                                                  create: true)
        let fooURL     = documentsURL.appendingPathComponent("ImageCatche")
        let fileExists = FileManager().fileExists(atPath: fooURL.path)
        
        viewNavigation.layer.cornerRadius      = 5
        viewNavigation.clipsToBounds           = false
        viewNavigation.layer.shadowOpacity     = 0.1
        viewNavigation.layer.shadowColor       = UIColor.black.cgColor
        viewNavigation.layer.shadowOffset      = CGSize(width: 0, height: 0)
        viewNavigation.layer.shadowRadius      = 6
        viewButtom.layer.cornerRadius          = 5
        viewButtom.clipsToBounds               = false
        viewButtom.layer.shadowOpacity         = 0.1
        viewButtom.layer.shadowColor           = UIColor.black.cgColor
        viewButtom.layer.shadowOffset          = CGSize(width: 0, height: 0)
        viewButtom.layer.shadowRadius          = 6
        print("Check Folder Exists: \(fileExists)")
        print("Folder Path: \(ImageCatchePath!)")
    }
}

//MARK:- Fetch Data
extension DemoViewController {
    
    func fetchJson(){
        if let result = loadJson(filename: "jSon") {
            self.resultApi.append(contentsOf: result)
            _ = resultApi.map{
                let url = URL(string: $0.url)
                let cellObject = DownloadCellObject(urlPhoto: url!, identifier: 0, taskName: (url?.lastPathComponent)!, taskStatus: StatusFileDownload.DownloadItemStatusNotStarted, process: 0, taskDetail: "", totalBytes: 0, totalbyteRecives: 0, filePath: "", fileName: "", image: #imageLiteral(resourceName: "ic_default"))
                cellObjects[String(describing: cellObject.urlPhoto)] = cellObject
                let fileName = url?.lastPathComponent
                fileNameCell.append(fileName!)
            }
            for _ in 0...resultApi.count-1 {
                self.imageList.append(#imageLiteral(resourceName: "demoImage"))
            }
        }
    }
    
    func loadJson(filename fileName: String) -> [photoAPI]? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            do {
                let data     = try Data(contentsOf: url)
                let decoder  = JSONDecoder()
                let jsonData = try decoder.decode(Array<photoAPI>.self, from: data)
                return jsonData
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
}

//MARK: - Tableview
extension DemoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !resultApi.isEmpty {
            return resultApi.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell                 = tableView.dequeueReusableCell(withIdentifier: "cell") as! ImageTableViewCell
        let url                  = resultApi[indexPath.row].url
        cell.delegate            = self
        cell.lblUrl.text         = resultApi[indexPath.row].url
        cell.lblNetworking.text  = fileNameCell[indexPath.row]
        cell.setModel(model: cellObjects[url]! )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122.0
    }
}

//MARK: - Download Parse
extension DemoViewController: TrackCellDelegate {
    
    func resumeTapped(_cell: ImageTableViewCell, identifier: Int) {
        downloadService.resumeDownload(identifier: identifier)
    }
    
    func pauseTapped(_ cell: ImageTableViewCell, identifier: Int) {
        downloadService.pauseDownload(identifier: identifier) { (downloadItem) in
            self.updateCell(item: downloadItem, cell, filePath: downloadItem.filePath)
        }
    }
    
    func downloadTapped(_ cell: ImageTableViewCell) {
        if let indexPath = vTableview.indexPath(for: cell) {
            if resultApi.count > 0 {
                let imageApi = resultApi[indexPath.row]
                let queue    = DispatchQueue.main
                downloadService.startDownloadFileFromURL(sourceURL: imageApi.url, informationFile: { (downloadFileItem) -> () in
                    self.updateCell(item: downloadFileItem, cell, filePath: downloadFileItem.filePath)
                }, queue: queue)
            } else {
                print("error \(resultApi.count)")
            }
        } else {
            print("not found cell")
        }
    }
}

//MARK: - Reload Update UI Cell
extension DemoViewController {
    
    func reload(_ row: Int) {
        vTableview.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    
    func updateCell(item:DownloadItem, _ cell: ImageTableViewCell, filePath: String) {
        if cellObjects.count == 0 { return }
        let cellObject: DownloadCellObject  = cellObjects[item.sourceURL]!
        cellObject.identifier               = item.identifier
        let status: StatusFileDownload      = item.downloadItemStatus
        if vTableview.indexPath(for: cell) == nil { return }
        let indexpath: IndexPath = vTableview.indexPath(for: cell)!
        let cell = vTableview.cellForRow(at: indexpath) as! ImageTableViewCell
        
        lblDownloading.text   = "Downloading: \(downloadService.currentActiveDownloadTasks)"
        lblPending.text       = "Task Pending: \(downloadService.pendingDownloadTasks)"
        lblTaskResume.text    = "Task Resume: \(downloadService.resumeDownloadTasks)"
        
        if status == .DownloadItemStatusCompleted {
            cellObject.taskStatus  = .DownloadItemStatusCompleted
            cellObject.filePath    = filePath
            cellObject.fileName    = item.fileName
            cellObject.image       = item.image
            DispatchQueue.main.async {
                cell.setModel(model: cellObject)
            }
        } else if status == .DownloadItemStatusPaused {
            cellObject.taskStatus  = .DownloadItemStatusPaused
            DispatchQueue.main.async {
                cell.setModel(model: cellObject)
            }
        } else if status == .DownloadItemStatusCancelled {
            cellObject.taskStatus  = .DownloadItemStatusCancelled
            DispatchQueue.main.async {
                cell.setModel(model: cellObject)
            }
        } else if status == .DownloadItemStatusPending {
            cellObject.taskStatus  = .DownloadItemStatusPending
            DispatchQueue.main.async {
                cell.setModel(model: cellObject)
            }
        } else if status == .DownloadItemStatusTimeOut {
            cellObject.taskStatus  = .DownloadItemStatusTimeOut;
            DispatchQueue.main.async {
                cell.setModel(model: cellObject)
            }
        } else {
            // status is Started Download
            let progress                = Float(item.totalbyteRecives) / Float(item.totalBytes)
            let second                  = self.TimeLeft(startDate: item.startDate, byesTransferred: item.totalbyteRecives, totalByteExpectedToWrite: item.totalBytes)
            let formatByteWritten       = ByteCountFormatter.string(fromByteCount: item.totalbyteRecives, countStyle: ByteCountFormatter.CountStyle.file)
            let formartBytesExpected    = ByteCountFormatter.string(fromByteCount: item.totalBytes, countStyle: ByteCountFormatter.CountStyle.file)
            let detailInfor             = String(format: "%.0f%% - %@ / %@ - About: %@", progress * 100, formatByteWritten,formartBytesExpected,self.timeFormartted(totalSecond: Int(second)))
            cellObject.filePath         = filePath
            cellObject.totalbyteRecives = item.totalbyteRecives
            cellObject.totalBytes       = item.totalBytes
            cellObject.taskDetail       = detailInfor
            cellObject.process          = progress
            cellObject.taskStatus       = .DownloadItemStatusStarted
            DispatchQueue.main.async {
                cell.setModel(model: cellObject)
            }
        }
    }
}

//MARK: - Formart Time
extension DemoViewController {
    
    func TimeLeft(startDate: Date, byesTransferred: Int64 , totalByteExpectedToWrite: Int64) -> Float {
        let timeInterval     = CFDateGetTimeIntervalSinceDate(Date() as CFDate, startDate as CFDate)
        let speed            = Float(byesTransferred) / Float(timeInterval)
        let remainingBytes   = totalByteExpectedToWrite - byesTransferred
        let timeLeft         = Float(remainingBytes) / speed
        return timeLeft
    }
    
    func timeFormartted(totalSecond: Int) -> String {
        let seconds  = totalSecond % 60
        let minutes  = ( totalSecond / 60 ) % 60
        let hours    = totalSecond / 3600
        if hours > 0 {
            return String(format: "%02dh:%02dm:%02ds",hours,minutes,seconds)
        } else if minutes > 0 {
            return String(format: "%02dm:%02ds",minutes,seconds)
        } else {
            return String(format: "%02ds",seconds)
        }
    }
}


