//
//  AVFoundationManager.swift
//  AvFoudationDemo
//
//  Created by 国投 on 2018/11/12.
//  Copyright © 2018 FlyKite. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

//typedef struct{
//    CMTimeValue    value;     // 帧数
//    CMTimeScale    timescale;  // 帧率
//    CMTimeFlags    flags;
//    CMTimeEpoch    epoch;
//} CMTime;

let SCHEME = "zjl"

class AVFoundationManager: NSObject {

    // lazy 单例写法
    //static let instance = AVFoundationManager()

    fileprivate var player: AVPlayer?
    fileprivate var playeritem: AVPlayerItem?
    fileprivate var playprogressObserVer: Any?
    /// 下载管理
    fileprivate let downloadutil =  AVFoundationDownloadUtil()

    ///总前时间戳
    private var maxtimestamp: TimeInterval? {
        get {
            guard  let duration = playeritem?.duration.value else {
                return nil
            }
            guard  let scale = playeritem?.duration.timescale else {
                return nil
            }
            // 获取视频总长度 // 转换成秒
            let time = TimeInterval(duration) / TimeInterval(scale)

            return time
        }
    }

    ///当前时间戳
    private var currenttimestamp: TimeInterval? {
        get {
            let time = playeritem?.duration.seconds
            return time
        }set {
            if let stamp = newValue {
                let targetTime = CMTime.init(value: CMTimeValue(stamp), timescale: 1)
                player?.seek(to: targetTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { [weak self] finish in
                    if finish {
                        self?.player?.play()
                    }
                })

            }
        }
    }

    /// M码率
    open var rate: Float = 1.0 {
        didSet {
            player?.rate = rate
        }
    }

    /// M码率
    var isPlaying: Bool {
        get {
            guard let _ = player else { return false }
            return player?.rate != 0
        }
    }

    //MARK:- 初始化
    override init() {
        super.init()


    }

    private func initAvPlayService() {


    }



    /// 视频播放
    ///
    /// - Parameter timestamp: 如果传递时间戳则从
    @discardableResult
    public func play(url: URL,_ timestamp: TimeInterval?) -> AVPlayer {
        removeplayer() /// 移除对上一个视频的所有i监听

        var components = URLComponents.init(url: url, resolvingAgainstBaseURL: false)
        components?.scheme = SCHEME

        let asset = AVURLAsset.init(url: components!.url!)
        asset.resourceLoader.setDelegate(downloadutil, queue: DispatchQueue.main)

        playeritem = AVPlayerItem.init(asset: asset)
        // TODO: 添加监听
        // 视频状态
        playeritem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        // 缓冲进度
        playeritem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)

        if self.player == nil {
            self.player = AVPlayer.init(playerItem: playeritem!)
        }else {
            player?.replaceCurrentItem(with: playeritem)
        }

    
        playprogressObserVer = self.player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let _ = self else { return }
            if self?.player?.currentItem?.status == .readyToPlay {
                //更新进度条进度值
                let currentTime = CMTimeGetSeconds(self!.player!.currentTime())

                //一个小算法，来实现00：00这种格式的播放时间
                let all:Int=Int(currentTime)
                let m:Int=all % 60
                let f:Int=Int(all/60)
                let time = String.init(format: "%02d:%02d", f,m)
                debugPrint(time)
            }
        })

        ///设置当前时间戳
        currenttimestamp = timestamp

        return self.player!
    }

    public func play() {
        // 如果状态可以播放则直接播放
        if playeritem?.status == AVPlayerItem.Status.readyToPlay {
            player?.rate = rate
        }
    }

    public func pause() {
        player?.pause()
    }

    public func cache(_ url: String) {

    }

    public func setSound( voice: Float) {
        player?.volume = voice
    }

    private func removeplayer() {
        // TODO: 移除监听
        playeritem?.removeObserver(self, forKeyPath: "status")
        playeritem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        if let obserVer = playprogressObserVer {
            player?.removeTimeObserver(obserVer)
        }

    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let c = change {
            switch keyPath {
            case "status":
                handlerstatuschange(change: c)
            case "loadedTimeRanges":
                handlerloadedTimeRange()
            default:
                break
            }
        }
    }

    //MARK: 处理视频状态改变
    private func handlerstatuschange(change: [NSKeyValueChangeKey : Any]) {
        if let value = change[NSKeyValueChangeKey.newKey] as? Int,let status = AVPlayerItem.Status.init(rawValue: value) {
            switch status {
            case .unknown:
                debugPrint("未知")
            case .failed:
                break
               // debugPrint("发生错误")
            case .readyToPlay:
                self.play()

                ///必须播放后设置
                debugPrint("可以开始播放")
            }
        }
    }

    //MARK: 处理视频缓冲
    private func handlerloadedTimeRange() {
        guard let duration = playeritem?.duration else { return }
        // 通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
        let loadedTime = avalableDurationWithplayerItem()
        let totalTime = CMTimeGetSeconds(duration)
        let percent = loadedTime/totalTime // 计算出比例

        let result = String.init(format: "%.2lf", percent * 100)//String.init("%0.2d",percent)
        debugPrint("缓冲进度\(result)%")
        /// 缓冲进度

    }

    // 计算当前缓冲进度
    private func avalableDurationWithplayerItem() -> TimeInterval{
        guard let loadedTimeRanges = self.player?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        let timeRange = first.timeRangeValue
        let startSeconds =  CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSecound
        return result
    }



    deinit {
        removeplayer()
        player = nil
    }

}


extension AVFoundationManager {

    ///获取视频某个时间的图片
    class func getdataimg(url: URL,timestamp: TimeInterval,complete: ((UIImage?)->Void)?) {
        DispatchQueue.global().async {
            do {
                //生成视频截图
                let generator = AVAssetImageGenerator (asset: AVAsset.init(url: url))
                ///按视频的正确方向截图
                generator.appliesPreferredTrackTransform = true
                let targetTime = CMTime.init(value: CMTimeValue(timestamp), timescale: 1)
                var actualTime = CMTime.init(value: 0, timescale: 0)
                let imageRef: CGImage = try generator.copyCGImage(at: targetTime, actualTime: &actualTime)
                let img = UIImage (cgImage: imageRef)
                DispatchQueue.main.async {
                    complete?(img)
                }
            }catch {
                DispatchQueue.main.async {
                    complete?(nil)
                }
            }
        }
    }

}
