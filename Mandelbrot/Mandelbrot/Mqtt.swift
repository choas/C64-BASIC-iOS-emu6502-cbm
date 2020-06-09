//
//  Mqtt.swift
//  Mandelbrot
//
//  Created by Gregori, Lars on 07.06.20.
//

import Foundation
import CocoaMQTT

class Mqtt {
    
    let mqtt: CocoaMQTT?
    
    let defaultHost = "mqtt.eclipse.org"
    let topic = "c64/mandelbrot"
    
    init() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost, port: 1883)
        mqtt!.username = ""
        mqtt!.password = ""
        mqtt!.willMessage = CocoaMQTTMessage(topic: "/will", string: "dieout")
        mqtt!.keepAlive = 60
        mqtt!.delegate = self
        let _ = mqtt!.connect()
    }
    
    func publish(_ payload: [UInt8]) {
        if let mqtt = mqtt {
            mqtt.publish(CocoaMQTTMessage(topic: self.topic, payload: payload, qos: .qos0))
        }
    }
}

extension Mqtt: CocoaMQTTDelegate {
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // print("ping")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // print("pong")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("disconnect")
        let _ = mqtt.connect()
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            print("connected")
            mqtt.subscribe(self.topic, qos: .qos0)
        } else {
            print("ERROR: ack \(ack)")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        // publish message
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        // publish ack
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        // received message
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        // subscribe topic
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        // unsubscribe topic
    }
}
