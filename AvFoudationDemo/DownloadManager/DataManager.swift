//
//  DataManager.swift
//  AvFoudationDemo
//
//  Created by 国投 on 2018/11/14.
//  Copyright © 2018 FlyKite. All rights reserved.
//

import Foundation
import UIKit

enum  DataType {
    case Upload
    case Download
}


class DataManager: NSObject {

    /// 是否在后台执行下载任务 默认不执行 可以更改
    var isBackgroundRun: Bool = false


    final class func newinstance(dataType: DataType) -> DataManager {
        var vc: DataManager!
        switch dataType {
        case .Download:
            vc = DataDownloadManager()
        case .Upload:
            break
        }
        return vc
    }

    override init() {
        super.init()
        initObserVer()
    }

    private func initObserVer() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func taskstart(url: URL) {
        
    }

    func taskpause(url: URL) {

    }

    @objc func applicationWillTerminate() {

    }

    @objc func applicationWillResignActive() {

    }

    @objc func applicationDidBecomeActive() {

    }

    /// 释放移除
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

}



