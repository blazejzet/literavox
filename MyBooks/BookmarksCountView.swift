//
//  BookmarksCountView.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 04/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI

struct BookmarksCountView: View {
     @Binding var count:Int?
    var body: some View {
      HStack{
            Image(systemName: "bookmark").resizable().frame(width: 10.0, height: 10.0).foregroundColor(.white)
        Text("\(self.count ?? 0)").foregroundColor(.white).font(.system(size: 10.0)).bold()
      }.padding(4.0).padding(.horizontal,6.0).background((self.count ?? 0 > 0) ? Color.red : Color.gray).cornerRadius(20.0)
    }
}

struct BookmarksCountView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksCountView(count: .constant(1))
    }
}
