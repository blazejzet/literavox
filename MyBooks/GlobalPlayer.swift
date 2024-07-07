//
//  File.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import SwiftUI

class GlobalPlayer:NSObject,ObservableObject, AVAudioPlayerDelegate
{
    static var shared: GlobalPlayer?
    
    @ObservedObject var library:Library
    
    static func create(with library:Library) -> GlobalPlayer{
        GlobalPlayer.shared = GlobalPlayer(library: library)
        return shared!
    }
    
    var avPlayer:AVPlayer? = nil
    var observer : Any?
    @Published var percent = 0.0 {
        didSet{
            if let t = self.nowPlayingTrack{
                self.percentForTrack[t] = percent
            }
        }
    }
    @Published var nowPlaying:Book2?
    @Published var nowPlayingTrack:Track2?
    @Published var speed = Speed.x1_0 {
        didSet{
            self.avPlayer?.rate = self.speed.getFloat()
            if(!self.audioPlayerState){
                self.avPlayer?.pause()
            }else{
                self.setupMPInfoCenter()
            }
            
        }
    }
    @Published var audioPlayerState:Bool
    @Published var downloading: Bool
    @Published var percentForTrack =  [Track2:Double]()
    
    func set(percent:Double, for track:Track2){
        self.percent = percent
        self.percentForTrack[track] = percent
    }
    func updateTrack(_ track:Track2){
        DispatchQueue.main.async {
            self.trackChanged()
            for i in 0 ..< self.nowPlaying!.tracks!.count {
                if (self.nowPlaying!.tracks![i].num! == track.num){
                    self.nowPlaying!.tracks![i] = track
                }
            }
        }
    }
    
