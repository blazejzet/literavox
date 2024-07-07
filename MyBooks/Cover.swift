//
//  Cover.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct Cover: View {
    var book:Book
//    var height:CGFloat?
    
    var body: some View {
        ZStack{
            if book.image != nil{
                WebImage(url: URL(string: book.image!))
                    .resizable()
                    .placeholder {Rectangle().foregroundColor(.gray)}
//                    .indicator(.activity) // Activity Indicator
//                    .animation(.easeInOut(duration: 0.5)) // Animation Duration
//                    .transition(.fade) // Fade Transition
//                    .scaledToFit()
//                    .frame(width: nil, height: height, alignment: .center)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .shadow(radius: 20.0)
//                    .padding()
            }
            if let imdata = book.imageData, let image = UIImage(data: imdata) {
                Image(uiImage: image)
                    .resizable()
//                    .animation(.easeInOut(duration: 0.5)) // Animation Duration
//                    .transition(.fade) // Fade Transition
//                    .scaledToFit()
//                    .frame(width: nil, height: height, alignment: .center)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .shadow(radius: 20.0)
//                    .padding()
            }
        }
    }
}

//struct Cover_Previews: PreviewProvider {
//    static var previews: some View {
//        Cover(image: "?", height: 100)
//    }
//}


struct Cover2: View {
    var book2:Book2

    var body: some View {
        ZStack{
            
            if let imdata = book2.imageData, let image = UIImage(data: imdata) {
                Image(uiImage: image)
                    .resizable()
            }
        }
    }
}
