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
    weak var delegate: AudioPlayerDelegate?
    
    var url: URL!
    var player: AVAudioPlayer!
    
    open var isPlaying: Bool {
        if player == nil {
            return false
        }
        return player.isPlaying
    }
    
    static let shared = AudioPlayer()
    
    private override init() {

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
    
    deinit {
        
    }

}

extension AudioPlayer {
    @discardableResult
    func prepareToPlay(with url: URL) -> Bool {
        self.url = url
        do {
            if player != nil {
                player.stop()
                player = nil
            }
            
            let data = try Data(contentsOf: url)
            try player = AVAudioPlayer(data: data, fileTypeHint: AVFileType.mp3.rawValue)
            player.delegate = self
            return player.prepareToPlay()
        } catch {
            print(error)
            print("播放器创建失败")
        }
        
        return false
    }
    
    func play() {
//        isPaused = false
        
        guard player != nil else { return }

        let flag = player.play()
        if flag {
            print("播放成功")
        } else {
            print("播放失败")
        }
    }

    func pause() {
        guard player != nil else { return }
        guard player.isPlaying else { return }
//        isPaused = true
        
        player.pause()
    }
    
    func stop() {
        player.stop()
        
        url = nil
        player = nil
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard flag else { return }
        
        delegate?.playEnd(player: self, url: url)
    }
}
