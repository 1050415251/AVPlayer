//
//  AVFoundationView.swift
//  AvFoudationDemo
//
//  Created by 国投 on 2018/11/12.
//  Copyright © 2018 FlyKite. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
// 播放器view
class AVFoundationView: UIView {

    fileprivate var mangager: AVFoundationManager = AVFoundationManager()

    private var playerLayer:AVPlayerLayer?

    private var videourl: URL?

    convenience init(url: URL) {
        self.init()
        videourl = url
        playerLayer = AVPlayerLayer.init(player: mangager.play(url: url, nil))
        self.layer.addSublayer(playerLayer!)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    private func initView() {
        addProgressView()
        addFuntionView()



    }

    //TODO: 添加进度view
    private func addProgressView() {
        
    }

    //MARK: 添加功能按钮
    private func addFuntionView() {

    }


}

extension TimeInterval {

    /// 时间序列化
    func formatPlayTime() -> String{
        if self.isNaN{
            return "00:00"
        }
        let Min = Int(self) / 60
        let Sec = Int(self) % 60
        return String(format: "%02d:%02d", Min, Sec)
    }

}


