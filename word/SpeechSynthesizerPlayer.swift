//
//  SpeechSynthesizerPlayer.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit
import AVFoundation

class SpeechSynthesizerPlayer: NSObject {
    fileprivate let speechSynthesizer = AVSpeechSynthesizer()
    static let shared = SpeechSynthesizerPlayer()
    
    private override init() {
        super.init()
        speechSynthesizer.delegate = self
    }
    
    override func copy() -> Any {
        return self
    }
    
    override func mutableCopy() -> Any {
        return self
    }
    
    // Optional
    func reset() {
        // Reset all properties to default value
    }
}

extension SpeechSynthesizerPlayer: Player {
    func play() {
        
    }
    
    func next() {
        
    }
    
    func previous() {
        
    }
    
    func pause() {
        
    }
    
    
}

//MARK: AVSpeechSynthesizerDelegate
extension SpeechSynthesizerPlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("开始播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("播放完成")
//        guard isPaused == false else { return }
//
//        task = DispatchWorkItem { [weak self] in
//            self?.playNext()
//        }
        
//        DispatchQueue.main.asyn
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        print("暂停播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        print("继续播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("取消播放")
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
//        let subStr = utterance.speechString.dropFirst(characterRange.location).description
//        let rangeStr = subStr.dropLast(subStr.count - characterRange.length).description
//        willSpeekLabel.text = rangeStr
    }
}
