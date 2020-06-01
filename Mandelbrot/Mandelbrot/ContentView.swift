//
//  ContentView.swift
//  Mandelbrot01
//
//  Created by Gregori, Lars on 22.05.20.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var c64 = C64Mandelbrot()
    @GestureState private var tap = false
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100*40/25, height: 100*1))
        
    var body: some View {

        return ScrollView {
            Image(uiImage: createImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture(count: 2) {
                    print("tap")
                    self.c64.nextMandelbrot()
                }
        }.background(Color.black)
    }
    
    fileprivate func createImage() -> UIImage {
        return renderer.image { ctx in
            
            let height = 25
            let width = 40
            for py in 0..<width {
                for px in 0..<height {
                    
                    var hue = 0.6
                    
                    var reps: Double = Double(self.c64.reps)
                    
                    reps = 70.0
                    
                    let d = reps / 4.0
                    
                    var r = Double(c64.ram[px * width + py]) / d //10.0
                    if r > 1.0 {
                        hue -= (0.1 / (reps / d) * r)
                        r = 1.0
                    }
                    ctx.cgContext.setFillColor(UIColor.init(hue: CGFloat(hue), saturation: CGFloat(1.0), brightness: CGFloat(r), alpha: 1).cgColor)
                    
                    ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                    ctx.cgContext.setLineWidth(0.2)
                    
                    let w = 100 / height
                    let h = w
                    let R = false
                    let x = w * (R ? px : py)
                    let y = h * (R ? py : px)
                    
                    
                    //            let rectangle = CGRect(x: i * 512/(anz*2), y: 0, width: 512/(anz*2), height: 512/anz)
                    let rectangle = CGRect(x: x, y: y, width: w, height: h)
                    ctx.cgContext.addEllipse(in: rectangle)
                    ctx.cgContext.drawPath(using: .fillStroke)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.colorScheme, .dark)
    }
}
