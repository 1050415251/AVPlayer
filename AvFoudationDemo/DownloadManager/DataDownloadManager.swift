//
//  DownloadManager.swift
//  AvFoudationDemo
//
//  Created by 国投 on 2018/11/14.
//  Copyright © 2018 FlyKite. All rights reserved.
//

import Foundation

class DataDownloadManager: DataManager {

    fileprivate var resumeData: [String:Data?] = [String:Data?]()
    fileprivate var tasks: [String: URLSessionDownloadTask?] = [String: URLSessionDownloadTask?]()


    override init() {
        super.init()

    }


    override func taskstart(url: URL) {
        //判断当前的URL网络请求是否已经被加载过了，如果缓存中里面有URL对应的网络加载器(自己封装，也可以直接使用NSURLRequest)，则取出来添加请求，每一个URL对应一个网络加载器，loader的实现接下来会说明

        downloadTask(url: url, isForgrond: true)
    }


    override func taskpause(url: URL) {
        tasks[url.absoluteString]??.suspend()

        // 注意这里如果使用这样的取消,那么就没办法恢复了!❤️
        //  [self.task cancel];

        // 如果是调用cancelByProducingResumeData方法, 方法内部会回调一个block, 在block中会将resumeData传递给我们
        // resumeData中就保存了当前下载任务的配置信息(下载到什么地方, 从什么地方恢复等等)❤️
//        [self.task cancelByProducingResumeData:^(NSData *resumeData) {
//            self.resumeData = resumeData;
//            }];
    }


    override func applicationWillTerminate() {
        killAllTask(complete: nil)
    }

    override func applicationDidBecomeActive() {
        /// 需求是后台下载的话悬疑注册后台下载任务
        if isBackgroundRun {
            killAllTask(complete: {

            })
        }else {
            tasks.forEach { (task) in
                if let url = URL.init(string: task.key) {
                    self.downloadTask(url: url, isForgrond: true)
                }
            }
        }

    }

    override func applicationWillResignActive() {
        killAllTask(complete: {
            if self.isBackgroundRun {
                ///切换任务至前台
                self.tasks.forEach { (task) in
                    if let url = URL.init(string: task.key) {
                        self.downloadTask(url: url, isForgrond: true)
                    }
                }
            }
        })

    }



    fileprivate func downloadTask(url: URL,isForgrond: Bool) {

        //不默认缓存
        //ephemeralSessionConfiguration
        let configuration =  isForgrond ?  URLSessionConfiguration.default:URLSessionConfiguration.background(withIdentifier: url.absoluteString)
        configuration.networkServiceType = isForgrond ? .default:.background
        /// 是否允许通过蜂窝移动网络下载
        configuration.allowsCellularAccess = true
        /// 是否允许通过低电量
        configuration.isDiscretionary = true

        let session = URLSession.init(configuration: configuration, delegate: self , delegateQueue: OperationQueue.current)

        var task: URLSessionDownloadTask?
        if let data = resumeData[url.absoluteString] as? Data {
            task = session.downloadTask(withResumeData: data)
        }else {
            let recourseurl = url
            let request = URLRequest.init(url: recourseurl)

            task = session.downloadTask(with: request)
            task?.taskDescription = recourseurl.absoluteString
            task?.resume()
            tasks[recourseurl.absoluteString] = task
        }

    }

    ///杀掉所有任务
    fileprivate func killAllTask(complete: (()->Void)?) {

        let group = DispatchGroup()
        ///创建线程 两个任务 一个积分明细 一个积分推荐标的list 完成后记得回到主线程刷新
        let queue = DispatchQueue.init(label: "workQueue", qos: DispatchQoS.default, attributes:
            DispatchQueue.Attributes.concurrent, autoreleaseFrequency:
            DispatchQueue.AutoreleaseFrequency.inherit, target: nil)

        //  程序将要被杀死的时候 结束任务并保存数据
        tasks.forEach {  task in
            group.enter()
            queue.async(group: group, qos: DispatchQoS.default, flags: DispatchWorkItemFlags.barrier, execute: { [weak self] in
                task.value?.cancel(byProducingResumeData: { (data) in
                    self?.resumeData[task.key] = data
                })
                self?.tasks[task.key] = nil ///任务清空 列表中保留任务
                group.leave()
            })
        }

        group.notify(queue: queue) {
            complete?()
        }
    }

}



extension DataDownloadManager: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        session.invalidateAndCancel()
        if let desc = downloadTask.taskDescription {
            tasks[desc] = nil
            if let dic = tasks.index(forKey: desc) {
                tasks.remove(at: dic) ///任务从列表中移除
            }

        }
    }

    /// 用户点击暂停 或者数据下载完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            // 如果下载任务可以恢复，那么NSError的userInfo包含了NSURLSessionDownloadTaskResumeData键对应的数据，保存起来，继续下载要用到
            if let data = (error! as NSError).userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
                if let desc = task.taskDescription {
                    resumeData[desc] =  data
                }
            }
        }

    }

    /// 继续下载时候调用
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {


    }

    /// 进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        /// 多任务可根据key来配置多个path
        print(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
    }

    /// 当app从后台r下载任务完成
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {

    }


    //
    //    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    //
    //    }
    //
    //    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    //
    //    }
}
