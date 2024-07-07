//
//  LibrariesView.swift
//  MyBooks
//
//  Created by Dawid Jenczewski on 19/11/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct LibrariesView : View{
    @Environment (\.colorScheme) var colorScheme : ColorScheme
    @EnvironmentObject var lib:Library
    @State var showBanner = true
    @State var addProvidersIsShow = false
    @State var addSimpleServerIsShow = false
    @State var cloudServerConnected = false
    
    @State var cos = ["ala","melo","i","pomelo"]
    
     
    
    var body : some View{
        
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
    //    if (colorScheme == .dark){
//            .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//            .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
            
    //    }
      
        
        return VStack{
             
                
                HStack{
                    
                    Text("Your Libraries").font(.largeTitle).bold()
                    
                    Spacer(minLength: 10)
                    Button(action:{
                        MXContextMenuModel.global.hideContextMenu()
                        
                    }){
                        Image(colorScheme == .dark ? "xw" : "x").renderingMode(.original).resizable().frame(width: 25, height: 25)
                    }
                }
                
                
                HStack(spacing:0){
                    
                    Text("You can add multiple libraries placed in various places").font(.system(size: 22,weight:.light)).padding(0)
                    Spacer()
                    
                }
                
                Rectangle().frame(height: 20.0).foregroundColor(.clear)
                HStack(spacing:0){
                    
                    Text("Added sources").font(.system(size: 22,weight:.bold)).padding(0)
                    Spacer()
                    
                }
                
                
            
            Rectangle().frame(height: 20.0).foregroundColor(.clear)
                List{
                    ForEach(self.lib.providers.map({IdentifiedProviders($0)}),id: \.id){
                        provider in
                        
                        HStack{
                            SymbolView(mark: provider.provider.symbol).frame(width: 20,height: 20).padding(5)
                            
                            
                            Text(provider.provider.instancename).font(.system(size: 21, weight: .light))
                           
                            if provider.provider as? LocalStorageProvider != nil{
                                Image("config").renderingMode(.template).resizable().frame(width:20, height: 20).offset(x:5).foregroundColor(.foreground)
                            }
                           
                        }
                    }.onDelete(perform: {
                        indexSet in
                        
                        for index in indexSet{
                            let providerCode = self.lib.providers[index].providercode
                            //self.lib.removeProvider(providerCode: providerCode)
                            self.lib.removeProvider(providerCode: providerCode)
                            
                        }
                        self.lib.objectWillChange.send()
                    })
                }.offset(x: -15).padding(.top,10).animation(.easeInOut).listStyle(PlainListStyle())
//            }
            Spacer()
            
            HStack{
                Button(action:{
                    MXContextMenuModel.global.showContextSheet(content:
                                                                AnyView(AddingLibraryView().environmentObject(self.lib))
                                                   
                    
                    )
                }){
                    
                    Image(systemName: "plus.circle").font(.system(size: 25)).foregroundColor(.white)
                    Text("Add another").foregroundColor(.white)
                    
                }.padding(12).background(Rectangle().foregroundColor(.black).cornerRadius(20.0))
                Spacer()
                Button(action:{
                    
                    self.lib.reload()
                    MXContextMenuModel.global.hideContextMenu()
                }){
                   
                    Image(systemName: "arrow.2.squarepath").font(.system(size: 25)).foregroundColor(.white)
                    Text("Reload").foregroundColor(.white)
                    
                }.padding(12).background(Rectangle().foregroundColor(.black).cornerRadius(20.0))
                
            }
            
            
            
        }.padding(30).onAppear(){
            //self.repo.monthlySubsription.getSubscribtionState()
        }
       
        
    }
    
}

enum LibrariesSheetMode{
    case none, adding, customServer, iCloudServer
}

struct IdentifiedProviders : Identifiable{
    
    var id : String
    var provider : Provider
    
    init(_ provider: Provider){
        self.id = provider.providercode
        self.provider = provider
    }
}

struct LibrariesView_Previews: PreviewProvider {
    
    static var previews: some View {
        LibrariesView().environmentObject(BooksRepository())//.previewDevice(PreviewDevice(rawValue: "iPhone 8"))
    }
}

