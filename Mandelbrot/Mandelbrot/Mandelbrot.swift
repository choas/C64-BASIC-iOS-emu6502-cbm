//
//  Mandelbrot.swift
//  Mandelbrot01
//
//  Created by Gregori, Lars on 24.05.20.
//

import Foundation


class Mandelbrot {
    /*
     90 REM **TO CHANGE THE SHAPE, CHANGE**
     91 REM **XL,XU,YL,YU. REPS CHANGES  **
     92 REM **THE RESOLUTION**
     100 XL = -2.000:XU = 0.500
     110 YL = -1.100:YU = 1.100
     115 REPS = 20
     120 WIDTH = 40:HEIGHT = 25
     */

    var xl = -2.0
    var xu = 0.5
    var yl = -1.1
    var yu = 1.1

    let reps = 40
    let width = 40
    let height = 25
    
    var xinc: Double
    var yinc: Double
    
    var m: [UInt]

    /*
     130 XINC = (XU-XL)/WIDTH
     140 YINC = (YU-YL)/HEIGHT
     */
    
    init() {
        self.xinc = (xu - xl) / Double(width)
        self.yinc = (yu - yl) / Double(height)
        self.m = [UInt](repeating: 0, count: width * height)
    }
    
    func calc() {

        /*
         200 REM MAIN ROUTINE
         205 PRINT "{CLEAR}"
         210 FOR J = 0 TO HEIGHT - 1
         211 REM PRINT J
         220 : FOR I = 0 TO WIDTH - 1
         230 :   GOSUB 300
         231 :   GOSUB 400
         240 : NEXT I
         250 NEXT J
         290 GET A$:IF A$ = "" THEN 290
         299 END
         */

        for j in 0 ..< height {
            for i in 0 ..< width {
                let ismnd = calcMandel(i: i, j: j)
                let count = i + j * width
                
                m[count] = UInt(ismnd)
            }
        }
    }
    
    func calcMandel(i: Int, j: Int) -> Int {
        /*
         300 REM CALCULATE MANDELBROT
         310 ISMND = -1
         312 NREAL = XL + I * XINC
         313 NIMG  = YL + J * YINC
         315 RZ = 0:IZ = 0
         316 R2Z = 0:I2Z = 0
         320 FOR K = 1 TO REPS
        */
        
        let nreal = self.xl + Double(i) * self.xinc
        let nimg = self.yl + Double(j) * self.yinc
        var rz = 0.0
        var iz = 0.0
        var r2z = 0.0
        var i2z = 0.0
        for k in 1 ... self.reps {

            /*
             330 : R2Z = RZ*RZ - IZ*IZ
             340 : I2Z  = 2*RZ*IZ
             350 : RZ  = R2Z+NREAL
             360 : IZ   = I2Z +NIMG
             
             IF (RZ*RZ + IZ*IZ)>4 THEN ISMND=K:K=REPS
             */
            
            r2z = rz * rz - iz * iz
            i2z = 2 * rz * iz
            rz = r2z + nreal
            iz = i2z + nimg
            
            if (rz * rz + iz * iz) > 4 {
                return k
            }
        }
        /*
         390 NEXT K
         399 RETURN
         */
        return 0

    }
}

