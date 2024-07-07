//
//  SmallPlayerView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import AVFoundation

struct SmallPlayerView: View {
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    @EnvironmentObject var player:GlobalPlayer
    
    var body: some View {
        //var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
        ////var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
        //if (colorScheme == .dark){
//        //var  .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
        //var  .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
            
        //}
        
        return VStack{
            if (player.nowPlaying != nil){
                ZStack{
                    //                WebImage(url: URL(string: player.nowPlaying!.image!)).placeholder {Rectangle().foregroundColor(.gray)}.resizable().blur(radius: 40.0).opacity(0.5)
                    Cover2(book2: player.nowPlaying!).blur(radius: 40.0,opaque: true).opacity(0.7)
                        .edgesIgnoringSafeArea(.bottom)
                        .background(Rectangle()
                            .foregroundColor(.gray)
                                        .shadow(color: .init(white: 0.3), radius: 20)
                            .clipShape(Rectangle()
                                .offset(y:-80)))
                        
                    HStack{
                        //                    WebImage(url: URL(string: player.nowPlaying!.image!)).placeholder {Rectangle().foregroundColor(.gray)}.resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:50.0, height: 50.0, alignment: .center).padding(5.0).shadow(radius: 30).padding(5.0)
                        Cover2(book2: player.nowPlaying!).scaledToFit().clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:50.0, height: 50.0, alignment: .center).padding(5.0).shadow(radius: 30).padding(5.0)
                        VStack(alignment: .leading){
                            
                            Text(player.nowPlaying!.title.trimmingCharacters(in: .whitespacesAndNewlines))
                                .font(.headline).lineLimit(0).foregroundColor(.white)
                            Text(player.nowPlaying!.author!.trimmingCharacters(in: .whitespacesAndNewlines))
                                .font(.subheadline).lineLimit(0).foregroundColor(.white)
                            
                        }
                        Spacer()
                        Button(action:{
                            self.player.playAtSeconds(seconds: (self.player.avPlayer?.currentTime().seconds ?? 0) - 30.0)
                        }){
                            Image(systemName: "gobackward.30").font(.system(size: 20.0)).foregroundColor(.foreground)
                        }
                        Spacer()
                        Button(action: {
                            if((self.player.avPlayer?.timeControlStatus ?? AVPlayer.TimeControlStatus.playing) == AVPlayer.TimeControlStatus.playing){
                                self.player.avPlayer?.pause()
                                self.player.saveTime()
                            }else{
                                self.player.avPlayer?.play()
                                self.player.saveTime()
                            }
                            self.player.audioPlayerState.toggle()
                        }){
                            Image(systemName: self.player.audioPlayerState ? "pause.fill":"play.fill").font(.system(size: 30.0)).foregroundColor(.foreground)
                        }
                        Spacer()
                        Button(action:{
                            self.player.playAtSeconds(seconds: (self.player.avPlayer?.currentTime().seconds ?? 0) + 30.0)
                        }){
                            Image(systemName: "goforward.30").font(.system(size: 20.0)).foregroundColor(.foreground)
                        }
                        Spacer()
                    }
                }.frame(maxHeight:80.0)
                
              }else{
                  EmptyView()
              }
            }
        
    }
}


struct SmallPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        SmallPlayerView()
    }
}
