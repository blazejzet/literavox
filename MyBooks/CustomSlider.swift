//
//  CustomSlider.swift
//  MyBooks
//
//  Created by Blazej Zyglarski on 04/05/2020.
//  Copyright © 2020 Blazej Zyglarski. All rights reserved.
//

import SwiftUI
struct CustomSlider<Component: View>: View {

    @Binding var value: Double
    var cb: (Bool)->Void?
    
    var range: (Double, Double)
    var knobWidth: CGFloat?
    let viewBuilder: (CustomSliderComponents) -> Component
    @GestureState private var isTapped = false
    
    init(value: Binding<Double>,cb: @escaping (Bool)->Void?,range: (Double, Double), knobWidth: CGFloat? = nil,
         _ viewBuilder: @escaping (CustomSliderComponents) -> Component
    ) {
        _value = value
        //_bookmarksCount = bookmarksCount
        //_bookmarks = bookmarks
        self.range = range
        self.viewBuilder = viewBuilder
        self.knobWidth = knobWidth
        self.cb = cb
    }

    var body: some View {
        GeometryReader { geometry in
          self.view(geometry: geometry) // function below
        }
    }
    private func view(geometry: GeometryProxy) -> some View {
      let frame = geometry.frame(in: .global)
      let drag = DragGesture(minimumDistance: 0).onChanged({ drag in
        self.onDragChange(drag, frame)}
      ).updating($isTapped) { (_, isTapped, _) in
          isTapped = true
      }.onEnded( {drag in
        self.cb(true)
      })
        
        
        let offsetX = self.getOffsetX(frame: frame)
        
        let knobSize = CGSize(width: (knobWidth ?? frame.height) * (isTapped ? 1.0 : 0.7), height: frame.height  * (isTapped ? 1.0 : 0.7))
        let bookSize = CGSize(width: frame.height / 6.0, height: frame.height )
        
      let barLeftSize = CGSize(width: CGFloat(offsetX + knobSize.width * 0.5), height:  frame.height)
        
      let barRightSize = CGSize(width: frame.width - barLeftSize.width, height: frame.height)

        
        
      let modifiers = CustomSliderComponents(
          barLeft: CustomSliderModifier(name: .barLeft, size: barLeftSize, offset: frame.height *  0.15, offsetY: 0),
          barRight: CustomSliderModifier(name: .barRight, size: barRightSize, offset: barLeftSize.width - frame.height *  0.15, offsetY: 0),
          knob: CustomSliderModifier(name: .knob, size: knobSize, offset: offsetX + frame.height * (isTapped ? 0.0 : 0.15), offsetY: frame.height * (isTapped ? 0.0 : 0.15) )
        )

        return ZStack {
            
            viewBuilder(modifiers).gesture(drag)
        }
    }
    
    private func getOffsetX(frame: CGRect) -> CGFloat {
        let width = (knob: knobWidth ?? frame.size.height, view: frame.size.width)
        let xrange: (Double, Double) = (0, Double(width.view - width.knob))
        let result = self.value.convert(fromRange: range, toRange: xrange)
        return CGFloat(result ?? 0.0)
    }
    private func getOffsetX(val:Double, frame: CGRect) -> CGFloat {
        let width = (knob: knobWidth ?? frame.size.height, view: frame.size.width)
        let xrange: (Double, Double) = (0, Double(width.view - width.knob))
        let result = val.convert(fromRange: range, toRange: xrange)
        return CGFloat(result ?? 0.0)
    }
    
    private func onDragChange(_ drag: DragGesture.Value,_ frame: CGRect) {
        let width = (knob: Double(knobWidth ?? frame.size.height), view: Double(frame.size.width))
        let xrange = (min: Double(0), max: Double(width.view - width.knob))
        var value = Double(drag.startLocation.x + drag.translation.width) // knob center x
        value -= 0.5*width.knob // offset from center to leading edge of knob
        value = value > xrange.max ? xrange.max : value // limit to leading edge
        value = value < xrange.min ? xrange.min : value // limit to trailing edge
        value = value.convert(fromRange: (xrange.min, xrange.max), toRange: range)
        print("changing to \(value)")
        if self.value != value { self.cb(false) }
        self.value = value
    }
    
    
}

struct CustomSliderComponents {
    let barLeft: CustomSliderModifier
    let barRight: CustomSliderModifier
    let knob: CustomSliderModifier
}
struct CustomSliderModifier: ViewModifier {
    enum Name {
        case barLeft
        case barRight
        case knob
        case bookmark
    }
    let name: Name
    let size: CGSize
    let offset: CGFloat
    let offsetY: CGFloat
    

    func body(content: Content) -> some View {
        content
        .frame(width: size.width)
        .position(x: size.width*0.5, y: size.height*0.5)
            .offset(x: offset, y:offsetY)
    }
}

extension Double {
    func convert(fromRange: (Double, Double), toRange: (Double, Double)) -> Double {
        // Example: if self = 1, fromRange = (0,2), toRange = (10,12) -> solution = 11
        var value = self
        value -= fromRange.0
        value /= Double(fromRange.1 - fromRange.0)
        value *= toRange.1 - toRange.0
        value += toRange.0
        return value
    }
}




//struct CustomSlider_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        CustomSlider(value: .constant(0.1), range: (0.0,1.0) ){ modifiers in
//            ZStack {
//              Color.blue.cornerRadius(3).frame(height: 6).modifier(modifiers.barLeft)
//              Color.blue.opacity(0.2).cornerRadius(3).frame(height: 6).modifier(modifiers.barRight)
//              
//                
//              ZStack {
//                Circle().fill(Color.white)
//                Circle().stroke(Color.black.opacity(0.2), lineWidth: 2)
//              }.modifier(modifiers.knob)
//                
//                
//              
//            }
//            
//        }.frame( height: 40.0)
//    }
//}
