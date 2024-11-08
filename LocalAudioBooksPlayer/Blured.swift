//
//  Blured.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 03/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct Blured: View {
    //    var image:String
    var book:Book2
    var body: some View {
        ZStack{
            
            if book.imageData != nil{
                Image(uiImage: UIImage(data: book.imageData!)!)
                    .resizable()
                    .animation(.easeInOut(duration: 0.5)) // Animation Duration
                    .transition(.fade) // Fade Transition
                    .scaledToFit()
                    .blur(radius: 200.0)
            }
        }
        
    }
}

//struct Blured_Previews: PreviewProvider {
//    static var previews: some View {
//        Blured(image: "")
//    }
//}
