//
//  ContentView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI

enum MainSheetMode{
    case player, uploader, progress, libraries, addingLibrary, none
}


struct ContentView: View {
    
    let showUpdatesPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("showUpdatesFromUserNotification"))
    
    @StateObject private var contextMenuModel = MXContextMenuModel.global
    @Environment (\.colorScheme) var colorScheme : ColorScheme
    @EnvironmentObject var repo:BooksRepository
    @EnvironmentObject var lib:Library
    
    @EnvironmentObject var player:GlobalPlayer
    
//    @State var firstOpenSources = false
    @State var providerFilter: Provider?
    @State var search:String=""
    @State var showSheet = false
    @State var lastPlayedShow = true
    
    @State var sheetMode:MainSheetMode = .none{
        didSet{
            self.repo.objectWillChange.send()
        }
    }
    @State var favOn = false
    @State var readOn = false
    
    
    
    var body : some View{
        ZStack{
            main.background{Color.background}
            MXContextMenuComponent(menumodel: contextMenuModel)
        }.background{Rectangle().foregroundColor(Color.background).edgesIgnoringSafeArea(.all)}
        
    }
    
    var main: some View {
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
//        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//        //if (colorScheme == .dark){
//            .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//            .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//
//        //}
        
        return VStack(spacing:0){
            HStack{
                //                Image("icon").resizable().frame(width:25,height:25)
                
                //TextField("Search...", text: self.$search, onCommit:{})
                
                SuperTextField(
                       placeholder: Text("Search...").foregroundColor(.gray),
                       text:  self.$search
                   ).font(.headline).foregroundColor(.foreground)
                Spacer()
                
//                Button(action:{
//                    //self.hideKeyboard()
//                    self.readOn.toggle()
//                }){
//                    Image(self.readOn ? "read_on":"read_off").renderingMode(.original).resizable().frame(width:25,height:25)
//                }.padding(.horizontal,5)
//                Button(action:{
//                    //self.hideKeyboard()
//                    self.favOn.toggle()
//                }){
//                    Image(self.favOn ? "favourite_on":"favourite_off").renderingMode(.original).resizable().frame(width:25,height:25)
//                }
                
                
                
                
            }.padding(.horizontal).padding(.vertical,10)
            
            VStack(alignment: .leading){
                HStack{
                    
                    ProvidersFilterListView(selectedProvider: self.$providerFilter,addCallback: {  }).environmentObject(self.lib)
                    
                    Spacer()
                    
                    
                    
                    Button(action: {
                        MXContextMenuModel.global.showContextSheet(content: AnyView(
                            LibrariesView().environmentObject(self.repo).environmentObject(self.lib)
                        ))
                    }){
                        ZStack{
                            Circle().fill(Color.foreground).frame(width: 30, height: 30)
                            Circle().stroke(Color.background.opacity(0.6),lineWidth: 1).frame(width: 30, height: 30)
                            Image(systemName: "books.vertical.fill").renderingMode(.template).resizable().frame(width:22,height:22).foregroundColor(Color.background)
                        }
                    }.buttonStyle(PlainButtonStyle())
                    
                    
                    
                    
                    
                }
                HStack{
                    Text(self.providerFilter != nil ? self.providerFilter?.instancename ?? "" : "All book libraries")
                        .font(.system(size:20, weight: .medium)).foregroundColor(.foreground)
                    Spacer()
                    
                    if self.lib.inProgress{
                        Image(systemName:"arrow.counterclockwise.circle").foregroundColor(.white)
                    }
                    
                    Button(action: {
                        
                        MXContextMenuModel.global.showContextSheet(content: AnyView(
                            AddingBooksView(repo:self.$providerFilter).environmentObject(self.repo)
                        ))
                        
                    }){
                        HStack(spacing:2){
                            Image("add").renderingMode(.template).resizable().frame(width:15,height:15).foregroundColor(.foreground)
                            Text("Adding books").font(.system(size:15)).foregroundColor(.foreground)
                        }.padding(.horizontal, 7).padding(.vertical,3).background(
                            ZStack{
                                RoundedRectangle(cornerRadius: 13).fill(Color.backgroundLight)
                                RoundedRectangle(cornerRadius: 13).stroke()
                            })
                    }.foregroundColor(.foreground).buttonStyle(PlainButtonStyle())
                    
                    
                }
            }.padding()
                .background(colorScheme == .light ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
            
            //if(self.lib.books.count > 0){
            //TODO LAST PLAYED-----
            if let bookID = self.lib.lastPlayedBookId{
                if let book = self.lib.books.first{$0.id == self.lib.lastPlayedBookId || $0.title == bookID}{
                    VStack(alignment: .leading){
                        VStack{
                            HStack{
                                Text("Continue listening...").bold().foregroundColor(.foreground)
                                Spacer()
                                
                                Image(systemName: self.lastPlayedShow ? "chevron.up":"chevron.down").renderingMode(.original).resizable().frame(width:11,height:8).foregroundColor(.white)
                            }
                            if(self.lastPlayedShow){
                                HStack{
                                    
                                    Button(action: {
                                        MXContextMenuModel.global.showContextSheet(content:
                                            AnyView(PlayerView().environmentObject(self.player)
                                                 .environmentObject(self.repo)))
                                        
                                        
                                        DispatchQueue.global().async {
                                            if (self.player.nowPlaying ?? nil) != book{
                                                self.player.play(book: book)
                                            }
                                        }
                                    }){
                                        BookRowView2(book: book)
                                    }.buttonStyle(PlainButtonStyle())
                                    
                                    //HStack{
                                    Spacer()
                                    BookProgress(percent: Double(BooksInfoStorage().lastTime(bookId: bookID))/Double(book.length ?? 1)).foregroundColor(.white)
                                    Text("\( Int( round( Double(BooksInfoStorage().lastTime(bookId: bookID))/Double(book.length ?? 1) * 100) ) )%").foregroundColor(.white)
                                    //                                }
                                }.frame(maxHeight: self.lastPlayedShow ? 110: 0).transition(AnyTransition.asymmetric(insertion: AnyTransition.offset(y:-40).combined(with: AnyTransition.opacity.animation(.easeIn(duration:0.3))), removal: AnyTransition.offset(y:-50).combined(with: AnyTransition.opacity.animation(.linear(duration:0.1)))))
                            }
                        }.padding(10).buttonStyle(PlainButtonStyle()).background(Color(UIColor.black).cornerRadius(10.0)).onTapGesture{
                            withAnimation(.easeInOut(duration: 0.2)){
                                self.lastPlayedShow.toggle()
                            }
                        }
                       
                        //}.frame(maxHeight: self.lastPlayedShow ? 130: 0)
                        Text("All in this library").bold().foregroundColor(.foreground).padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
                    }.padding(EdgeInsets(top: 15, leading: 15, bottom: 0, trailing: 15))
                }
            }
            //****
            
            //                List(self.repo.books.filter {
            //                    ($0.title!.lowercased().contains(
            //                        self.search.lowercased()) || self.search==""
            //                    )
            //                    && ($0.favourite==true || self.favOn==false)
            //                    && ($0.read==true || self.readOn==false)
            //                    && (self.providerFilter == nil || $0.providercode == self.providerFilter?.providercode)
            //                } ,id: \.self)
            //                { book in Button(action: {
            //                    //                self.showPlayer.toggle()
            //                    self.sheetMode = .player
            //                    self.showSheet.toggle()
            //                    DispatchQueue.global().async {
            //                        if (self.player.nowPlaying ?? nil) != book{
            //                            self.player.play(book: book)
            //                        }
            //                    }
            //                }, label: {
            //                    BookRowView(book: book)
            //                }).buttonStyle(PlainButtonStyle())
            
            if (self.lib.cbooks(providerFilter).count == 0){
                VStack{
                    Spacer()
                
                HStack{
                    Text("Add some library to the app!").foregroundColor(.white)
                }
                    Spacer()
                }
            }else{
                //Text("\(self.lib.books.count)")
                //ForEach (self.lib.providers) { provider in
                List(self.lib.cbooks(providerFilter).filter {
                    ($0.title.lowercased().contains(
                        self.search.lowercased()) || self.search==""
                    )
                    && ($0.favourite==true || self.favOn==false)
                    && ($0.read==true || self.readOn==false)
                } ,id: \.self)
                { book in Button(action: {
                    //                self.showPlayer.toggle()
                    //self.sheetMode = .player
                    //self.showSheet.toggle()
                    
                    ///NOWE
                    ///
                    ///
                    
                    MXContextMenuModel.global.showContextSheet(content:
                                                                AnyView(PlayerView().environmentObject(self.player)
                                                                    .environmentObject(self.repo)))
                    
                    
                    DispatchQueue.global().async {
                        if (self.player.nowPlaying ?? nil) != book{
                            self.player.play(book: book)
                        }
                    }
                }, label: {
                    BookRowView2(book: book).background{ Cover2(book2: book).blur(radius: 40.0,opaque: true).opacity(0.1)
                            .edgesIgnoringSafeArea(.bottom)
                        
                        .padding(-10.0).padding(.horizontal,-15.0)}
                }).buttonStyle(PlainButtonStyle()) .background{Rectangle().foregroundColor(Color.background).ignoresSafeArea().padding(-10.0).padding(.horizontal,-15.0)}
                    
                    
                    
                }.listStyle(PlainListStyle()).background{Rectangle().foregroundColor(Color.background).ignoresSafeArea().padding(-10.0).padding(.horizontal,-15.0)}
                
                // }
            }
            
            
        
        
            Button(action: {
                MXContextMenuModel.global.showContextSheet(content:
                    AnyView(PlayerView().environmentObject(self.player)
                         .environmentObject(self.repo)))
                
            }, label: {
                SmallPlayerView().environmentObject(self.player)
            }).buttonStyle(PlainButtonStyle())
            
            
           
            
        }.background{Rectangle().foregroundColor(.background).edgesIgnoringSafeArea(.all)}
        .onReceive(showUpdatesPublisher){ _ in
            self.sheetMode = .progress
            self.showSheet = true
        }.sheet(isPresented: self.$showSheet, onDismiss: {
            self.showSheet = false
            self.sheetMode = .none
            self.repo.monthlySubsription.getSubscribtionState()
        }, content: {
              
        
        }).onTapGesture{
            
        }.onAppear{
            lib.getLastPlayedBookID()
        
            
        }
    }
    
    var addLibrariesInfo: some View{
     //   let .foreground = colorScheme == .dark ? Color.init(red: 0.8, green: 0.8, blue: 0.8) : Color.init(red: 0.3, green: 0.3, blue: 0.3)
        return VStack{
            Text("Oh!").font(.system(size: 22,weight: .bold))
            Text("There is nothing here.").font(.system(size: 22,weight: .bold)).padding(.bottom,80)
            Button(action:{
                self.showSheet = true
                self.sheetMode = .addingLibrary
            }){
                VStack{
                    Image(systemName: "plus").font(.system(size: 40,weight: .heavy)).foregroundColor(.foreground).padding(.bottom,2)
                    Text("Create new audiobook library,").font(.system(size: 14,weight: .bold))
                    Text("and start uploading your books").font(.system(size: 14, weight: .bold))
                }
            }.buttonStyle(PlainButtonStyle()).background(Color(UIColor.systemBackground))
        }
    }
    
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct BookProgress: View{
    var percent: Double
    
    var body: some View{
        return ZStack {
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.3)
                .foregroundColor(.white)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(percent, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(.foreground)
                .rotationEffect(Angle(degrees: 270.0))
            
        }.frame(minWidth: 0, maxWidth: 20, minHeight: 0, maxHeight: 20, alignment: .trailing)
    }
}

struct CircledImage: View{
    var image: Image? = nil
    var body: some View{
        return ZStack{
            Circle().fill(Color(UIColor.systemBackground))
            if(self.image != nil){
                image
            }
        }
    }
}
struct SuperTextField: View {

var placeholder: Text
@Binding var text: String
var editingChanged: (Bool)->() = { _ in }
var commit: ()->() = { }

var body: some View {
    ZStack(alignment: .leading) {
        if text.isEmpty { placeholder }
        TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
    }
}   }
