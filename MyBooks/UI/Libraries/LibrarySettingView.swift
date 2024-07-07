//
//  LibrarySettingView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 20/12/2022.
//  Copyright © 2022 Blazej Zyglarski. All rights reserved.
//

import Foundation

import SwiftUI

struct LibrarySettingView : View{
    @EnvironmentObject var repo: BooksRepository
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var lib: Library
    @State var url: URL
    @State var repoindex: Int
    @State var name: String = ""
    @State var icon: String = "paperplane"
    var icons = ["paperplane","scribble.variable","book.closed","magazine","bookmark","camera.macro","sun.min","moon","cloud","sparkles","smoke","wind","snow","tornado","house","airplane","figure.walk","ferry","car","mustache","nose","eyes","mouth","hand.tap","flame","globe.americas","leaf","ant","ladybug","pawprint","hare","bolt","signature"]
    @State var color =  Color.red
    var colors :  [Color] = [.red,.blue,.yellow,.brown,.cyan,.gray,.green,.indigo,.mint,.pink,.purple,.teal]
    
    
    var body : some View{
        VStack(spacing: 20.0){
            VStack{
                HStack(){
                    
                    Text("Library Settings").font(.largeTitle).bold()
                    Spacer()
                    Button(action:{
                        MXContextMenuModel.global.hideContextMenu()
                        
                    }){
                        Image(colorScheme == .dark ? "xw" : "x").renderingMode(.original).resizable().frame(width: 25, height: 25)
                    }
                    
                }
                
                HStack(spacing:0){
                    
                    Text("Provide details for newly added library").font(.system(size: 22,weight:.light)).padding(0)
                    Spacer()
                    
                }
            }
            VStack{
                HStack{
                    
                    Text("Filesystem Path").font(.subheadline).bold()
                    Spacer()
                    
                }
                HStack{
                    
                    //ScrollView(.horizontal) { Text(url.path()).font(.subheadline)}
                    
                    
                }
            }
            VStack{
                HStack{
                    
                    Text("Library Name").font(.subheadline).bold()
                    Spacer()
                    
                }
                HStack{
                    TextField("Provide a name", text: $name).textFieldStyle(.roundedBorder)
                }
            }
            VStack{
                HStack{
                    
                    Text("Icon").font(.subheadline).bold()
                    Spacer()
                    
                }
                
                ScrollView(.horizontal) {
                    HStack{
                        ForEach(icons, id: \.self){ icon in
                            Button(action: {
                                self.icon = icon
                            }){
                                Image(systemName: icon)
                                    .padding(10.0)
                                    .foregroundColor(.black )
                                    .background{
                                        Circle().foregroundColor(color).opacity(self.icon == icon ? 1.0 : 0.2 )
                                }
                            }
                        }
                    }
                }
            }
            VStack{
                HStack{
                    
                    Text("Colour").font(.subheadline).bold()
                    Spacer()
                    
                }
                
                ScrollView(.horizontal) {
                    HStack{
                        ForEach(colors, id: \.self){ color in
                            Button(action: {
                                self.color = color
                            }){
                                ZStack{
                                    Circle().frame(width: 30,height: 30).foregroundColor(.primary).opacity(self.color == color ? 1.0 : 0.1 )
                                    Circle().frame(width: 15,height: 15).foregroundColor(color)
                                }
                                 
                            }
                        }
                    }
                }
            }
            Spacer()
            Button(action:{
                MXContextMenuModel.global.hideContextMenu()
                print("Adding url \(url.path) + \(name)")
                url.startAccessingSecurityScopedResource()
                var bd =  repo.saveBookmarkData(for: url)
                lib.addLocalProvider(name: name, url: url,bd:bd!, icon: self.icon, color: UIColor(self.color), category: "adult")
            }){
               
                Image(systemName: "plus.circle").font(.system(size: 25)).foregroundColor(.white)
                Text("Save").foregroundColor(.white)
                
            }.padding(12).background(Rectangle().foregroundColor(.black).cornerRadius(20.0))
            
            
        }.padding(30.0)
    }
}
