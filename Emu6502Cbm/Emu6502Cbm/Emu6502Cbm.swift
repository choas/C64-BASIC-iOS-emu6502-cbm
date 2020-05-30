//
//  CbmBasic.swift
//  CbmBasic
//
//  Created by Gregori, Lars on 04.05.20.
//

import Foundation
import Libemu6502cbm


@objc(Cbmbasic)
public final class Emu6502cbm : NSObject {
    
    private var errorString = "";
    
    @objc public override init() {
    }
    
    public func run(startup startupPath: String?) {
        if let startupPath = startupPath {
            Libemu6502cbm.StartupPRG = strdup(startupPath)
        }
        
        let basic = "basic.901226-01"
        let chargen = "characters.901225-01"
        let kernal = "kernal.901227-03"
        let type = "bin"
        let basicPath = Bundle.main.path(forResource: basic, ofType: type)
        let chargenPath = Bundle.main.path(forResource: chargen, ofType: type)
        let kernalPath = Bundle.main.path(forResource: kernal, ofType: type)
        
        if (basicPath == nil || chargenPath == nil || kernalPath == nil) {
            errorString = "ERROR: ROMs are missing\n";
            print(errorString)
            return
        }

        Libemu6502cbm.C64_Init(64*1024, basicPath, chargenPath, kernalPath)
        Libemu6502cbm.MyResetRun()
    }

    
    public func cmd(command: String) {
        setCommand(command);
    }

    public func read() -> String {
        func getChar() -> Character {
            return Character(UnicodeScalar(readChar()))
        }

        var buf = "";
        if (errorString.count > 0) {
            buf += errorString
            errorString = ""
        }
        var c = getChar()
        while c != Character(UnicodeScalar(255)) {
            buf += String(c)
            c = getChar()
        }
        return buf;
    }
    
    public func readRam(addr baseaddr: Int, count: Int) -> [UInt8] {
        var data = [UInt8](repeating: 0, count: count)
        for i in 0..<count {
            let addr = baseaddr + i
            data[i] = GetMemory(ushort(addr))
        }

        return data
    }
    
    public func writeRam(addr baseaddr: Int, data: [UInt8]) {
        for i in 0..<data.count {
            SetMemory(ushort(baseaddr + i), data[i])
        }
    }
}
