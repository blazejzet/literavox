//
//  ControllsView.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 04/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI 
import AVFoundation
struct ControllsView: View {
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    
    @EnvironmentObject var repo:BooksRepository
    @EnvironmentObject var player:GlobalPlayer
    
    @State var track:Track2
    @State var downloading = false
    @Binding var trackListIsShow: Bool
    var body: some View {
        
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
//        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//        if (colorScheme == .dark){
//            .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//            .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//
//        }
        return VStack{
                        
            VStack{
                HStack{
                    Text("\(self.player.nowPlayingTime())").font(.subheadline).bold().foregroundColor(.white)
                    Spacer()
                    
                    
                    
                    Spacer()
                    Text("-\(self.player.leftTime())").font(.subheadline).bold().foregroundColor(.white)
                }.padding(.bottom,20)
            
                HStack{
                    Button(action: {
                        //self.track.prevBookmark()
                        self.player.prevTrack()
                    }){
                        Image(systemName: "backward.end").font(.system(size: 15.0)).foregroundColor(.foreground)
                    }.frame(width: 20.0)
                    ZStack{
                        CustomSlider(value:  $player.percent, cb: setCurrentTimeFromSlider,   range: (0.0, 1.0)) { modifiers in
                            ZStack {
                                Color.white.cornerRadius(3).frame(height: 6).modifier(modifiers.barLeft)
                                Color.foreground.cornerRadius(3).frame(height: 6).modifier(modifiers.barRight)
                                ZStack {
                                    Circle().fill(.red)
                                }.modifier(modifiers.knob)
                            }
                        }.frame(height: 30)
//                        BOOKMARKS
//                        GeometryReader{
//                            geometry in
//                            ForEach(self.track.bookmarksTags , id: \.self){ (bookmark:Bookmark) in
//                                Circle().fill(Color.red)
//                                    .frame(
//                                        width: bookmark.h(self.track.percent!), height:bookmark.h(self.track.percent!) )
//                                    .offset(x:CGFloat(bookmark.percent) * geometry.frame(in:.global).width - 3.5 - bookmark.o(self.track.percent!), y:17 - bookmark.o(self.track.percent!))
//                            }
//                        }.frame(height:40).padding(.horizontal,15)
                    }
                    Button(action: {
                        //self.track.nextBookmark()
                        self.player.nextTrack()
                    }){
                        Image(systemName: "forward.end").font(.system(size: 15.0))
                    }.disabled(!((self.track.num ?? 1) <  (self.player.nowPlaying?.tracks?.count ?? 0))).frame(width: 20.0).foregroundColor(.foreground)
                }
            }.padding(.bottom,20)
            
            ZStack{
                HStack{
                    Text(
                        "\(self.player.speed.get())"
                    ).font(.footnote).bold().frame(width: 50.0).padding().onTapGesture {
                        self.player.speed.next()
                    }.foregroundColor(.white)
                    Spacer()
                    Button(action:{
                        withAnimation(.easeInOut(duration: 0.5)){
                            trackListIsShow.toggle()
                        }
                    }){
                        Image(systemName: "list.bullet").foregroundColor(.white)
                        //Text("Track \(track.num!)").font(.headline).bold()
                    }.buttonStyle(PlainButtonStyle()).frame(width: 50.0)
                    
                }
                HStack{
                    Spacer()
                    Button(action: {
                        self.player.playAtSeconds(seconds: (self.player.avPlayer?.currentTime().seconds ?? 0) - 30.0)
                    }){
                        
                        Image(systemName: "gobackward.30").font(.system(size: 20.0)).foregroundColor(.foreground)
                    }
                    Spacer()
                    if(!self.player.downloading){
                        Button(action: {
                            
                            if((self.player.avPlayer?.timeControlStatus ?? AVPlayer.TimeControlStatus.paused) == AVPlayer.TimeControlStatus.playing){
                                self.player.pauseP()
                            }else{
                                self.player.playP()
                            }
                            
                        }){
                            Image(systemName: self.player.audioPlayerState ? "pause.fill":"play.fill").font(.system(size: 40.0)).padding().frame(width: 40, height: 40).foregroundColor(.foreground)
                            /*.contextMenu {
                             Button(action: {
                             // change country setting
                             }) {
                             Text("Play last played")
                             Image(systemName: "clock")
                             }
                             
                             Button(action: {
                             // enable geolocation
                             }) {
                             Text("Play the farthest")
                             Image(systemName: "play.rectangle")
                             }
                             }*/
                        }
                    }else{
                        DownloadingCircle().frame(width: 40, height: 35)
                    }
                    Spacer()
                    Button(action: {
                        //                    self.track.addBookmark()
                        self.player.playAtSeconds(seconds: (self.player.avPlayer?.currentTime().seconds ?? 0) + 30.0)
                    }){
                        Image(systemName: "goforward.30").font(.system(size: 20.0)).foregroundColor(.foreground)
                    }
                    Spacer()
                }
            }
//            HStack{
//
//
//
//
//
//
////                Image(systemName: self.track.hasCloseBookmark() ? "bookmark.fill" : "bookmark").font(.system(size: 15.0))
////
////                    .frame(width: 30.0).onTapGesture {
////                        self.track.addBookmark()
////                    }.padding().contextMenu(menuItems: {
////                        Button(action: {}, label: {
////                            Text("Delete all bookmarks")
////                        })
////
////                        ForEach(self.track.bookmarksTags.array.sorted(by: {$0.percent < $1.percent}) , id: \.self){ (bookmark:Bookmark) in
////                            Button(action: {
////                                self.track.percent = bookmark.percent
////                            }, label: {
////                                Text("\( Int(bookmark.percent * Double(self.track.length!)).toTimeString() )")
////                                Image(systemName: "bookmark.fill").font(.system(size: 10.0)).accentColor(.red)
////                            })
////                        }
////                    })
//
//            }
        }
        
    }
    
    func setCurrentTimeFromSlider(isEnded : Bool){
        
        print("[NOWPLAY] setting to: \(Double(self.player.nowPlayingTrack?.length ?? 0) * (self.player.percent ?? 0))")
        self.player.avPlayer?.pause()
        self.player.playAtSeconds(seconds: Double(self.player.nowPlayingTrack?.length ?? 0) * (self.player.percent ?? 0),shouldContinue: isEnded)
        self.player.saveTime()
        if isEnded && self.player.audioPlayerState{
            
            self.player.avPlayer?.play()
        }
    }
}

struct DownloadingCircle: View{
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    @State var anim = false
    var lineWidth: Double = 5
    var body : some View{
        
//        var .foreground = Color.init(red: 0.5, green: 0.5, blue: 0.5)
//        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//        if (colorScheme == .dark){
//            .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//            .foreground = Color.init(red: 0.6, green: 0.6, blue: 0.6)
//
//        }
//
        
        return VStack{
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(AngularGradient(gradient: .init(colors: [.foreground,.foreground]), center: .center),style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)).blendMode(colorScheme == .dark ? .luminosity:.luminosity)
                .rotationEffect(.init(degrees: anim ? 360:0))
                .animation(Animation.easeOut(duration: 3).repeatForever(autoreverses: false),value: self.anim)
        }.onAppear(){
            self.anim.toggle()
        }
    }
}
