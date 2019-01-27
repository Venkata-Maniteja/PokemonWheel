//
//  WheelView.swift
//  PlayLog_test
//
//  Created by Rupika Sompalli on 25/01/19.
//  Copyright © 2019 Venkata. All rights reserved.
//

import UIKit

@IBDesignable

class WheelView: UIView  {
    
    var pointMapper  = [Int:CGPoint]()
    var path = UIBezierPath()
    let trackOffset = 10.0

    override func draw(_ rect: CGRect) {
        
        let radius: Double = Double(rect.width) / 2 - trackOffset
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        
        path.move(to: CGPoint(x: center.x + CGFloat(radius), y: center.y))
        
        for i in stride(from: 0, to: 361.0, by: 1) {
           
            // radians = degrees * PI / 180
            let radians = i * Double.pi / 180
            
            let x = Double(center.x) + radius * cos(radians)
            let y = Double(center.y) + radius * sin(radians)
            
            path.addLine(to: CGPoint(x: x, y: y))
            pointMapper[Int(i)] = CGPoint(x: x, y: y)
        }
        
        UIColor(red: 0.96, green: 0.30, blue: 0.46, alpha: 1.0).setStroke()
        path.lineWidth = 5
        path.stroke()
        
        
    }
    
   

}


