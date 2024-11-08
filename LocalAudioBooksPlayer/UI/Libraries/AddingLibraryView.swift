//
//  LibrariesTypesView.swift
//  LocalAudioBooksPlayer
//
//  Created by Dawid Jenczewski on 26/01/2021.
//  Copyright © 2021 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI

struct AddingLibraryView : View{
    @EnvironmentObject var lib:Library
    @Environment(\.colorScheme) var colorScheme
    var body : some View{
        VStack{
            HStack{
                
                Text("Adding library").font(.largeTitle).bold()
                Spacer()
                Button(action:{
                    MXContextMenuModel.global.hideContextMenu()
                    
                }){
                    Image( colorScheme == .dark ? "xw" : "x" ).renderingMode(.original).resizable().frame(width: 25, height: 25)
                }
                
            }
            HStack{
                
                Text("Add new library folder.").font(.system(size: 22,weight:.light)).padding(0)
                Spacer()
                
            }
            HStack{
                
                Text("You should add a folder containing **one or more folders** with audio files. It means, that You should select whole **library containing** folder. Further operations can be performed by simply managing this folder in Finder/Files app.") .font(.system(size: 20)).padding(0)
                Spacer()
                
            }.padding(.top,10)
            HStack{
                
                Text("Do not use single book folder.") .font(.system(size: 14)).padding(0)
                Spacer()
                
            }.padding(.top,10)
            
            ForEach(0 ..< lib.availableProviders.count) {repoindex in
                var repox = lib.availableProviders[repoindex]
                
                
                Button(action: {
                    
                    MXContextMenuModel.global.showContextSheet(content:
                        AnyView(
                        
                            FilePickerUIRepresentable(types: [.folder], allowMultiple: false) { urls in
                               
                                if let first = urls.first{
                                    
                                    
                                    MXContextMenuModel.global.showContextSheet(content:
                                        AnyView(
                                        
                                            LibrarySettingView(url:first,repoindex:repoindex).environmentObject(lib)
                                        
                                        
                                        )
                                    )
                                    
                                    
                                    
                                }
                            }
                        
                        
                        )
                    )
                               
                }){
                    
                        
                        HStack{
                            
                            Image(systemName:repox.icon).font(.system(size: 33)).foregroundColor(.white)
                            VStack{
                                Rectangle().frame(height: 6.0).foregroundColor(.clear)
                                
                                HStack{
                                    Text(repox.name).frame(alignment: .leading).font(.system(size: 20, weight: .bold)).padding(.bottom,10).foregroundColor(.white)
                                    Spacer()
                                    }
                                HStack{
                                    Text(repox.description).multilineTextAlignment(.leading).foregroundColor(.white)
                                    Spacer()
                                }
                            }.padding(5)
                            Image(systemName: "chevron.right").foregroundColor(.white)
                             
                        }.padding(20).background(Rectangle().foregroundColor(.black).opacity(0.5).cornerRadius(30.0))
                     
                    
                }
                
                
            }
            Spacer()
            
        }.padding(30)
             
    }
    
    
    
    
}
