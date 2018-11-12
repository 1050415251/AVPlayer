//
//  AVFoundationDownloadManager.swift
//  AvFoudationDemo
//
//  Created by 国投 on 2018/11/12.
//  Copyright © 2018 FlyKite. All rights reserved.
//

import Foundation
import AVFoundation

class  AVFoundationDownloadManager: NSObject {

    fileprivate var requestlist: [AVAssetResourceLoadingRequest] = []


}


extension AVFoundationDownloadManager: AVAssetResourceLoaderDelegate {






    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {

    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {

        return true
    }

    


    /// //在系统不知道如何处理URLAsset资源时回调回调
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {

        let recourseurl = loadingRequest.request.url
        if recourseurl?.scheme == SCHEME {
            //判断当前的URL网络请求是否已经被加载过了，如果缓存中里面有URL对应的网络加载器(自己封装，也可以直接使用NSURLRequest)，则取出来添加请求，每一个URL对应一个网络加载器，loader的实现接下来会说明

        }

        return false
    }

}
