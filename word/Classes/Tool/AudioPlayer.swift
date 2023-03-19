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
    var repeatInterval: Double = 2
    weak var delegate: AudioPlayerDelegate?
    
    private var playCount: Int = 0
    var url: URL!
    var player: AVAudioPlayer!
    var task: DispatchWorkItem?
    var isPaused: Bool = false
    
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
    func prepareToPlay(with url: URL) -> Bool {
        self.url = url
        do {
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
        isPaused = false
        
        guard player != nil else { return }

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
        
        url = nil
        player = nil
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
}
