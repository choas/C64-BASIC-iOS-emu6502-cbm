//
//  CbmBasic.swift
//  CbmBasic
//
//  Created by Gregori, Lars on 04.05.20.
//  Copyright © 2020 Gregori, Lars. All rights reserved.
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
}