    func trackChanged(){
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func play(book:Book2){
        DispatchQueue.main.async {
            self.nowPlaying = book
            self.nowPlayingTrack = nil
            self.audioPlayerState = false
            self.avPlayer = nil
            self.downloading = false
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            
                let seconds = Library.global.booksInfoStorage.lastTime(bookId: self.nowPlaying?.id ?? "")

            print("[NOWPLAY] \(self.nowPlaying?.id) --> \(seconds)")

                for var track in self.nowPlaying?.tracks ?? [] {
                    if(seconds >= (track.start ?? 0) && seconds < (track.start ?? 0) + (track.length ?? 0)){
                        print("[D][X][1] before set(track")
//                        self.set(track: track){
//                            self.set(percent: Double(seconds - (track.start ?? 0)) / Double(track.length ?? 1), for:track)
//                            self.play(percent: self.percent)
//                        }
                        var percent = Double(seconds - (track.start ?? 0)) / Double(track.length ?? 1)
                        //self.set(percent:percent , for:track)
                        print("[NOWPLAY] \(self.nowPlaying?.id) --> \(seconds) \(percent)")

                        self.play(track: track, seconds: (seconds - (track.start ?? 0)) )
                        break
                    }
                }
            
            
//            BooksRepository.global.loadData(for: book){
//                let seconds = BooksRepository.global.booksInfoStorage.lastTime(bookId: self.nowPlaying?.id ?? "")
//
//                for track in self.nowPlaying?.tracks ?? [] {
//                    if(seconds >= (track.start ?? 0) && seconds < (track.start ?? 0) + (track.length ?? 0)){
//                        track.percent = Double(seconds - (track.start ?? 0)) / Double(track.length ?? 1)
//                        print("[D][X][1] before set(track")
//                        self.set(track: track){
//                            DispatchQueue.main.async(){
//                                self.downloading = false
//                            }
//                        }
//                        break
//                    }
//                }
//            }
        }
    }
    
    func play(percent:Double){
        guard let len = self.nowPlaying?.length else{return}
        var seconds = Int(Double(len) * percent)
        
        for var track in nowPlaying!.tracks! {
            if seconds > track.start! && seconds < track.start!+track.length!{
//                self.set(percent: percent, for:track)
                self.play(track: track, percent: percent)
            }
        }
    }
    
    func set(track toPlay:Track2, callback: @escaping ()->Void){
        print("[D][1] set(track ")
        self.nowPlayingTrack = toPlay
        if self.observer != nil{
            self.avPlayer?.removeTimeObserver(self.observer!)
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        
        self.avPlayer = nil
        
        for var track in nowPlaying!.tracks! {
            if track.num!<toPlay.num!{
                self.set(percent: 1.0, for:track)
            }
            if track.num!>toPlay.num!{
                    self.set(percent: 0.0, for:track)
            }
            if track.num!==toPlay.num! && self.percentForTrack[track] == 1.0{
                        self.set(percent: 0.0, for:track)
                //TODO get from data. track.percent = 1.0
            }
        }
        
        
        DispatchQueue.main.async {
            self.nowPlayingTrack =  toPlay
        
            
            // TODO, do it through library.global...
            self.nowPlayingTrack?.url?.downloadFromiCloud{ _, _, localURL in
                if(self.avPlayer == nil  ){
                    self.setPlayer(audioFileURL: localURL!)
                    callback()
                }
            }
            //            Library.global.
            //        print("[D][1] getLocalFile")
            //            BooksRepository.global.getLocalFile(for:self.nowPlayingTrack!, inBook: self.nowPlaying!,downloading: &self.downloading,shouldBeDownloaded: self.audioPlayerState){ (localURL,track) in
            //
            //                if(self.avPlayer == nil && track == self.nowPlayingTrack){
            //                    self.setPlayer(audioFileURL: localURL)
            //                    DispatchQueue.main.async{
            //                        self.downloading = false
            //                    }
            //                    callback()
            //                    print("downloaded current track")
            //                }
            //            }
        }
        
    }
    func play(track toPlay:Track2){
        self.play(track: toPlay, percent:0.0)
    }
    
    func play(track toPlay: Track2,percent:Double){
        var track = toPlay
        print("[D][X][2] before set(track")
        track.setState( .downloading )
        self.updateTrack(track)
        library.download(track: track){ url in
            track.setState( .offline )
            track.url = url
            self.updateTrack(track)
            self.nowPlayingTrack = track
            
            let nextTrack = self.nowPlaying?.tracks?[self.nowPlayingTrack?.num ?? 0]
            if(nextTrack != nil && self.nowPlaying != nil){
                
                print("[D][2] getLocalFile for next track")
                DispatchQueue.main.async {
                    nextTrack?.url?.iCloud().downloadFromiCloud{_,_,_ in}
                   
                }
            }
            
            self.set(track: track){
                self.set(percent: percent, for: track)
                
                DispatchQueue.main.async {
                    self.audioPlayerState = true
                }
                //self.avPlayer?.seek(to: CMTime(seconds: currentTrackTime, preferredTimescale: (self.avPlayer?.currentTime().timescale ?? 1)))
               
                self.avPlayer?.play()
                
            }
        }
        
        
    }
    func play(track toPlay: Track2,seconds:Int){
        var track = toPlay
        print("[D][X][2] before set(track")
        track.setState( .downloading )
        self.updateTrack(track)
        library.download(track: track){ url in
            track.setState( .offline )
            track.url = url
            self.updateTrack(track)
            self.nowPlayingTrack = track
            
            let ind = self.nowPlayingTrack?.num ?? 0
            if self.nowPlaying!.tracks!.count > ind{
                let nextTrack = self.nowPlaying?.tracks?[ind]
                if(nextTrack != nil && self.nowPlaying != nil){
                    
                    print("[D][2] getLocalFile for next track")
                    DispatchQueue.main.async {
                        nextTrack?.url?.iCloud().downloadFromiCloud{_,_,_ in}
                        
                    }
                }
            }
            
            self.set(track: track){
                var percent = (Double(seconds) / Double(track.length ?? 1))
                self.set(percent: percent, for: track)
                
                DispatchQueue.main.async {
                    self.audioPlayerState = true
                }
                self.avPlayer?.seek(to: CMTime(seconds: Double(seconds), preferredTimescale: (self.avPlayer?.currentTime().timescale ?? 1)))
               
                self.avPlayer?.play()
                
            }
            DispatchQueue.main.async {
                
                
                Library.global.saveLastPlayedBook(self.nowPlaying?.id != nil ? self.nowPlaying?.id : self.nowPlaying?.title)
            }
        }
        
        
    }
    
    func setPlayer(audioFileURL: URL){
        print("[D][2] setPlayer")
        
        if (self.nowPlayingTrack?.num ?? 1) < (self.nowPlaying?.tracks?.count  ?? 0){
            
            let nextTrack = self.nowPlaying?.tracks?[self.nowPlayingTrack?.num ?? 0]
            if(nextTrack != nil && self.nowPlaying != nil){
                
                print("[D][2] getLocalFile")
                DispatchQueue.main.async {
                    nextTrack?.url?.iCloud().downloadFromiCloud{_,_,_ in}
                   
                }
            }
        }
        
        var counter = 0
        
        
        
        
        
        let avPlayerItem = AVPlayerItem(url: audioFileURL.absoluteURL)
        self.avPlayer = AVPlayer(playerItem: avPlayerItem)
        
        let currentTrackTime = (self.percentForTrack[self.nowPlayingTrack!] ?? 0) * Double(self.nowPlayingTrack?.length ?? 0)
        self.avPlayer?.seek(to: CMTime(seconds: currentTrackTime, preferredTimescale: (self.avPlayer?.currentTime().timescale ?? 1)))
        
        self.observer = self.avPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: (self.avPlayer?.currentTime().timescale ?? 1)), queue: DispatchQueue.global(), using: {
            currentTime in
            if self.avPlayer?.timeControlStatus == .playing{
                if counter == 5{
                    self.saveTime()
                }
                counter = (counter + 1) % 30
                DispatchQueue.main.async {
                    let percent = min(1.0,max((self.avPlayer?.currentTime().seconds ?? 0)/Double(self.nowPlayingTrack?.length ?? 1),0.0))
                    if let t = self.nowPlayingTrack {
                        self.set(percent: percent, for: t)
                    }
                }
            }
        })
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String:Any]()
        
        
        //setting nowPlayingInfo
        if(self.nowPlaying?.imageData != nil){
            
            let image = UIImage(data: (self.nowPlaying?.imageData ?? Data())) ?? UIImage()
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
                return image
            })
            
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            
        }else if(self.nowPlaying?.image != nil){
            
            let data = try? Data(contentsOf: URL(string: self.nowPlaying?.image ?? "")!)
            let image = UIImage(data: data ?? Data()) ?? UIImage()
            let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {  (_) -> UIImage in
                return image
            })
            
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
            
        }
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.nowPlaying?.title.trimmingCharacters(in: .whitespacesAndNewlines)
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Track \(self.nowPlayingTrack?.num ?? 0)"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.nowPlayingTrack?.length
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.speed.getFloat()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.avPlayer?.currentTime().seconds
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        self.avPlayer?.rate = self.speed.getFloat()
        self.play()
        
        
        
        //end track or interrupt audioSession
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playNextSound), name: .AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.audioSesionInterrupted), name: AVAudioSession.interruptionNotification, object: nil)
        
        
        //setting mediaPlayer buttons on lock screen
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [unowned self] event in
            self.audioPlayerState = false
            self.avPlayer?.pause()
            pauseMP()
            return .success
        }
        MPRemoteCommandCenter.shared().playCommand.addTarget { [unowned self] event in
            self.setupMPInfoCenter()
            self.audioPlayerState = true
            self.avPlayer?.play()
            //self.play()
            return .success
        }
        MPRemoteCommandCenter.shared().skipForwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [30]
        MPRemoteCommandCenter.shared().skipForwardCommand.addTarget{[unowned self] event in
            self.playAtSeconds(seconds: (self.avPlayer?.currentTime().seconds ?? 0) + 30.0)
            return .success
        }
        MPRemoteCommandCenter.shared().skipBackwardCommand.isEnabled = true
        MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [30]
        MPRemoteCommandCenter.shared().skipBackwardCommand.addTarget{ [unowned self] event in
            self.playAtSeconds(seconds: (self.avPlayer?.currentTime().seconds ?? 0) - 30.0)
            return .success
        }
    }
    
    
    func saveTime(){
        DispatchQueue.main.async {
            if(self.avPlayer != nil){
                
                let seconds = (self.nowPlayingTrack?.start ?? 0) + Int(self.avPlayer?.currentTime().seconds ?? 0)
                
                BooksRepository.global.booksInfoStorage.setValueFor(bookID: self.nowPlaying?.id ?? "",currentTime: seconds)
                
                print("[NOWPLAY] Saving time for \(self.nowPlaying?.id ?? "") time: \(seconds)")
                print("In userdefaults: \(BooksRepository.global.booksInfoStorage.lastTime(bookId: self.nowPlaying?.id ?? ""))")
                
            }
        }
    }
    
    
    
    @objc func audioSesionInterrupted(){
        self.avPlayer?.pause()
        self.audioPlayerState = false
    }
    
    func playAtSeconds(seconds: Double, shouldContinue newState: Bool = true){
        
        self.avPlayer?.pause()
        self.avPlayer?.seek(to: CMTimeMakeWithSeconds(seconds, preferredTimescale: self.avPlayer?.currentTime().timescale ?? 2))
        
        if(newState && self.audioPlayerState){
            self.avPlayer?.play()
        }
        
        if(self.percentForTrack[nowPlayingTrack!] != nil){
            self.set(percent: seconds / Double(self.nowPlayingTrack?.length ?? 1), for: nowPlayingTrack!)
        }
        
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String:Any]()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seconds
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
    }
    
     init(library:Library ) {
        self.library = library
        self.downloading = false
        self.audioPlayerState = false
    }
    
    func isPlaying(track:Track2) -> Bool{
        return track.num == (nowPlayingTrack?.num ?? 0)
    }
    
    func isFinished(track:Track2) -> Bool{
        return false
    }
    
    func closeAudioSession(){
        do{
            try AVAudioSession.sharedInstance().setActive(false)
        }catch {
            print("Error with close audioSession")
        }
    }
    
    func play(){
        DispatchQueue.main.async {
            self.audioPlayerState = true
        }
        if(self.avPlayer != nil){
            print("[DEBUG:GlobalPlayer::play]: avPlayer != nil")
            do{
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers,.defaultToSpeaker])// mode: .spokenAudio)
                try AVAudioSession.sharedInstance().setActive(true)
                try UIApplication.shared.beginReceivingRemoteControlEvents()
                self.avPlayer?.playImmediately(atRate: self.speed.getFloat())
                
                self.setupMPInfoCenter()
                self.saveTime()
                
                if(self.nowPlaying != nil){
                    DispatchQueue.main.async {
                        
                        
                        Library.global.saveLastPlayedBook(self.nowPlaying?.id != nil ? self.nowPlaying?.id : self.nowPlaying?.title)
                    }
                    
                }
                
            }catch let error{
                print("Error with setup audioSession \(error.localizedDescription)")
                self.audioPlayerState = false
            }
            
        }else if let track = self.nowPlayingTrack{
            print("[DEBUG:GlobalPlayer::play]: avPlayer == nil")
            //self.set(track: track){
                self.play(track: track)
            //}
        }
    }
    
    func pause(){
        
        DispatchQueue.global().async {
            self.avPlayer?.pause()
                    
            self.pauseMP()
            self.saveTime()
            try? AVAudioSession.sharedInstance().setActive(false)
        }
        
        DispatchQueue.main.async {
            self.audioPlayerState = false
        }
    }
    
    func setupMPInfoCenter(){
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String:Any]()
        
        print(self.speed.getFloat())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.speed.getFloat()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.avPlayer?.currentTime().seconds
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
        
    }
    func pauseP(){
        audioPlayerState = false
        self.avPlayer?.pause()
    }
    func playP(){
        
            audioPlayerState = true
        self.avPlayer?.play()
    }
    func pauseMP(){
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String:Any]()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.avPlayer?.currentTime().seconds
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    func nowPlayingTime()->String{
        if let booktime = self.nowPlaying?.length {
            if let chapterstart = self.nowPlayingTrack?.start{
                if let chapterlength = self.nowPlayingTrack?.length{
                    if let chapterpercent =  self.percentForTrack[self.nowPlayingTrack!] {
                        let chaptercurrent = Int(Double(chapterlength)*chapterpercent)
                        let bookcurrent = chaptercurrent + chapterstart
                        
                        return bookcurrent.toTimeString()
                    }
                }
            }
        }
        return "--:--"
    }
    func leftTime()->String{
        if let booktime = self.nowPlaying?.length {
            if let chapterstart = self.nowPlayingTrack?.start{
                if let chapterlength = self.nowPlayingTrack?.length{
                    if let chapterpercent =  self.percentForTrack[self.nowPlayingTrack!] {
                        let chaptercurrent = Int(Double(chapterlength)*chapterpercent)
                        let bookcurrent = chaptercurrent + chapterstart
                        let left  = booktime - bookcurrent
                        return left.toTimeString()
                    }
                }
            }
        }
        return "--:--"
    }
    
    
    
    
    func nextTrack(){
        DispatchQueue.global().async {
            if(self.nowPlayingTrack!.num! < self.nowPlaying!.tracks!.count && self.nowPlaying != nil){
                if self.observer != nil{
                    self.avPlayer?.removeTimeObserver(self.observer!)
                }
                self.avPlayer = nil
                let nextTrack = (self.nowPlaying!.tracks ?? [])[self.nowPlayingTrack?.num ?? 0]
                if self.audioPlayerState{
                    self.play(track: nextTrack)
                }else{
                    self.set(track: nextTrack){}
                }
            }
        }
    }
    
    
    
    func prevTrack(){
        if(self.nowPlayingTrack!.num! > 1){
            if((self.avPlayer?.currentTime().seconds ?? 0) <= 5.0){
                let prevTrack =  (self.nowPlaying?.tracks ?? [])[(self.nowPlayingTrack?.num ?? 2) - 2]
                if self.observer != nil{
                    self.avPlayer?.removeTimeObserver(self.observer!)
                }
                self.avPlayer = nil
                if(self.audioPlayerState){
                    self.play(track: prevTrack)
                }else{
                    self.set(track: prevTrack){}
                }
            }else{
                self.playAtSeconds(seconds: 0.0)
            }
        }else{
            self.playAtSeconds(seconds: 0.0)
        }
    }
    
    
    func maxPlayed()->Double{
        return 0.79
    }
    
    func lastPlayed()->Double{
        return 0.69
    }
    
    @objc func playNextSound(){
        self.avPlayer = nil
        if(self.nowPlaying!.tracks!.count > self.nowPlayingTrack!.num!){
            self.nextTrack()
        }else{
            print("Koniec audiobooka")
            self.audioPlayerState = false
            self.avPlayer = nil
        }
        self.saveTime()
    }
    
}


enum Speed{
    case x0_8, x1_0, x1_3, x1_5, x1_7, x2_0
    mutating func next(){
        switch self{
        case .x0_8: self = .x1_0
        case .x1_0: self = .x1_3
        case .x1_3: self = .x1_5
        case .x1_5: self = .x1_7
        case .x1_7: self = .x2_0
        case .x2_0: self = .x0_8
        }
    }
    func get()->String{
        switch self{
        case .x0_8: return  "x0.8"
        case .x1_0: return  "x1.0"
        case .x1_3: return  "x1.3"
        case .x1_7: return  "x1.7"
        case .x1_5: return  "x1.5"
        case .x2_0: return  "x2.0"
        }
    }
    func getFloat()->Float{
        switch self{
        case .x0_8: return  0.8
        case .x1_0: return  1.0
        case .x1_3: return  1.3
        case .x1_5: return  1.5
        case .x1_7: return  1.7
        case .x2_0: return  2.0
        }
    }
}

