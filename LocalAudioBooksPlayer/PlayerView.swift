//
//  PlayerView.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct PlayerView: View {
    @Environment (\.colorScheme) var colorScheme:ColorScheme
    
    @EnvironmentObject var repo:BooksRepository
    @EnvironmentObject var player:GlobalPlayer
    @State var showList = false
    @State var height:CGFloat? = nil
    
    @State var coverSize = CGRect(x: 0, y: 0, width: 0, height: 0)
    @State var coverStackSize = CGRect(x: 0, y: 0, width: 0, height: 0)
    @State var authorSize = CGRect(x: 0, y: 0, width: 0, height: 0)
    @State var authorOffset = CGPoint(x:0,y:0)
    
    var body: some View {
        
       
        GeometryReader{ g in
            var coverScale = 1/6 * (g.size.height/(coverSize.height > 0 ? coverSize.height : 100))
            var maxheightlist = g.size.height / 3.0

             VStack{
                if (player.nowPlaying != nil){
                    ZStack{
                        Blured(book: player.nowPlaying!)
                        VStack{
                            HStack{
//                                Button(action:{
//                                    self.player.nowPlaying?.read.toggle()
//                                    self.repo.booksInfoStorage.setValueFor(bookID: self.player.nowPlaying?.id ?? "",read: self.player.nowPlaying?.read)
//                                    self.player.objectWillChange.send()
//                                }){
//                                    Image((self.player.nowPlaying?.read ?? false) ? "read_on":"read_off").renderingMode(.original).resizable().frame(width: 25, height: 25)
//                                }
                                
                                //if(!self.showList){
                                Spacer()
                                //}
                                //                                VStack{
                                //                                    Text(player.nowPlaying!.author!.trimmingCharacters(in: .whitespacesAndNewlines)).font(.footnote).bold().lineLimit(1).padding(.bottom,5)
                                //                                    Text(player.nowPlaying!.title!.trimmingCharacters(in: .whitespacesAndNewlines)).font(.headline).bold().lineLimit(2)
                                //                                }
                                self.author.offset(x: self.showList && coverSize.width > 0 ? self.coverStackSize.minX + 15 + self.coverSize.width * coverScale - self.authorSize.minX + 10:0,
                                                   y: self.showList && coverSize.height > 0 && authorSize.height.isFinite && authorSize.height > 0 ? self.coverSize.minY + (self.coverSize.height * coverScale - self.authorSize.height)/2  - self.authorSize.minY :0)
                                .background(GeometryReader{
                                    geometry in
                                    Color.clear.onAppear{ self.authorSize = geometry.frame(in: .global)}
                                }).onTapGesture {
                                    print(self.authorSize)
                                    print(self.coverSize)
                                }
                                //}
                                Spacer()
                                
                                
//                                Button(action:{
//                                    self.player.nowPlaying?.favourite.toggle()
//                                    self.repo.booksInfoStorage.setValueFor(bookID: self.player.nowPlaying?.id ?? "",favourite: self.player.nowPlaying?.favourite)
//                                    self.player.objectWillChange.send()
//
//                                }){
//                                    Image((self.player.nowPlaying?.favourite ?? false) ? "favourite_on":"favourite_off").renderingMode(.original).resizable().frame(width: 25, height: 25)
//                                }
                                Button(action:{
                                    MXContextMenuModel.global.hideContextMenu()
                                    
                                }){
                                    //Image(systemName:"xmark").resizable().frame(width: 25, height: 25).foregroundColor(.foreground)
                                    Image("xw").renderingMode(.original).resizable().frame(width: 25, height: 25)
                                }
                            }
                            HStack{
                                if(!self.showList || (coverSize.width == 0 && coverSize.height == 0)){
                                    Spacer()
                                }
                                if(player.nowPlaying?.image == nil && player.nowPlaying?.imageData == nil){
                                    Image(systemName: "photo.fill.on.rectangle.fill").font(.system(size:50)).offset(x:-10).onTapGesture {
                                        
                                        withAnimation(.easeInOut(duration: 0.5)) { self.showList.toggle() }
                                        
                                    }
                                }else{
                                    Cover2(book2: player.nowPlaying!).background(GeometryReader{
                                        geometry in
                                        Color.clear.onAppear{ self.coverSize = geometry.frame(in: .global)}
                                    })
                                    .animation(.easeInOut(duration: 0.5)) // Animation Duration
                                    .transition(.fade) // Fade Transition
                                    .scaledToFit()
                                    .frame(width: nil, height: self.showList ? self.coverSize.height * coverScale: nil, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 20.0)
                                    .padding(15).onTapGesture {
                                        
                                        withAnimation(.easeInOut(duration: 0.5)) { self.showList.toggle() }
                                        
                                    }.animation(.easeInOut(duration:0.5))
                                }
                                Spacer()
                                
                                
                            }.background(GeometryReader{
                                geometry in
                                Color.clear.onAppear{ self.coverStackSize = geometry.frame(in: .global)}
                            }).padding(5)
                            
                            if(player.nowPlaying?.image == nil && player.nowPlaying?.imageData == nil){
                                Spacer()
                            }
                            HStack{
                                if(self.showList){
                                    
                                    TracksList().environmentObject(self.player)
                                        .environmentObject(self.repo)
                                        .padding(5)
                                        //.frame(maxHeight: maxheightlist)
                                }
                            }
                            
                            
                            Spacer()
                            
                            VStack{
                                
                                
                                if (self.player.nowPlayingTrack != nil){
                                    TrackGlobalSlider(track: self.player.nowPlayingTrack!).environmentObject(self.player)
                                        .environmentObject(self.repo).animation(.easeInOut(duration: 0.5))
                                }
                                
                                
                                
                            }.padding(.bottom,20.0)
                            
                            if(self.player.nowPlayingTrack != nil){
                                
                                ControllsView(track:self.player.nowPlayingTrack!, trackListIsShow: self.$showList)
                                    .environmentObject(self.player)
                                    .environmentObject(self.repo)
                            }
                            
                        }
                    }.padding()
                    Spacer()
                    
                }else{
                    EmptyView()
                }
            }.background{
                ZStack{
                    Rectangle().foregroundColor(.background).edgesIgnoringSafeArea(.all)
//                    if let p = self.player.nowPlaying{
//
//                        Cover2(book2: p).blur(radius: 40.0,opaque: true).opacity(0.7)
//
//                            .edgesIgnoringSafeArea(.bottom)
//                            .background(Rectangle()
//                                .foregroundColor(.black)
//                                .shadow(color: .init(white: 0.3), radius: 20)
//                                .clipShape(Rectangle()
//                                    .offset(y:-80)))
//                    }
                }
            }
            
        }
            
        
    }
    
    var author: some View{
        
        return VStack(alignment: self.showList && coverSize.height > 0 && coverSize.width > 0 ? .leading: .center){
            Text(player.nowPlaying!.author!.trimmingCharacters(in: .whitespacesAndNewlines)).font(.caption).bold().lineLimit(1)   .foregroundColor(.foreground)
            Text(player.nowPlaying!.title.trimmingCharacters(in: .whitespacesAndNewlines)).font(.system(size: 20)).bold().lineLimit(2).padding(.top,1) .foregroundColor(.foreground)
            
        }
        
    }
    
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
