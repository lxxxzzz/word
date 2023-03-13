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
    var player : AVPlayer!
    var playerItem : AVPlayerItem!
    var url: URL!
    weak var delegate: AudioPlayerDelegate?
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
    
    @objc func playToEndTime(){
        print("播放完成")
        delegate?.playEnd(player: self, url: url)
    }
}

extension AudioPlayer: Player {
    func play() {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1
        player.play()
    }
    
    func play(with url: URL) {
        self.url = url
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player.rate = 1
        player.play()
    }
    
    func next() {
        
    }
    
    func previous() {
        
    }
    
    func pause() {
        player.pause()
    }
    
    
}
