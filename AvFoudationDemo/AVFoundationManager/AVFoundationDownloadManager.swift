//
//  AVFoundationDownloadManager.swift
//  AvFoudationDemo
//
//  Created by 国投 on 2018/11/12.
//  Copyright © 2018 FlyKite. All rights reserved.
//

import Foundation
import AVFoundation

class  AVFoundationDownloadUtil: NSObject {

    fileprivate var requestlist: [AVAssetResourceLoadingRequest] = []
   
    fileprivate lazy var datamanager: DataManager = DataManager.newinstance(dataType: DataType.Download)

} 


extension AVFoundationDownloadUtil: AVAssetResourceLoaderDelegate {

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {

    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {

        return true
    }

    


    /// //在系统不知道如何处理URLAsset资源时回调回调
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {

        if let recourseurl = loadingRequest.request.url,recourseurl.scheme == SCHEME {
            var components = URLComponents.init(url: recourseurl, resolvingAgainstBaseURL: false)
            components?.scheme = "http"
            datamanager.taskstart(url: components!.url!)
            return true
        }
        return false
    }

}

