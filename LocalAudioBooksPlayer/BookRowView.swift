//
//  BookRowView.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct BookRowView: View {
    
    @ObservedObject var book:Book
    var body: some View {
        
       return HStack{
        ZStack{
//        WebImage(url: URL(string: book.image!)).placeholder {Rectangle().foregroundColor(.gray)}.resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:100.0, height: 100.0, alignment: .center).padding(5.0).shadow(radius: 30)
           Cover(book: book).scaledToFit().clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:100.0, height: 100.0, alignment: .center).padding(5.0).shadow(radius: 30)
            if(book.image == nil && book.imageData == nil){
                ZStack{
                    Image(systemName: "photo.fill.on.rectangle.fill")
                }.clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:100.0, height: 100.0, alignment: .center).padding(5.0).shadow(radius: 30)
            }
            SymbolView(mark:book.symbol ?? Mark(icon: "ant", color: .black) ).offset(x:-40, y:-40)
        }
        VStack(alignment: .leading){
            Spacer()
            Text(book.title!.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.headline).lineLimit(0)
            Text(book.author?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "-")
                .font(.subheadline).lineLimit(0)
            Text(book.folder?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "-")
                .font(.subheadline).lineLimit(0)
            Text("\(book.id)")
                .font(.subheadline).lineLimit(0)
            if book.populating{
                Text("POP")
            }
            HStack(spacing: 5){
                if book.read ?? false {
                    Image("read_on").renderingMode(.original).resizable().frame(width: 15, height: 15)
                    Text("Ukończona").font(.footnote).padding(.trailing,10)
                }
                if book.favourite ?? false {
                    
                        Image("favourite_on").renderingMode(.original).resizable().frame(width: 15, height: 15)
                        Text("Ulubiona").font(.footnote)
                    
                }
            }
            Spacer()
        }
        Spacer()
       }.background(Color.backgroundLight)
    }
}

struct BookRowView_Previews: PreviewProvider {
    static var previews: some View {
        BookRowView(book: .example)
    }
}



struct BookRowView2: View {
    
    @State var book:Book2
    var body: some View {
        
       return HStack{
        ZStack{
//        WebImage(url: URL(string: book.image!)).placeholder {Rectangle().foregroundColor(.gray)}.resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:100.0, height: 100.0, alignment: .center).padding(5.0).shadow(radius: 30)
           
            Cover2(book2: book).scaledToFit().clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:100.0, height: 100.0, alignment: .center).padding(5.0).shadow(radius: 30)
            if(book.image == nil && book.imageData == nil){
                ZStack{
                    Image(systemName: "photo.fill.on.rectangle.fill")
                }.clipShape(RoundedRectangle(cornerRadius: 5)).frame(width:100.0, height: 100.0, alignment: .center).padding(5.0).shadow(radius: 30)
            }
//            SymbolView(mark:book.sy ?? Mark(icon: "ant", color: .black) ).offset(x:-40, y:-40)
        }.padding(.trailing,30)
        VStack(alignment: .leading){
            Spacer()
            Text(book.title.trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.headline).lineLimit(0).foregroundColor(.foreground)
            Text(book.author?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "-")
                .font(.subheadline).lineLimit(0).foregroundColor(.foreground)

            HStack(spacing: 5){
                if book.read ?? false {
                    Image("read_on").renderingMode(.original).resizable().frame(width: 15, height: 15)
                    Text("Ukończona").font(.footnote).padding(.trailing,10)
                }
                if book.favourite ?? false {
                    
                        Image("favourite_on").renderingMode(.original).resizable().frame(width: 15, height: 15)
                        Text("Ulubiona").font(.footnote)
                    
                }
            }
            Spacer()
        }
        Spacer()
       }
    }
}
