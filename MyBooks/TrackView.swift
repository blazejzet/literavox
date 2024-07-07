//
//  TrackView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI

struct TrackView: View {
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    
    @EnvironmentObject var library:Library
       @EnvironmentObject var player:GlobalPlayer
       
    @Binding var track: Track2
    var body: some View {
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
       // if (colorScheme == .dark){
//             .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//             .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
            
      //  }
        
        return Button(action: {
            //TODO:DOWNLOAD
           
                self.player.play(track: self.track)
            
        }){
        HStack{
        
            //ProgressView(percent: $track.percent)
            
            if (player.isPlaying(track:track)){
                Image(systemName: "play.circle.fill").foregroundColor(.foreground).frame(width: 30.0)
            }else{
                if (player.isFinished(track:track)){
                    Image(systemName: "chevron.down.circle.fill").foregroundColor(.green).frame(width: 30.0)
                }else if (!player.isPlaying(track:track)){
                    Image(systemName: "play.circle").foregroundColor(.foreground).frame(width: 30.0)
                }
            }
            
            
            
            Text("\(track.num!)# \(track.filename!)").bold().lineLimit(1).foregroundColor(.foreground)
            Spacer()
            
            Text(track.length?.toTimeString() ?? "").foregroundColor(.foreground)
            
            if track.state == .online{            Image(systemName: "cloud").foregroundColor(.foreground).padding(.trailing, 10.0).frame(width: 30.0) }
            if track.state == .downloading{            Image(systemName: "square.and.arrow.down").foregroundColor(.foreground).padding(.trailing, 10.0).frame(width: 30.0) }
            if track.state == .offline{            Image(systemName: "iphone").foregroundColor(.foreground).padding(.trailing, 10.0).frame(width: 30.0) }

            
            //BookmarksCountView(count: $track.bookmarks)
            
            
            
        }
        }//.buttonStyle(PlainButtonStyle())
        .onAppear{
            print("[TR] \(self.track.url!.path)")
            if (FileManager.default.fileExists(atPath: self.track.url!.path)){
                self.track.setState(.offline)
                self.player.updateTrack(self.track)
            }
        }
    }
}
