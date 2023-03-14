//
//  AudioPlayer.swift
//  word
//
//  Created by 小红李 on 2023/3/13.
//

import UIKit
import AVKit

protocol AudioPlayerDelegate: AnyObject {
    func playEnd(player: AudioPlayer, url: URL)
}

class AudioPlayer: NSObject {
    
    var repeatCount: Int = 2
    var repeatInterval: TimeInterval = 2
    weak var delegate: AudioPlayerDelegate?
    
    private var playCount: Int = 0
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var url: URL!
    
    
    static let shared = AudioPlayer()
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
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
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func playToEndTime() {
        playCount += 1
        
        guard playCount < repeatCount else {
            print("播放完成")
            delegate?.playEnd(player: self, url: url)
            playCount = 0
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + repeatInterval) {
            self.replay()
        }
    }
}

extension AudioPlayer {
    func play(with url: URL) {
        self.url = url
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1
        player.play()

    }
    
    func replay() {
        guard player != nil else { return }

        let time = CMTimeMake(value: Int64(floorf(0)), timescale: 1)
        player.seek(to: time)
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    
}
