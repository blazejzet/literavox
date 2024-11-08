//
//  TracksList.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
 
struct TracksList: View {
    @Environment (\.colorScheme) var colorScheme:ColorScheme
      
    @EnvironmentObject var repo:BooksRepository
    @EnvironmentObject var player:GlobalPlayer
    
    init() {
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack{
            
            if ( player.nowPlaying != nil ){
                if(player.nowPlaying?.tracks != nil){
                    List{
                        ForEach(player.nowPlaying!.tracks!, id:\.self){ t in
                            TrackView(track:Binding.instant(value: t))
                            .environmentObject(self.player)
                            .environmentObject(self.repo)
                        }.listRowBackground(Color.clear)
                    }.listStyle(PlainListStyle())
                    
                }else{
                    Text("Loading tracks")
                }
            }else{
                Text("Missing tracks")
            }
        }
    }
}

