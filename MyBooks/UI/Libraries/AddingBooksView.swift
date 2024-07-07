//
//  AddingBooksView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 09/02/2023.
//  Copyright © 2023 Blazej Zyglarski. All rights reserved.
//

import Foundation

import Foundation
import SwiftUI
import UIKit

struct AddingBooksView : View{
    
    @Environment (\.colorScheme) var colorScheme : ColorScheme
    @EnvironmentObject var lib:Library
    
    @Binding var repo: Provider?
    
    var body : some View{
        
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
     //   if (colorScheme == .dark){
//            .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//            .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
            
      //  }
        
        
        return VStack{
             
                
             
                    
                HStack{
                    Text("Adding books").font(.largeTitle).bold()
                    Spacer()
                    Button(action:{
                        MXContextMenuModel.global.hideContextMenu()
                        
                    }){
                        Image("x").renderingMode(.original).resizable().frame(width: 25, height: 25)
                    }
                }
                HStack{
                    Text("You can manage Your books in this folder with system browser. Simply put there a subfolder containing all audiobook files")
                    Spacer()
                }
                Rectangle().frame(height: 20.0).foregroundColor(.clear)
                HStack{
                    Text("Repository name").font(.subheadline).bold()
                    Spacer()
                }
                HStack{
                    Text(repo?.instancename ?? "").font(.subheadline)
                    Spacer()
                }
                if let rr = repo as? LocalProvider {
                    Rectangle().frame(height: 20.0).foregroundColor(.clear)
                    HStack{
                        Text("Repository folder").font(.subheadline).bold()
                        Spacer()
                    }
                    HStack{
                        ScrollView(.horizontal){Text(rr.server).font(.subheadline)}
                        Spacer()
                    }
                    
                    Rectangle().frame(height: 20.0).foregroundColor(.clear)
                    
                    Button(action:{
                        if let url = URL(string: rr.server.replacingOccurrences(of: "file:", with: "shareddocuments:")){
                            UIApplication.shared.open(url)
                        }
                    }){
                        Image(systemName: "folder").font(.system(size: 25)).foregroundColor(.white)
                        Text("Open folder").foregroundColor(.white)
                    }.padding(12).background(Rectangle().foregroundColor(.black).cornerRadius(20.0))
                    
                }
                Spacer()
            }.padding(30)
        
    }
}
