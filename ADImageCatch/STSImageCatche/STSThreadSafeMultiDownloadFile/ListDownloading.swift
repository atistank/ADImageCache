//
//  ListDownloading.swift
//  ADImageCatch
//
//  Created by Apple on 5/16/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
class ListDownloading {
    
    // Properties
    private var listDownloadQueue = [DownloadItem]()
    private var queue = DispatchQueue(label: "ListDownloadingQueue")
    static var share = ListDownloading()
    
    // Init
    private init() {
    }
    
    // Add Object
    func getAllList() -> [DownloadItem]{
        return listDownloadQueue
    }
    
    // Add Object
    func addNewDownload(object: DownloadItem?) {
        if object == nil {
            print("Object must be nonnull")
            return
        }
        queue.async {
            self.listDownloadQueue.append(object!)
        }
    }
    
    // Remove Object
    func removeObject(object: DownloadItem?) {
 
        if let object = object {
            if self.listDownloadQueue.index(where: {$0.identifier == object.identifier}) != nil{
                queue.async {
                    self.listDownloadQueue.remove(at: self.listDownloadQueue.index(where: {$0.identifier == object.identifier})!)
                }
            }
        } else {
            print("Object must be nonnull")
            return
        }
    }
}
