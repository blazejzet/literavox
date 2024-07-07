//
//  TrackView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
// 

import SwiftUI

struct TrackGlobalSlider: View {
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    
    @EnvironmentObject var repo:BooksRepository
    @EnvironmentObject var player: GlobalPlayer
    
    @State var track: Track2
    
    
    var body: some View {
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
//        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//        //if (colorScheme == .dark){
//            .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//            .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//            
//       // }
        
        return ZStack{
            GeometryReader{
                geometry in
                
//                Rectangle().cornerRadius(5.0).foregroundColor(.gray)
//                    .frame(width: geometry.frame(in:.global).width * CGFloat(self.player.maxPlayed()), height: 6.0)
//                    .offset(x: 0.0 )
                
                
                Rectangle().cornerRadius(5.0).foregroundColor(.white).opacity(0.5)
                    .frame(width: geometry.frame(in:.global).width , height: 6.0)
                    .offset(x: 0.0 ).gesture( DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                                .onChanged {
                        let percent = $0.location.x / geometry.frame(in:.local).width
                        //self.player.play(percent: Double(percent))
                        //print("Changed \(   )")
                    })
                
                Rectangle().cornerRadius(5.0).foregroundColor(.white)
                    .frame(width: geometry.frame(in:.global).width * CGFloat(self.player.nowPlayingTrack?.length ?? 0) /  CGFloat(self.player.nowPlaying?.length ?? 1), height: 6.0)
                    .offset(x: geometry.frame(in:.global).width * CGFloat(self.player.nowPlayingTrack?.start ?? 0) /  CGFloat(self.player.nowPlaying?.length ?? 1) ).animation(.easeInOut(duration: 0.5))
                
                //TODO lastplayed
                Rectangle().cornerRadius(2.0)
                    .frame(width: 4.0, height: 4.0).foregroundColor(.red)
                    .offset(x:  geometry.frame(in:.global).width * self.getLastPlayedOffset() - 1.0, y:1
                    ).animation(.easeInOut(duration: 0.5))
                
//                Rectangle().cornerRadius(5.0)
//                    .frame(width: 2.0, height: 8.0).foregroundColor(.orange)
//                    .offset(x:  geometry.frame(in:.global).width * CGFloat(self.player.lastPlayed() ) - 1.0).animation(.easeInOut(duration: 0.5))
                //
                
                
            }
        }.frame( height: 10.0).padding(5.0)
        
        
        
    }
    
    
    func getLastPlayedOffset() -> CGFloat{
        guard let track = self.player.nowPlayingTrack else {return 0}
        return (
            CGFloat((self.player.percentForTrack[track] ?? 0.0))
            * CGFloat((self.player.nowPlayingTrack?.length ?? 0))
            + CGFloat(self.player.nowPlayingTrack?.start ?? 0)
        )
        / CGFloat(self.player.nowPlaying?.length ?? 1)
        
        
    }
    
}
