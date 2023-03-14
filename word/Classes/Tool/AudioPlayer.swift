//
//  AudioPlayer.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit
import AVFoundation

protocol AudioPlayerDelegate: AnyObject {
    func playEnd(player: AudioPlayer, url: URL)
}

class AudioPlayer: NSObject {
    
    var repeatCount: Int = 2
    var repeatInterval: TimeInterval = 2
    weak var delegate: AudioPlayerDelegate?
    
    private var playCount: Int = 0
    var url: URL!
    var player: AVAudioPlayer!
    var task: DispatchWorkItem?
    var isPaused: Bool = false
    
    static let shared = AudioPlayer()
    
    private override init() { }
    
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
    
    deinit {
        
    }

}

extension AudioPlayer {
    func play(with url: URL) {
        self.url = url
        do {
            if player != nil {
                player.stop()
            }
            
            try player = AVAudioPlayer(contentsOf: url)
            player.delegate = self
            play()
        } catch {
            print("播放器创建失败")
        }
    }
    
    func play() {
        isPaused = false
        
        print(player.prepareToPlay())
        
        let flag = player.play()
        if flag {
            print("播放成功")
        } else {
            print("播放失败")
        }
    }

    func pause() {
        task?.cancel()
        
        isPaused = true
        
        player.pause()
    }
    
    func stop() {
        task?.cancel()
        
        player.stop()
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        
        playCount += 1

        guard playCount < repeatCount else {
            print("播放完成")
            delegate?.playEnd(player: self, url: url)
            playCount = 0
            return
        }

        task = DispatchWorkItem { [weak self] in
            guard self?.isPaused == false else { return }
            
            player.play()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + repeatInterval, execute: task!)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription)
    }
}
