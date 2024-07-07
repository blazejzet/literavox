//
//  ProvidersFilterListView.swift
//  MyBooks
//
//  Created by Dawid Jenczewski on 08/11/2021.
//  Copyright © 2021 Blazej Zyglarski. All rights reserved.
//

import Foundation
import SwiftUI


struct ProvidersFilterListView : View{
    @Environment (\.colorScheme) var colorScheme : ColorScheme
    @EnvironmentObject var lib: Library
    @Binding var selectedProvider: Provider?
    
    var addCallback: ()->Void
    
    var body : some View{
//        var .foreground = Color.init(red: 0.3, green: 0.3, blue: 0.3)
        //var .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//        var .backgroundLight = Color.black
        //if (colorScheme == .dark){
//            .foreground = Color.init(red: 22.0/255.0, green: 22.0/255.0, blue: 22.0/255.0)
//            .background = Color.init(red: 0.8, green: 0.8, blue: 0.8)
//            .backgroundLight = Color.white
        //}
        return ScrollView(.horizontal){
            HStack(alignment: .center, spacing: 10){
                
                ZStack{
                    if(selectedProvider == nil){
                        Circle().fill(RadialGradient(colors: [.foreground.opacity(0.3),.foreground.opacity(0.1)], center: UnitPoint.top, startRadius: 20, endRadius: 40)).frame(width: 38, height: 38)
                    }else{
                        Circle().fill(RadialGradient(colors: [.foreground.opacity(0.05),.foreground.opacity(0.05)], center: UnitPoint.top, startRadius: 20, endRadius: 40)).frame(width: 38, height: 38)
                    }
                    Image("icon").resizable().frame(width:30,height:30).clipShape(Circle())
                    BooksCounterView(count: lib.books.count).offset(x:13,y:-13)
                }.onTapGesture(perform: {
                    //self.hideKeyboard()
                    self.selectedProvider = nil
                })
                
                ForEach(self.lib.providers.map({IdentifiedProviders($0)}),id: \.id){
                    provider in
                    
                    ZStack{
                        if(selectedProvider?.providercode == provider.provider.providercode){
                            Circle().fill(RadialGradient(colors: [.foreground.opacity(0.3),.foreground.opacity(0.1)], center: UnitPoint.top, startRadius: 20, endRadius: 40)).frame(width: 38, height: 38)
                        }else{
                            Circle().fill(RadialGradient(colors: [.foreground.opacity(0.05),.foreground.opacity(0.05)], center: UnitPoint.top, startRadius: 20, endRadius: 40)).frame(width: 38, height: 38)
                        }
                        SymbolView(mark: provider.provider.symbol)
                        BooksCounterView(count: provider.provider.books.count).offset(x:13,y:-13)
                    }.onTapGesture(perform: {
                        //self.hideKeyboard()
                        self.selectedProvider = provider.provider
                    })
                    
                }
                
                
            }.padding(.top,5)
            
        }
        
    }
            
}



struct BooksCounterView: View{
    @Environment (\.colorScheme) var colorScheme : ColorScheme
    var count: Int
    
    var body: some View{
        Text("\(count)").font(.system(size: 10,weight: Font.Weight.medium))
            .padding(.horizontal,2)
            .padding(.vertical,1)
            .frame(minWidth: 14)
            .background(
                RoundedRectangle(cornerRadius: 9)
                    .foregroundColor(colorScheme == .light ? .white: .black)
            )
    }
    
    
    
}
