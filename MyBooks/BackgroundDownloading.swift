//
//  BackgroundDownloading.swift
//  MyBooks
//
//  Created by Dawid Jenczewski on 16/05/2021.
//  Copyright © 2021 Blazej Zyglarski. All rights reserved.
//

import Foundation
import UIKit
class BackgroundDownloading{
    
    var backgroundTaskID : UIBackgroundTaskIdentifier?
    
    
    init(){
        
    }
    
    func downloadTrack(downloadFrom neturl: URL, saveTo savedURL : URL, cb: @escaping ()->Void ){
        
        DispatchQueue.global().async{
            
            let number = Int.random(in: 0...100000)
            self.backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Task downloading \(number)"){
                
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
                
            }
            
            let downloadTask = URLSession.shared.downloadTask(with: neturl){
                urlOrNil, responseOrNil, errorOrNil in
                guard let fileURL = urlOrNil else { return }
                print("------\(fileURL)-------")
                try? FileManager.default.moveItem(at: fileURL, to: savedURL)
                cb()
                
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID!)
                self.backgroundTaskID = UIBackgroundTaskIdentifier.invalid
            }
            downloadTask.resume()
            
            
        }
        
    }
    
}
