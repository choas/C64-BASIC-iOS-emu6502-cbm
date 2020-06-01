//
//  C64Mandelbrot.swift
//  Mandelbrot01
//
//  Created by Gregori, Lars on 28.05.20.
//

import Emu6502Cbm

class C64Mandelbrot: ObservableObject {
    
    @Published var ram = [UInt8](repeating: 0, count: 1000)
    
    let emu6502cbm = Emu6502cbm()
    var isCodeStarted = false
    var mandelbrotCount = 0
    
    init() {
        let queue = DispatchQueue(label: "emu6502cbm", qos: .background)
        queue.async {
            self.emu6502cbm.run(startup: nil)
        }

        let _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func setParameter(xl: Double, xu: Double, yl: Double, yu: Double, reps: UInt8) {
        let size = 8  // neg + 64 bit
        var param = [UInt8](repeating: 0, count: size * 4 + 1)

        convert(double: xl, in: &param, at: 0 * size)
        convert(double: xu, in: &param, at: 1 * size)
        convert(double: yl, in: &param, at: 2 * size)
        convert(double: yu, in: &param, at: 3 * size)
        param[param.count - 1] = reps

        self.emu6502cbm.writeRam(addr: 38000, data: param)
    }
    
    fileprivate func convert(double value: Double, in mem: inout [UInt8], at pos: Int) {
        var t = abs(value)
        var d = 1.0
        for i in 0...7 {
            let n = t * d
            t = t - (Double(Int(n)) / d)
            d *= 256.0
            mem[pos + i] = UInt8(n)
        }
        if value < 0 {
            mem[pos] += 0x80
        }
        
        var out = "\(value) -> "
        for i in 0...7 {
            out += "\(mem[pos + i]) "
        }
        print(out)
    }

    func runCode() {
        let param = """
        10 ADDR = 38000
        11 GOSUB 20: XL = V
        12 GOSUB 20: XU = V
        13 GOSUB 20: YL = V
        14 GOSUB 20: YU = V
        15 REPS = PEEK(ADDR)
        16 GOTO 120

        REM *** CONVERT MEM TO DOUBLE
        20 M = 1: V = 0: D = 1
        25 FOR I = 0 TO 7
        26 : X = PEEK(ADDR)
        27 : ADDR = ADDR + 1
        28 : IF (I = 0) AND ((X AND 128) > 0) THEN M = -1: X = X AND 127
        29 : V = V + (X / D)
        30 : D = D * 256
        35 NEXT
        36 V = V * M
        40 RETURN

        """

        let mandelbrot = """
        90 REM **TO CHANGE THE SHAPE, CHANGE**
        91 REM **XL,XU,YL,YU. REPS CHANGES  **
        92 REM **THE RESOLUTION**
        100 XL = -2.000:XU = 0.500
        110 YL = -1.100:YU = 1.100
        115 REPS = 20
        120 WIDTH = 40:HEIGHT = 25
        130 XINC = (XU-XL)/WIDTH
        140 YINC = (YU-YL)/HEIGHT
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
        300 REM CALCULATE MANDELBROT
        310 ISMND = -1
        312 NREAL = XL + I * XINC
        313 NIMG  = YL + J * YINC
        315 RZ = 0:IZ = 0
        316 R2Z = 0:I2Z = 0
        320 FOR K = 1 TO REPS
        330 : R2Z = RZ*RZ - IZ*IZ
        340 : I2Z  = 2*RZ*IZ
        350 : RZ  = R2Z+NREAL
        360 : IZ   = I2Z +NIMG
        370 : IF (RZ*RZ + IZ*IZ)>4 THEN ISMND=0:K=REPS
        390 NEXT K
        399 RETURN
        400 REM PLOT MANDELBROT
        410 COUNT = I+J*WIDTH
        420 POKE 1024+COUNT,160
        430 POKE 55296+COUNT,2 AND NOT ISMND
        499 RETURN

        REM *** ADJUST SOME CODE ***
        290 END
        310 ISMND = 0
        370 : IF (RZ*RZ + IZ*IZ)>4 THEN ISMND=K:K=REPS
        430 POKE 38000+COUNT,ISMND

        321 POKE 38000+(I+J*WIDTH),K

        """
        
        let run = """
        LIST
        RUN

        """

        self.emu6502cbm.cmd(command: param + mandelbrot + run)
    }
    
    fileprivate func isC64Started() -> Bool {
        
        let screenRam = self.emu6502cbm.readRam(addr: 1024, count: 1000)
        for (i, s) in screenRam.enumerated() {
            if i == 5 * 40 && s == 18 {
                return true
            }
        }
        
        return false
    }
    
    @objc func update() {
        if !isC64Started() && !isCodeStarted {
            return
        }
        
        if !isCodeStarted {
            isCodeStarted = true
            setParameter(xl: -2.0, xu: 0.5, yl: -1.1, yu: 1.1, reps: 40)
            runCode()
        }
        
        let result = self.emu6502cbm.readRam(addr: 38000, count: 1000);
        for (index, b) in result.enumerated() {
            ram[index] = UInt8(b)
        }

    }
    
    func nextMandelbrot() {
        self.mandelbrotCount += 1
        
        if mandelbrotCount == 1 {
            self.setParameter(xl: -0.6, xu: -0.5, yl: -0.6, yu: -0.7, reps: UInt8(40))
            self.runCode()
        } else if mandelbrotCount == 2 {
            self.setParameter(xl: -0.57, xu: -0.53, yl: -0.6, yu: -0.65, reps: UInt8(50))
            self.runCode()
        } else if mandelbrotCount == 3 {
            self.setParameter(xl: -0.562, xu: -0.547, yl: -0.6, yu: -0.627, reps: UInt8(70))
            self.runCode()
        } else if mandelbrotCount == 4 {
            self.setParameter(xl: -0.562, xu: -0.547, yl: -0.6, yu: -0.627, reps: UInt8(170))
            self.runCode()
        }
    }
}
