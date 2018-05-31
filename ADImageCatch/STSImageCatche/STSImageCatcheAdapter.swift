//
//  STSImageCatcheAdapter.swift
//  ADImageCatch
//
//  Created by Apple on 5/14/18.
//  Copyright © 2018 Apple. All rights reserved.
//
import UIKit
import Foundation

class ImagCatcheAdapter: NSObject, URLSessionDownloadDelegate {
    
    private var imageCacheTaskID = [String:UIImage]()
    private var imageDefault:UIImage = #imageLiteral(resourceName: "demoImage")
    private var imageCacheURL = [String:UIImage]()
    private var imagePath = [String:String]()
    private var session : URLSession!
    
    override init() {
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    func getImage(url: String, imageView: UIImageView, defaultImage: UIImage) {
        if let img = imageCacheURL[url] {
            imageView.image = img
        } else {
            let request: URLRequest = URLRequest(url: URL(string: url)!)
            session.dataTask(with: request) { (data, response, error) in
                if error == nil {
                    let image = UIImage(data: data!)
                    self.imageCacheURL[url] = image
                    DispatchQueue.main.async {
                        imageView.image  = image
                    }
                }
                else {
                    imageView.image = defaultImage
                }
            }.resume()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        print("downloadTask - \(downloadTask.taskIdentifier)")
        let data = try! Data(contentsOf: location)
        let image = UIImage(data: data)
        let imageName  = self.saveImageToFolder(image: image!, folderName: "ImageCatche", fileType: ".png")
        self.imagePath[String(describing:  downloadTask.currentRequest?.url)] = imageName
        self.imageCacheTaskID[String(describing:  downloadTask.currentRequest?.url)] = self.getImageFromFolder(named: imageName, folderName: "ImageCatche", defaultImage: imageDefault)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("downloading \(downloadTask.taskIdentifier)")
    }

    func createFolderImageCatche() {
       _ = URL.createFolder(folderName: "ImageCatche")
       _ = URL.createFolder(folderName: "Thumbnail")
    }

// MARK: - Save & get image from device
    
    // Save Image by folder name
    func saveImageToFolder1(image: UIImage, folderName: String, fileType: String) -> String{
        let imageData   = NSData(data: UIImagePNGRepresentation(image)!)
        let fileName    = NSUUID().uuidString + fileType
        if let filePath = Bundle.main.path(forResource: fileName, ofType: nil, inDirectory: folderName) {
            _ = imageData.write(toFile: filePath, atomically: true)
            return fileName
        }
        return ""
    }
    
    // Save Image by folder name
    func saveImageToFolder(image: UIImage, folderName: String, fileType: String) -> String{
        let imageData  = NSData(data: UIImagePNGRepresentation(image)!)
        let paths      = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,  FileManager.SearchPathDomainMask.userDomainMask, true)
        let docs       = paths[0] as NSString
        let uuid       = NSUUID().uuidString + fileType
        let fullPath   =  docs.appendingPathComponent("\(folderName)/\(uuid)")
        _ = imageData.write(toFile: fullPath as String, atomically: true)
        return uuid
    }
    
    
    // Save Image to default file path
    func saveImage(image: UIImage, fileType: String) -> String{
        let imageData = NSData(data: UIImagePNGRepresentation(image)!)
        let paths     = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,  FileManager.SearchPathDomainMask.userDomainMask, true)
        let docs      = paths[0] as NSString
        let uuid      = NSUUID().uuidString + fileType
        let fullPath  = docs.appendingPathComponent(uuid)
        _ = imageData.write(toFile: fullPath, atomically: true)
        return uuid
    }
    
    // Get Image from default file path
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    // Get Image from folder file path
    func getImageFromFolder(named: String,folderName: String, defaultImage: UIImage) -> UIImage {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let folderPath = dir.appendingPathComponent(folderName)
            return UIImage(contentsOfFile: URL(fileURLWithPath: folderPath.absoluteString).appendingPathComponent(named).path)!
        }
        return defaultImage
    }

    // Get name all images from folder
    func loadImagesFromAlbum(folderName:String) -> [String]{
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        var theItems = [String]()
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(folderName)
            
            do {
                theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
                
                return theItems
            } catch let error as NSError {
                print(error.localizedDescription)
                return theItems
            }
        }
        return theItems
    }
}

extension URL {
    
    // Create folder
    static func createFolder(folderName: String) -> URL? {
        let fileManager          = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath         = documentDirectory.appendingPathComponent(folderName)
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                    
                    return nil
                }
            }
            return filePath
        } else {
            return nil
        }
    }
}
