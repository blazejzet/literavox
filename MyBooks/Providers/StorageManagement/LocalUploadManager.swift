//
//  LocalStorageManager.swift
//  MyBooks
//
//  Created by Damian Skarżyński on 09/09/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Combine
import Foundation
import Zip
import ID3TagEditor

public enum FilePickerState{
    case initial, loading, details, noFoundMP3
}

class LocalUploadManager: ObservableObject{
    
    
    private let temporaryDirectoryURL:URL = FileManager.documentsDirectoryURL.appendingPathComponent("TempDir")
    private let bookStorageDirectoryURL: URL = FileManager.documentsDirectoryURL//.appendingPathComponent("BookStorage")
    private let fileManager = FileManager.default
    
    var filePickerState:FilePickerState = .initial
    var decompressionPregress:Double = 0.0
    
    let bookID:String = UUID().uuidString
    var bookTitle:String = ""
    var bookAuthor:String = ""
    var bookType: String = ""
    var bookCoverData:Data = Data()
    var bookCoverURL:URL?
    var bookTracks:Int = 0
    
    private var sortedTempTracksArray:[URL] = []
    var tracksArray:[URL] = []
    
    
    func unzipToTemp(url sourceURL: URL) {
        //        var tempFileURL:URL?
        print("docDir \(FileManager.documentsDirectoryURL)")
        filePickerState = .loading
        DispatchQueue.global().async {
            do{
                sourceURL.startAccessingSecurityScopedResource()
                let sourceName = sourceURL.deletingPathExtension().lastPathComponent
                let currentDate = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH-mm-ss"
                let currentHour = formatter.string(from: currentDate)
                
                let temporaryFilename = "\(sourceURL.deletingPathExtension().lastPathComponent)_\(currentHour)"
                let tempFileURL = self.temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
                try Zip.unzipFile(sourceURL, destination: tempFileURL, overwrite: true, password: nil, progress: { (progress) -> () in
                    print(progress)
                    DispatchQueue.main.async {
                        self.decompressionPregress = progress
                        self.objectWillChange.send()
                    }
                })
                sourceURL.stopAccessingSecurityScopedResource()

                self.scanBookID3Tags(url: tempFileURL, sourceName: sourceName)
            }catch {
                sourceURL.stopAccessingSecurityScopedResource()
            }
            //        return tempFileURL
        }
    }
    
    func scanBookID3Tags(url: URL, sourceName: String){
        do{
            let bookURL = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            print(bookURL)
            var index = 0
            print(sourceName)
            for (idx, item) in bookURL.enumerated(){
                if item.lastPathComponent.contains(sourceName){
                    index = idx
                }
            }
            let contentURLs = try fileManager.contentsOfDirectory(at: bookURL[index], includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let image = contentURLs.filter({$0.lastPathComponent.contains(".jpg")})
            bookCoverURL = image.first
            var tempTracksArray = contentURLs.filter({
                $0.lastPathComponent.contains(".mp3")
            })
            tempTracksArray.sort( by: {
                $0.lastPathComponent < $1.lastPathComponent
            })
            bookTracks = tempTracksArray.count
            if bookTracks > 0 {
                
                for (index, item) in tempTracksArray.enumerated(){
                    let newName = "\(index)-" + UUID().uuidString + ".mp3"
                    let newURL = item.deletingLastPathComponent().appendingPathComponent(newName)
                    try fileManager.moveItem(at: item, to: newURL)
                    sortedTempTracksArray.append(newURL)
                }
                let track:Data = try Data(contentsOf: sortedTempTracksArray[0])
                
                let id3TagEditor = ID3TagEditor()
                
                if let id3Tag = try id3TagEditor.read(mp3: track) {
                    
                    
                    self.bookAuthor = (id3Tag.frames[.Artist] as? ID3FrameWithStringContent)?.content ?? "unknown"
                    
                    self.bookTitle = (id3Tag.frames[.Album] as?  ID3FrameWithStringContent)?.content ?? "unknown"
                    
                    if let attachedPicture = (id3Tag.frames[.AttachedPicture(.Other)] as? ID3FrameAttachedPicture)?.picture {
                        
                        self.bookCoverData = attachedPicture
                        print("has image")
                    }else{
                        if let image = image.first{
                            self.bookCoverData = try Data(contentsOf: image )
                        }
                        
                    }
                }
                DispatchQueue.main.async {
                    print("unzipToTemp ended")
                    self.filePickerState = .details
                    self.objectWillChange.send()
                }
            }else{
                DispatchQueue.main.async {
                    print("empty or invalid content of zipfile")
                    self.filePickerState = .noFoundMP3
                    self.bookTitle = ""
                    self.bookAuthor = ""
                    self.bookType = ""
                    self.bookCoverData = Data()
                    self.bookCoverURL = nil
                    self.bookTracks = 0
                    self.objectWillChange.send()
                }
            }
        }catch{
            print(error)
        }
        
        
        
    }
    
    func saveAudiobook(completion: ((Bool) -> Void)){
        let savedBookURL:URL = bookStorageDirectoryURL.appendingPathComponent(self.bookID)
        if !fileManager.fileExists(atPath: bookStorageDirectoryURL.path){
            print("not exist \(bookStorageDirectoryURL)")
            do{
                //try fileManager.createDirectory(atPath: bookStorageDirectoryURL.path, withIntermediateDirectories: false, attributes: nil)
                try fileManager.createDirectory(atPath: savedBookURL.path, withIntermediateDirectories: false, attributes: nil)
                for (index, item) in sortedTempTracksArray.enumerated(){
                    let name = item.lastPathComponent
                    let newURL = savedBookURL.appendingPathComponent(name)
                    try fileManager.moveItem(at: item, to: newURL)
                    tracksArray.append(newURL)
                    
                }
                completion(true)
            }catch{
                print(error)
                completion(false)
            }
        }else{
            do{
                try fileManager.createDirectory(atPath: savedBookURL.path, withIntermediateDirectories: false, attributes: nil)
                for (index, item) in sortedTempTracksArray.enumerated(){
                    let name = item.lastPathComponent
                    let newURL = savedBookURL.appendingPathComponent(name)
                    try fileManager.moveItem(at: item, to: newURL)
                    tracksArray.append(newURL)
                }
                completion(true)
            }catch{
                print(error)
                completion(false)
            }
        }
    }
    
}
