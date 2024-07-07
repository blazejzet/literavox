//
//  ActivityIndicator.swift
//  privmx-pocket-2-ios
//
//

import SwiftUI


struct ActivityIndicator: View {
    
    @Binding var showIndicator: Bool
    var size:CGFloat = 60
   
   
    
    
    var body: some View{
        if(showIndicator){
        ZStack{
             
            Circle().fill(.gray).frame(width: size, height: size)
                CircularIndicator().frame(width: size/2, height: size/2)
             
        }.frame(alignment: .top)
        }
    }
}

struct CircularIndicator:View{
    @State var animate = false
    let color1 = Color.gray
    let color2 = Color.gray.opacity(0.5)
    let stype = StrokeStyle(lineWidth: 6, lineCap: .round)
//    @State var animate = false
    
    var body: some View{
        ZStack{
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(AngularGradient(gradient: .init(colors: [color1,color2]), center: .center), style: stype)
                .rotationEffect(Angle(degrees: animate ? 360 : 0))
//                .animation(Animation.linear, value: animate)
                .animation(Animation.linear.repeatCount(animate ? .max : 1, autoreverses: false), value: animate)
        }.onAppear(){
            self.animate = true
            
        }
        .onDisappear(){
            self.animate = false
        }
    }
}
