//
//  CircularProgressIndicator.swift
//  LocalAudioBooksPlayer
//
//  Created by Blazej Zyglarski on 25/11/2019.
//  Copyright © 2019 Blazej Zyglarski. All rights reserved.
//

import SwiftUI

struct Arc : Shape
{
    @Binding var endAngle: Double

    var center: CGPoint
    var radius: CGFloat
    var color: Color

    func path(in rect: CGRect) -> Path
    {
        var path = Path()

        path.addArc(center: center, radius: radius, startAngle: .degrees(270), endAngle: .degrees(endAngle), clockwise: false)

        return path.strokedPath(.init(lineWidth: 3  , lineCap: .round))
    }
}


struct CircularProgressIndicator: View {
    @Binding var percent:Double
    var body: some View {
        
            ZStack() {
                
               
                Arc(endAngle: .constant(269.0) , center: CGPoint(x: 12, y:12), radius: CGFloat(8), color: .black).foregroundColor(.gray).opacity(0.2)
                Arc(endAngle: .constant( 360.0 * self.percent - 90.0 ), center: CGPoint(x: 12, y:12),radius: CGFloat(8)  , color: .black).foregroundColor(.gray)
            }.frame(width: 24, height: 24, alignment:.trailing)
        
    }
}

struct CircularProgressIndicator_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressIndicator(percent: .constant(0.3))
    }
}
