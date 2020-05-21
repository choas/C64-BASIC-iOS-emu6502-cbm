//
//  ViewController.swift
//  CbmbasicApp
//
//  Created by Gregori, Lars on 04.05.20.
//

import UIKit
import Emu6502Cbm

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var basicOutput: UITextView!
    @IBOutlet weak var textInputField: UITextField!
    
    let emu6502cbm = Emu6502cbm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startupPath: String? = nil //Bundle.main.path(forResource: "startup", ofType: "prg")
        
        let queue = DispatchQueue(label: "emu6502cbm", qos: .background)
        
        queue.async {
            self.emu6502cbm.run(startup: startupPath)
        }
        
        let _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        textInputField.delegate = self // RETURN KEY
        textInputField.returnKeyType = .done

        basicOutput.text = ""
    }

    
    // detect RETURN KEY and close keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //self.view.endEditing(true)
        
        if let text = textField.text {
            self.emu6502cbm.cmd(command: text/*.uppercased()*/ + "\n")
        }
        textField.text = ""
        return false
    }
    
    @IBAction func button(_ sender: Any) {
        
        // Basic code from c-simple-emu6502-cbm
        // ... adjust RND
        let cmd = """
        10 PRINT "I'm thinking of a number between 1 and 99"
        15 C=0
        20 X=RND(-TI):X=INT(RND(1)*100+1)
        25 G=0
        30 PRINT "GUESS";:INPUT G
        40 IF G<=0 OR G>=100 OR G<>INT(G) THEN PRINT "TRY AGAIN":GOTO 30
        50 C=C+1
        60 IF G=X THEN PRINT "YOU GUESSED IN "C" TRIES":GOTO 10
        70 IF G<X THEN PRINT "TOO LOW, TRY HIGHER"
        80 IF G>X THEN PRINT "TOO HIGH, TRY LOWER"
        90 GOTO 30
        RUN

        """
        self.emu6502cbm.cmd(command: cmd)
    }
    
    @objc func update() {
        basicOutput.text! += self.emu6502cbm.read()
        let range = NSMakeRange(basicOutput.text.count * 2, 1)
        basicOutput.scrollRangeToVisible(range)
    }
}

